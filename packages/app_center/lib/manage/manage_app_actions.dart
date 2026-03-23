import 'package:app_center/constants.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/app_providers.dart';
import 'package:app_center/manage/local_deb_providers.dart';
import 'package:app_center/manage/local_deb_updates_model.dart';
import 'package:app_center/manage/manage_app_data.dart';
import 'package:app_center/manage/quit_to_update_notice.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/widgets/active_change_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru/yaru.dart';

/// Renders the action buttons (open, update, remove, cancel) for a manage page
/// tile. Dispatches to snap- or deb-specific layouts based on the [app] type.
///
/// When [showOnlyUpdate] is true, only the update button is shown (used in the
/// updates section). Otherwise the full set of actions is displayed (used in the
/// installed section).
class ManageAppActions extends ConsumerWidget {
  const ManageAppActions({
    required this.app,
    this.showOnlyUpdate = false,
    super.key,
  });

  final ManageAppData app;
  final bool showOnlyUpdate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return app.map(
      snap: (snapData) => _buildSnapActions(
        context,
        ref,
        l10n,
        snapData.snap,
        snapData.updateVersion,
      ),
      localDeb: (debData) =>
          _buildDebActions(context, ref, l10n, debData.debInfo),
    );
  }

  /// Builds snap action buttons using the per-snap [SnapModel]. Shows a loading
  /// indicator while the snap model loads, an active change status when a snapd
  /// operation is in progress, or the appropriate action buttons (update, open,
  /// remove) otherwise.
  Widget _buildSnapActions(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Snap snap,
    String? updateVersion,
  ) {
    final snapModel = ref.watch(snapModelProvider(snap.name));
    if (!snapModel.hasValue) {
      return const Center(
        child: SizedBox.square(
          dimension: kLoaderMediumHeight,
          child: YaruCircularProgressIndicator(),
        ),
      );
    }
    final snapData = snapModel.value!;
    final shouldQuitToUpdate = snapData.localSnap?.refreshInhibit != null;
    final snapViewModel = ref.watch(snapModelProvider(snap.name).notifier);
    final snapLauncher = snapData.localSnap == null
        ? null
        : ref.watch(launchProvider(snapData.localSnap!));
    final canOpen = snapLauncher?.isLaunchable ?? false;
    final hasActiveChange = snapData.activeChangeId != null;
    if (hasActiveChange) {
      return ActiveChangeStatus(
        snapName: snap.name,
        activeChangeId: snapData.activeChangeId!,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (shouldQuitToUpdate) ...[
          const QuitToUpdateNotice(),
          const SizedBox(width: kSpacing),
        ],
        if (showOnlyUpdate)
          OutlinedButton(
            onPressed: SnapAction.update.callback(
              snapData,
              snapViewModel,
              snapLauncher,
              context,
            ),
            child: Text(SnapAction.update.label(l10n)),
          ),
        if (!showOnlyUpdate && snapData.isInstalled) ...[
          OutlinedButton(
            onPressed: canOpen
                ? SnapAction.open.callback(
                    snapData,
                    snapViewModel,
                    snapLauncher,
                    context,
                  )
                : null,
            child: Text(SnapAction.open.label(l10n)),
          ),
          const SizedBox(width: kSpacing),
          MenuAnchor(
            menuChildren: [
              MenuItemButton(
                onPressed: SnapAction.remove.callback(
                  snapData,
                  snapViewModel,
                  snapLauncher,
                  context,
                ),
                child: Text(SnapAction.remove.label(l10n)),
              ),
              MenuItemButton(
                onPressed: SnapAction.removePurge.callback(
                  snapData,
                  snapViewModel,
                  snapLauncher,
                  context,
                ),
                child: Text(SnapAction.removePurge.label(l10n)),
              ),
            ],
            builder: (context, controller, child) => OutlinedButton.icon(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              icon: const Icon(Icons.arrow_drop_down, size: 18),
              iconAlignment: IconAlignment.end,
              label: Text(SnapAction.remove.label(l10n)),
            ),
          ),
        ],
      ],
    );
  }

  /// Builds deb action buttons. Shows a progress indicator with a cancel button
  /// when a PackageKit transaction is active, or update/remove buttons otherwise.
  ///
  /// Cancel and update/remove are routed to [LocalDebUpdatesModel] (updates section)
  /// or [InstalledApps] (installed section) depending on [showOnlyUpdate].
  Widget _buildDebActions(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    LocalDebInfo debInfo,
  ) {
    final hasActiveTransaction = debInfo.activeTransactionId != null;

    if (hasActiveTransaction) {
      final progress = ref
          .watch(debTransactionProgressProvider(debInfo.activeTransactionId));
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: kLoaderHeight,
            child: YaruCircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: kSpacingSmall),
          Text(
            showOnlyUpdate
                ? l10n.snapActionUpdatingLabel
                : l10n.snapActionRemovingLabel,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: kSpacing),
          OutlinedButton(
            onPressed: () => showOnlyUpdate
                ? ref
                    .read(localDebUpdatesModelProvider.notifier)
                    .cancelTransaction(debInfo.id)
                : ref
                    .read(installedAppsProvider.notifier)
                    .cancelDebTransaction(debInfo.id),
            child: Text(l10n.snapActionCancelLabel),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showOnlyUpdate)
          OutlinedButton(
            onPressed: () => ref
                .read(localDebUpdatesModelProvider.notifier)
                .updateDeb(debInfo.id),
            child: Text(l10n.snapActionUpdateLabel),
          ),
        if (!showOnlyUpdate)
          OutlinedButton(
            onPressed: () =>
                ref.read(installedAppsProvider.notifier).removeDeb(debInfo.id),
            child: Text(l10n.snapActionRemoveLabel),
          ),
      ],
    );
  }
}
