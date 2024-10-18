import 'package:app_center/constants.dart';
import 'package:app_center/extensions/iterable_extensions.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/updates_model.dart';
import 'package:app_center/snapd/snap_action.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/widgets/active_change_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

class SnapActionsButton extends ConsumerWidget {
  const SnapActionsButton({
    required this.snapName,
    required this.isPrimary,
    super.key,
  });

  final String snapName;
  final bool isPrimary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snapModel = ref.watch(snapModelProvider(snapName));
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
    final snap = snapData.snap;
    final snapViewModel = ref.watch(snapModelProvider(snap.name).notifier);
    final snapLauncher = snapData.localSnap == null
        ? null
        : ref.watch(launchProvider(snapData.localSnap!));
    final canOpen = snapLauncher?.isLaunchable ?? false;
    final hasActiveChange = snapData.activeChangeId != null;
    final hasUpdate = ref.watch(hasUpdateProvider(snap.name));

    final SnapAction? primaryAction;
    if (snapData.isInstalled) {
      final hasChangedChannel = snapData.selectedChannel != null &&
          snapData.localSnap!.trackingChannel != null &&
          snapData.selectedChannel != snapData.localSnap!.trackingChannel;

      if (hasChangedChannel) {
        primaryAction = SnapAction.switchChannel;
      } else if (!shouldQuitToUpdate && hasUpdate) {
        primaryAction = SnapAction.update;
      } else if (canOpen) {
        primaryAction = SnapAction.open;
      } else {
        primaryAction = null;
      }
    } else {
      primaryAction = SnapAction.install;
    }

    final secondaryActions = [
      if (canOpen) SnapAction.open,
      if (!shouldQuitToUpdate && hasUpdate) SnapAction.update,
      if (snapData.isInstalled) SnapAction.remove,
    ]..remove(primaryAction ?? SnapAction.open);

    final secondaryActionsWidgets = [
      ...secondaryActions.map((action) {
        final color = action == SnapAction.remove
            ? Theme.of(context).colorScheme.error
            : null;
        return PopupMenuItem(
          onTap: action.callback(snapData, snapViewModel, snapLauncher),
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
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasActiveChange)
          ActiveChangeStatus(
            snapName: snap.name,
            activeChangeId: snapData.activeChangeId!,
          )
        else ...[
          if (shouldQuitToUpdate) const QuitToUpdateNotice(),
          (isPrimary ? YaruSplitButton.new : YaruSplitButton.outlined.call)(
            items: [
              if (snapData.isInstalled && snapData.activeChangeId == null)
                ...secondaryActionsWidgets,
            ],
            onPressed: snapData.activeChangeId == null
                ? primaryAction?.callback(snapData, snapViewModel, snapLauncher)
                : null,
            child: Text(
              primaryAction?.label(l10n) ?? SnapAction.open.label(l10n),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ].separatedBy(const SizedBox(width: kSpacing)),
    );
  }
}

@visibleForTesting
class QuitToUpdateNotice extends StatelessWidget {
  const QuitToUpdateNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(YaruIcons.warning_filled, color: colorScheme.warning),
        const SizedBox(width: 8),
        Text(
          l10n.managePageQuitToUpdate,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
