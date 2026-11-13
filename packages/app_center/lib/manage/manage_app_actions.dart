import 'dart:async';

import 'package:app_center/constants.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/app_providers.dart';
import 'package:app_center/manage/local_deb_providers.dart';
import 'package:app_center/manage/local_deb_updates_model.dart';
import 'package:app_center/manage/manage_app_data.dart';
import 'package:app_center/manage/quit_to_update_notice.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:app_center/packagekit/packagekit_remove_dialog.dart';
import 'package:app_center/providers/current_desktops_provider.dart';
import 'package:app_center/providers/uninstall_check_provider.dart';
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
      snap: (snapData) => _SnapAppActions(
        snap: snapData.snap,
        showOnlyUpdate: showOnlyUpdate,
        appName: app.name,
      ),
      localDeb: (debData) => _buildDebActions(
        context,
        ref,
        l10n,
        debData.debInfo,
        debData.debInfo.isCompulsoryFor(ref.watch(currentDesktopsProvider)),
      ),
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
    bool isCompulsory,
  ) {
    final hasActiveTransaction = debInfo.activeTransactionId != null;

    if (hasActiveTransaction) {
      final progress = ref.watch(
        packageKitTransactionProgressProvider(debInfo.activeTransactionId),
      );
      final statusLabel = showOnlyUpdate
          ? l10n.snapActionUpdatingLabel
          : l10n.snapActionRemovingLabel;
      void cancelCallback() {
        if (showOnlyUpdate) {
          ref
              .read(localDebUpdatesModelProvider.notifier)
              .cancelTransaction(debInfo.id);
        } else {
          ref
              .read(installedAppsProvider.notifier)
              .cancelDebTransaction(debInfo.id);
        }
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: SizedBox.square(
              dimension: kLoaderHeight,
              child: YaruCircularProgressIndicator(
                value: progress,
                strokeWidth: 2,
              ),
            ),
          ),
          const SizedBox(width: kSpacingSmall),
          ExcludeSemantics(
            child: Text(
              statusLabel,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: kSpacing),
          _AccessibleActionButton(
            label: l10n.snapActionCancelLabel,
            semanticLabel: l10n.managePageCancelActionSemanticLabel(
              statusLabel,
              app.name,
            ),
            onPressed: cancelCallback,
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showOnlyUpdate)
          _AccessibleActionButton(
            label: l10n.snapActionUpdateLabel,
            semanticLabel: l10n.managePageUpdateAppSemanticLabel(app.name),
            onPressed: () => ref
                .read(localDebUpdatesModelProvider.notifier)
                .updateDeb(debInfo.id),
          ),
        if (!showOnlyUpdate && !isCompulsory)
          _AccessibleActionButton(
            label: l10n.snapActionRemoveLabel,
            semanticLabel: l10n.managePageRemoveAppSemanticLabel(app.name),
            onPressed: ref.watch(uninstallCheckProvider)
                ? null
                : () => unawaited(_removeDeb(context, ref, debInfo)),
          ),
      ],
    );
  }

  Future<void> _removeDeb(
    BuildContext context,
    WidgetRef ref,
    LocalDebInfo debInfo,
  ) async {
    final notifier = ref.read(installedAppsProvider.notifier);
    final confirmed = await confirmPackageKitRemoval(
      context,
      appName: app.name,
      packageIds: [debInfo.packageInfo.packageId],
    );
    if (confirmed) await notifier.removeDeb(debInfo.id);
  }
}

/// Snap action buttons for a manage page tile.
///
/// Display decisions use the [Snap] data directly plus the lightweight
/// [snapActiveChangeProvider], so no per-tile [SnapModel] is built eagerly:
/// rendering a tile costs one `getChanges` seed lookup instead of a full model
/// build (`getSnap` + store lookup + `getChanges` + `hasPreviousRevision`).
/// The [SnapModel] is only built (awaited) when an action is actually invoked,
/// keeping the tile cheap while actions stay correct.
class _SnapAppActions extends ConsumerStatefulWidget {
  const _SnapAppActions({
    required this.snap,
    required this.showOnlyUpdate,
    required this.appName,
  });

  final Snap snap;
  final bool showOnlyUpdate;
  final String appName;

  @override
  ConsumerState<_SnapAppActions> createState() => _SnapAppActionsState();
}

class _SnapAppActionsState extends ConsumerState<_SnapAppActions> {
  /// Guards against double-taps in the gap between pressing a button and the
  /// active change becoming visible.
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final snap = widget.snap;

    // Lightweight active-change lookup: covers changes started from this tile
    // as well as changes already in progress (e.g. when the app launched).
    final activeChangeId = ref.watch(snapActiveChangeProvider(snap.name));
    if (activeChangeId != null) {
      final activeChange = ref.watch(activeChangeProvider(activeChangeId));
      // A seeded change may already be done by the time we subscribe to it.
      if (activeChange?.ready != true) {
        return ActiveChangeStatus(
          actionLabel: activeChange?.localize(l10n),
          progress:
              ref.watch(snapChangeProgressProvider(activeChangeId)) ?? 0,
          onCancelPressed: _busy ? null : _cancelActiveChange,
          appName: widget.appName,
        );
      }
    }

    final shouldQuitToUpdate = snap.refreshInhibit != null;
    // launchProvider only wraps the Snap, so watching it stays cheap, and
    // SnapLauncher.isLaunchable keeps the full launchability check.
    final launcher = ref.watch(launchProvider(snap));
    final canOpen = launcher.isLaunchable;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (shouldQuitToUpdate) ...[
          const ExcludeSemantics(child: QuitToUpdateNotice()),
          const SizedBox(width: kSpacing),
        ],
        if (widget.showOnlyUpdate)
          _AccessibleActionButton(
            label: SnapAction.update.label(l10n),
            semanticLabel: shouldQuitToUpdate
                ? l10n.managePageUpdateAppRestartRequiredSemanticLabel(
                    widget.appName,
                  )
                : l10n.managePageUpdateAppSemanticLabel(widget.appName),
            onPressed: _busy ? null : () => _performAction(SnapAction.update),
          ),
        // Tiles in the installed section always carry the local snap, so the
        // snap is installed by construction; _performAction re-checks
        // isInstalled against the loaded model before acting.
        if (!widget.showOnlyUpdate) ...[
          if (canOpen) ...[
            _AccessibleActionButton(
              label: SnapAction.open.label(l10n),
              semanticLabel: l10n.managePageOpenAppSemanticLabel(
                widget.appName,
              ),
              onPressed: launcher.open,
            ),
            const SizedBox(width: kSpacing),
          ],
          _AccessibleActionButton(
            label: SnapAction.remove.label(l10n),
            semanticLabel: l10n.managePageRemoveAppSemanticLabel(
              widget.appName,
            ),
            onPressed: _busy ? null : () => _performAction(SnapAction.remove),
          ),
        ],
      ],
    );
  }

  /// Runs [action] against the snap's [SnapModel], building it first if needed.
  ///
  /// The model is awaited before invoking the action (actions assert on loaded
  /// state), and [SnapAction.callback] stays the single source of truth for
  /// the isInstalled/storeSnap guards once the model is loaded.
  Future<void> _performAction(SnapAction action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final snapName = widget.snap.name;
      late final SnapData data;
      try {
        data = await ref.read(snapModelProvider(snapName).future);
      } on Object catch (_) {
        // The model failed to build (e.g. the snap is gone): nothing to do.
        return;
      }
      if (!mounted) return;
      final model = ref.read(snapModelProvider(snapName).notifier);
      if (action == SnapAction.remove && !data.isInstalled) return;
      if (action.callback(data, model, null, context) == null) return;
      switch (action) {
        case SnapAction.update:
          await model.refresh();
        case SnapAction.remove:
          await model.remove();
        case _:
          return;
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Aborts the active change, building the [SnapModel] first if needed so
  /// that [SnapModel.cancel] sees the in-progress change id.
  Future<void> _cancelActiveChange() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final snapName = widget.snap.name;
      await ref.read(snapModelProvider(snapName).future);
      if (!mounted) return;
      await ref.read(snapModelProvider(snapName).notifier).cancel();
    } on Object catch (_) {
      // The model failed to build or there is nothing to abort.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// An [OutlinedButton] whose accessible name is overridden by
/// [semanticLabel] (e.g. to include the app name it acts on), while
/// preserving the button's tap action for assistive technologies.
class _AccessibleActionButton extends StatelessWidget {
  const _AccessibleActionButton({
    required this.label,
    required this.semanticLabel,
    required this.onPressed,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        label: semanticLabel,
        child: YaruFocusBorder.primary(
          child: OutlinedButton(
            onPressed: onPressed,
            style: kSuppressFocusOverlay,
            child: ExcludeSemantics(
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
