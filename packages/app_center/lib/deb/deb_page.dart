import 'dart:async';

import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/constants.dart';
import 'package:app_center/deb/deb_model.dart';
import 'package:app_center/deb/deb_providers.dart';
import 'package:app_center/error/error.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:appstream/appstream.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:packagekit/packagekit.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:yaru/yaru.dart';

class DebPage extends ConsumerStatefulWidget {
  const DebPage({required this.id, super.key});
  final String id;

  @override
  ConsumerState<DebPage> createState() => _DebPageState();
}

class _DebPageState extends ConsumerState<DebPage> {
  StreamSubscription<PackageKitErrorCodeEvent>? _errorSubscription;

  @override
  void initState() {
    super.initState();

    _errorSubscription =
        ref.read(debModelProvider(widget.id)).errorStream.listen(showError);
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    _errorSubscription = null;
    super.dispose();
  }

  Future<void> showError(PackageKitServiceError e) => showErrorDialog(
        context: context,
        title: 'PackageKit error: ${e.code}',
        message: e.details,
      );
  @override
  Widget build(BuildContext context) {
    final debModel = ref.watch(debModelProvider(widget.id));
    return debModel.state.when(
      data: (_) => ResponsiveLayoutBuilder(
        builder: (context) => _DebView(
          debModel: debModel,
        ),
      ),
      error: (error, stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(debModelProvider(widget.id)),
      ),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _DebView extends StatelessWidget {
  const _DebView({required this.debModel});

  final DebModel debModel;

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveLayout.of(context);
    final l10n = AppLocalizations.of(context);

    final debInfos = <AppInfo>[
      (
        label: l10n.snapPageVersionLabel,
        value: Text(debModel.packageInfo?.packageId.version ?? '')
      ),
      if (debModel.component.urls.isNotEmpty)
        (
          label: l10n.snapPageLinksLabel,
          value: Column(
            children: debModel.component.urls
                .where(
                  (url) => [
                    AppstreamUrlType.contact,
                    AppstreamUrlType.homepage,
                  ].contains(url.type),
                )
                .map(
                  (url) => Html(
                    data: '<a href="${url.url}">${url.type.localize(l10n)}</a>',
                    style: {'body': Style(margin: Margins.zero)},
                    onLinkTap: (url, attributes, element) =>
                        launchUrlString(url!),
                  ),
                )
                .toList(),
          ),
        ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kPagePadding),
      child: Column(
        children: [
          SizedBox(
            width: layout.totalWidth,
            child: _Header(debModel: debModel),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: layout.totalWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppInfoBar(appInfos: debInfos, layout: layout),
                      if (debModel.component.screenshotUrls.isNotEmpty)
                        AppPageSection(
                          header: Text(l10n.snapPageGalleryLabel),
                          child: ScreenshotGallery(
                            title: debModel.component.getLocalizedName(),
                            urls: debModel.component.screenshotUrls,
                            height: layout.totalWidth / 2,
                          ),
                        ),
                      AppPageSection(
                        header: Text(l10n.snapPageDescriptionLabel),
                        child: Html(
                          data: debModel.component.getLocalizedDescription(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DebActionButtons extends ConsumerWidget {
  const _DebActionButtons({required this.debModel});

  final DebModel debModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final primaryAction =
        debModel.isInstalled ? DebAction.remove : DebAction.install;
    final primaryActionButton = SizedBox(
      width: kPrimaryButtonMaxWidth,
      child: PushButton.elevated(
        onPressed: debModel.activeTransactionId != null
            ? null
            : primaryAction.callback(debModel),
        child: debModel.activeTransactionId != null
            ? Consumer(
                builder: (context, ref, child) {
                  final transaction = ref
                      .watch(transactionProvider(debModel.activeTransactionId!))
                      .valueOrNull;
                  return Center(
                    child: SizedBox.square(
                      dimension: kCircularProgressIndicatorHeight,
                      child: YaruCircularProgressIndicator(
                        value: (transaction?.percentage ?? 0) / 100.0,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              )
            : Text(primaryAction.label(l10n)),
      ),
    );

    final cancelButton = OutlinedButton(
      onPressed: DebAction.cancel.callback(debModel),
      child: Text(DebAction.cancel.label(l10n)),
    );

    return OverflowBar(
      overflowSpacing: 8,
      children: [
        if (debModel.packageInfo != null)
          primaryActionButton
        else
          Text(l10n.debPageErrorNoPackageInfo),
        if (debModel.activeTransactionId != null) cancelButton,
      ].whereNotNull().toList(),
    );
  }
}

enum DebAction {
  cancel,
  install,
  remove;

  String label(AppLocalizations l10n) => switch (this) {
        cancel => l10n.snapActionCancelLabel,
        install => l10n.snapActionInstallLabel,
        remove => l10n.snapActionRemoveLabel,
      };

  IconData? get icon => switch (this) {
        remove => YaruIcons.trash,
        _ => null,
      };

  VoidCallback? callback(DebModel model) => switch (this) {
        cancel => model.cancel,
        install => model.install,
        remove => model.remove,
      };
}

class _Header extends StatelessWidget {
  const _Header({required this.debModel});

  final DebModel debModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: kPagePadding),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIcon(iconUrl: debModel.component.icon, size: 96),
            const SizedBox(width: 16),
            Expanded(child: AppTitle.fromDeb(debModel.component)),
            if (debModel.component.website != null)
              YaruIconButton(
                icon: const Icon(YaruIcons.share),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: debModel.component.website!),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: kPagePadding),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: _DebActionButtons(debModel: debModel),
        ),
        const SizedBox(height: 42),
        const Divider(),
      ],
    );
  }
}
