import 'dart:async';

import 'package:app_center/apps/app_page.dart';
import 'package:app_center/apps/app_title_bar.dart';
import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/deb/deb_model.dart';
import 'package:app_center/deb/deb_providers.dart';
import 'package:app_center/error/error.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:app_center/providers/current_desktops_provider.dart';
import 'package:app_center/store/store_app.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

class DebPage extends ConsumerWidget {
  const DebPage({required this.id, super.key});

  final String id;

  Future<void> showError(BuildContext context, PackageKitServiceError e) =>
      showErrorDialog(
        context: context,
        title: 'PackageKit error: ${e.code}',
        message: e.details,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debModel = ref.watch(debModelProvider(id));

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => debModel.whenOrNull(
        data: (data) {
          if (data.error == null) return;
          showError(context, data.error!);
        },
      ),
    );

    return debModel.when(
      data: (data) => ResponsiveLayoutBuilder(
        builder: (context) => _DebView(
          debModel: data,
        ),
      ),
      error: (error, stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(debModelProvider(id)),
      ),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _DebView extends ConsumerWidget {
  const _DebView({required this.debModel});

  final DebData debModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ResponsiveLayout.of(context);
    final l10n = AppLocalizations.of(context);

    return AppPage(
      titleBar: AppTitleBar.fromDeb(
        debModel,
        actions: debModel.component.website != null
            ? YaruIconButton(
                icon: Icon(
                  YaruIcons.share,
                  semanticLabel: l10n.debPageShareSemanticLabel,
                ),
                onPressed: () {
                  final navigationKey =
                      ref.watch(materialAppNavigatorKeyProvider);

                  ScaffoldMessenger.of(navigationKey.currentContext!)
                      .showSnackBar(
                    SnackBar(
                      content: Text(l10n.snapPageShareLinkCopiedMessage),
                    ),
                  );
                  Clipboard.setData(
                    ClipboardData(text: debModel.component.website!),
                  );
                },
              )
            : null,
      ),
      actionBar: Wrap(
        runSpacing: kSpacing,
        spacing: kSpacing,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _DebActionButtons(debModel: debModel),
          _MoreActionsButton(debData: debModel),
        ],
      ),
      infoBar: DebInfoBar(debData: debModel),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (debModel.component.screenshotUrls.isNotEmpty) ...[
            ScreenshotGallery(
              title: debModel.component.getLocalizedName(),
              urls: debModel.component.screenshotUrls,
              height: layout.totalWidth / 2,
            ),
            const SizedBox(height: kSectionSpacing),
          ],
          Text(
            debModel.component.getLocalizedSummary(),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: kPagePadding),
          Html(
            data: debModel.component.getLocalizedDescription(),
            style: {
              'body': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
            },
          ),
        ],
      ),
    );
  }
}

class _DebActionButtons extends ConsumerWidget {
  const _DebActionButtons({required this.debModel});

  final DebData debModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentDesktops = ref.watch(currentDesktopsProvider);
    final isCompulsory = debModel.isCompulsoryFor(currentDesktops);

    final primaryAction = debModel.hasUpdate
        ? DebAction.update
        : debModel.isInstalled
            ? (isCompulsory ? null : DebAction.remove)
            : DebAction.install;
    final button = switch (primaryAction) {
      DebAction.install || DebAction.update => YaruSplitButton.new,
      _ => YaruSplitButton.outlined,
    };

    final primaryActionButton = primaryAction == null
        ? null
        : button(
            onPressed: primaryAction.callback(ref, debModel),
            child: Text(primaryAction.label(l10n)),
          );

    if (debModel.activeTransactionId != null) {
      return ActiveChangeStatus(
        onCancelPressed: DebAction.cancel.callback(ref, debModel),
        progress: (ref
                    .watch(transactionProvider(debModel.activeTransactionId!))
                    .valueOrNull
                    ?.percentage ??
                0) /
            100.0,
      );
    }

    return OverflowBar(
      overflowSpacing: 8,
      children: [
        if (debModel.packageInfo != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (primaryActionButton != null) primaryActionButton,
            ],
          )
        else
          Text(l10n.debPageErrorNoPackageInfo),
      ].nonNulls.toList(),
    );
  }
}

class _MoreActionsButton extends ConsumerWidget {
  const _MoreActionsButton({required this.debData});

  final DebData debData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentDesktops = ref.watch(currentDesktopsProvider);
    final isCompulsory = debData.isCompulsoryFor(currentDesktops);

    final primaryAction = debData.hasUpdate
        ? DebAction.update
        : debData.isInstalled
            ? (isCompulsory ? null : DebAction.remove)
            : DebAction.install;

    final secondaryActions = [
      if (debData.hasUpdate) DebAction.update,
      if (!isCompulsory && (debData.isInstalled || debData.hasUpdate))
        DebAction.remove,
    ]..remove(primaryAction);

    return secondaryActions.isNotEmpty
        ? YaruPopupMenuButton(
            showArrow: false,
            semanticLabel: l10n.appMoreActionsSemanticLabel,
            childPadding: EdgeInsets.symmetric(horizontal: 2),
            itemBuilder: (context) => [
              ...secondaryActions.map((action) {
                final color = action == DebAction.remove
                    ? Theme.of(context).colorScheme.error
                    : null;
                return PopupMenuItem(
                  onTap: action.callback(
                    ref,
                    debData,
                  ),
                  child: IntrinsicWidth(
                    child: ListTile(
                      mouseCursor: SystemMouseCursors.click,
                      title: Text(
                        action.label(l10n),
                        style: TextStyle(color: color),
                      ),
                    ),
                  ),
                );
              }),
            ],
            onSelected: (value) => {},
            child: Icon(YaruIcons.view_more),
          )
        : SizedBox.shrink();
  }
}

enum DebAction {
  cancel,
  install,
  update,
  remove;

  String label(AppLocalizations l10n) => switch (this) {
        cancel => l10n.snapActionCancelLabel,
        install => l10n.snapActionInstallLabel,
        update => l10n.snapActionUpdateLabel,
        remove => l10n.snapActionRemoveLabel,
      };

  IconData? get icon => switch (this) {
        remove => YaruIcons.trash,
        _ => null,
      };

  VoidCallback? callback(WidgetRef ref, DebData data) {
    final provider = ref.read(debModelProvider(data.id).notifier);
    return switch (this) {
      cancel => provider.cancelTransaction,
      install => provider.installDeb,
      update => provider.updateDeb,
      remove => provider.removeDeb,
    };
  }
}
