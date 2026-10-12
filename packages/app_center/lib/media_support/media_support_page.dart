import 'package:app_center/error/error.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/media_support/media_support_model.dart';
import 'package:app_center/packagekit/packagekit_transaction_progress_provider.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

class MediaSupportPage extends ConsumerWidget {
  const MediaSupportPage({super.key});

  static String label(BuildContext context) =>
      AppLocalizations.of(context).addonsPageMediaSupportTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mediaSupport = ref.watch(mediaSupportModelProvider);
    return ResponsiveLayoutScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(kPagePadding),
          sliver: SliverList.list(
            children: [
              Text(l10n.mediaSupportPageDescription),
              const SizedBox(height: kPagePadding),
              mediaSupport.when(
                loading: () =>
                    const Center(child: YaruCircularProgressIndicator()),
                error: (error, _) => ErrorView(
                  error: error,
                  onRetry: () => ref.invalidate(mediaSupportModelProvider),
                ),
                data: (data) => YaruBorderContainer(
                  child: YaruListTile(
                    title: Text(l10n.mediaSupportPageAdditionalMediaTitle),
                    subtitle: data.size == null
                        ? null
                        : Text(context.formatByteSize(data.size!)),
                    trailing: _MediaSupportActions(data: data),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MediaSupportActions extends ConsumerWidget {
  const _MediaSupportActions({required this.data});

  final MediaSupportState data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final model = ref.read(mediaSupportModelProvider.notifier);

    if (data.activeAction != null) {
      final progress = ref.watch(
        packageKitTransactionProgressProvider(data.activeTransactionId),
      );
      return ActiveChangeStatus(
        actionLabel: switch (data.activeAction) {
          MediaSupportAction.install => l10n.snapActionInstallingLabel,
          MediaSupportAction.update => l10n.snapActionUpdatingLabel,
          MediaSupportAction.uninstall => l10n.snapActionRemovingLabel,
          null => l10n.snapActionInstallingLabel,
        },
        progress: progress ?? 0,
        onCancelPressed: data.activeTransactionId == null ? null : model.cancel,
      );
    }

    if (data.hasError) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            YaruIcons.error,
            color: Theme.of(context).colorScheme.error,
            size: 16,
          ),
          const SizedBox(width: kSpacingSmall),
          Text(l10n.driversPageErrorLabel),
          const SizedBox(width: kSpacing),
          OutlinedButton(
            onPressed: model.retry,
            child: Text(l10n.driversPageRetryLabel),
          ),
        ],
      );
    }

    if (!data.isInstalled) {
      return OutlinedButton(
        onPressed: model.install,
        child: Text(l10n.mediaSupportPageInstallButton),
      );
    }
    if (data.updatePackageIds.isNotEmpty) {
      return OutlinedButton(
        onPressed: model.updatePackages,
        child: Text(l10n.snapActionUpdateLabel),
      );
    }
    return OutlinedButton(
      onPressed: model.uninstall,
      child: Text(l10n.snapActionRemoveLabel),
    );
  }
}
