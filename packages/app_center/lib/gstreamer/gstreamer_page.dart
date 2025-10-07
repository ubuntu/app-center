import 'package:app_center/constants.dart';
import 'package:app_center/deb/deb_providers.dart';
import 'package:app_center/extensions/iterable_extensions.dart';
import 'package:app_center/gstreamer/gstreamer.dart';
import 'package:app_center/gstreamer/gstreamer_model.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

class GStreamerPage extends ConsumerWidget {
  const GStreamerPage({required this.resources, super.key});

  final List<GstResource> resources;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return ResponsiveLayoutBuilder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: kPagePadding) +
            ResponsiveLayout.of(context).padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: kPagePadding),
            Semantics(
              focused: true,
              header: true,
              child: Text(
                l10n.codecPageTitle,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: kPagePadding),
            Text(l10n.codecPageDescription),
            const SizedBox(height: kPagePadding),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: resources
                    .map(
                      (r) => Row(
                        children: [
                          Text('\u2022'),
                          SizedBox(width: kSpacingSmall),
                          Text(r.name),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: kPagePadding),
            Text(l10n.codecProprietaryDisclaimer),
            const SizedBox(height: kPagePadding),
            _GstreamerActions(resources: resources),
          ],
        ),
      ),
    );
  }
}

class _GstreamerActions extends ConsumerWidget {
  const _GstreamerActions({required this.resources});

  final List<GstResource> resources;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final gstreamer = ref.watch(gstreamerModelProvider(resources));

    return gstreamer.when(
      data: (data) => _GStreamerActionButton(resources: resources, data: data),
      error: (error, stackTrace) => Text(error.toString()),
      loading: () => YaruSplitButton(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Visibility(
              visible: false,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: Text(l10n.codecInstallAllButton),
            ),
            Center(
              child: SizedBox(
                height: kLoaderHeight,
                child: YaruCircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GStreamerActionButton extends ConsumerWidget {
  const _GStreamerActionButton({
    required this.resources,
    required this.data,
  });

  final List<GstResource> resources;
  final GStreamerData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (data.canInstall) {
      return YaruSplitButton(
        onPressed: data.canInstall
            ? () => ref
                .read(gstreamerModelProvider(resources).notifier)
                .installAll()
            : null,
        child: Text(l10n.codecInstallAllButton),
      );
    }

    if (data.canCancel) {
      return Row(
        children: [
          _TransactionSpinner(activeTransactionId: data.activeTransactionId!),
          YaruSplitButton.outlined(
            onPressed: data.canCancel
                ? () => ref
                    .read(gstreamerModelProvider(resources).notifier)
                    .cancel()
                : null,
            child: Text(l10n.snapActionCancelLabel),
          ),
        ].separatedBy(const SizedBox(width: kSpacing)),
      );
    }

    return YaruSplitButton.outlined(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check),
          Text(l10n.snapActionInstalledLabel),
        ].separatedBy(const SizedBox(width: kSpacingSmall)),
      ),
    );
  }
}

class _TransactionSpinner extends ConsumerWidget {
  const _TransactionSpinner({required this.activeTransactionId});

  final int activeTransactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final transaction =
        ref.watch(transactionProvider(activeTransactionId)).valueOrNull;

    return Row(
      children: [
        SizedBox.square(
          dimension: kLoaderHeight,
          child: YaruCircularProgressIndicator(
            value: (transaction?.percentage ?? 0) / 100.0,
            strokeWidth: 2,
          ),
        ),
        const SizedBox(width: kSpacingSmall),
        Text(
          l10n.snapActionInstallingLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
