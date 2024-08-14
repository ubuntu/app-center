import 'package:app_center/constants.dart';
import 'package:app_center/deb/local_deb_model.dart';
import 'package:app_center/error/error.dart';
import 'package:app_center/extensions/string_extensions.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:yaru/yaru.dart';

const localDebInfoUrl =
    'https://ubuntu.com/server/docs/third-party-repository-usage';

class LocalDebPage extends ConsumerWidget {
  const LocalDebPage({required this.path, super.key});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(localDebModelProvider(path: path));
    return model.when(
      data: (debData) => _LocalDebPage(debData: debData),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
      error: (error, stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(localDebModelProvider(path: path)),
      ),
    );
  }
}

class _LocalDebPage extends StatelessWidget {
  const _LocalDebPage({required this.debData});

  final LocalDebData debData;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppPage(
      appInfos: [
        (
          label: l10n.snapPageSizeLabel,
          value: Text(context.formatByteSize(debData.details.size))
        ),
        (
          label: l10n.snapPageLicenseLabel,
          value: Text(debData.details.license)
        ),
        (
          label: l10n.snapPageLinksLabel,
          value: Html(
            data: '<a href="${debData.details.url}">${debData.details.url}</a>',
            style: {'body': Style(margin: Margins.zero)},
            onLinkTap: (url, attributes, element) => launchUrlString(url!),
          )
        ),
      ],
      header: _Header(debData: debData),
      children: [_Description(debData: debData)],
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.debData});

  final LocalDebData debData;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).snapPageDescriptionLabel,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: kPagePadding),
        Text(
          debData.details.summary,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: kPagePadding),
        MarkdownBody(
          selectable: true,
          onTapLink: (text, href, title) => launchUrlString(href!),
          data: debData.details.description.escapedMarkdown(),
        ),
      ],
    );
  }
}

enum _Actions { install, cancel }

class _LocalDebActionButtons extends ConsumerWidget {
  const _LocalDebActionButtons({required this.debData});

  final LocalDebData debData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    Future<void> confirmInstallCallback() async {
      final userChoice = await showYaruInfoDialog(
        context: context,
        type: YaruInfoType.warning,
        actions: [
          DialogAction(
            value: _Actions.cancel,
            label: UbuntuLocalizations.of(context).cancelLabel,
          ),
          DialogAction(
            value: _Actions.install,
            label: l10n.snapActionInstallLabel,
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.localDebDialogMessage),
            const SizedBox(height: kPagePadding),
            Text(
              l10n.localDebDialogConfirmation,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
      if (userChoice == _Actions.install) {
        await ref
            .read(localDebModelProvider(path: debData.path).notifier)
            .install();
      }
    }

    final primaryActionButton = SizedBox(
      width: kPrimaryButtonMaxWidth,
      child: PushButton.elevated(
        onPressed: debData.activeTransactionId != null || debData.isInstalled
            ? null
            : confirmInstallCallback,
        child: debData.activeTransactionId != null
            ? Row(
                children: [
                  const SizedBox.square(
                    dimension: kCircularProgressIndicatorHeight,
                    child: YaruCircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Flexible(child: Text(l10n.snapActionInstallingLabel)),
                ],
              )
            : Text(
                debData.isInstalled
                    ? l10n.snapActionInstalledLabel
                    : l10n.snapActionInstallLabel,
              ),
      ),
    );

    final cancelButton = OutlinedButton(
      onPressed: debData.activeTransactionId != null
          ? ref.read(localDebModelProvider(path: debData.path).notifier).cancel
          : null,
      child: Text(l10n.snapActionCancelLabel),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        primaryActionButton,
        if (debData.activeTransactionId != null) ...[
          const SizedBox(width: 8),
          cancelButton,
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.debData});

  final LocalDebData debData;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTitle(
          title: debData.details.packageId.name,
          large: true,
          showPublisher: false,
        ),
        const SizedBox(height: kPagePadding),
        YaruInfoBox(
          title: Text(l10n.localDebWarningTitle),
          yaruInfoType: YaruInfoType.warning,
          child: Html(
            data:
                '${l10n.localDebWarningBody} <a href="$localDebInfoUrl">${l10n.localDebLearnMore}</a>',
            style: {'body': Style(margin: Margins.zero)},
            onLinkTap: (url, attributes, element) => launchUrlString(url!),
          ),
        ),
        const SizedBox(height: kPagePadding),
        _LocalDebActionButtons(debData: debData),
        const SizedBox(height: kPagePadding),
        const Divider(),
      ],
    );
  }
}
