import 'package:app_center/constants.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/quit_to_update_notice.dart';
import 'package:app_center/manage/snap_updates_provider.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/widgets/active_change_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

class ManageSnapActions extends ConsumerWidget {
  const ManageSnapActions({
    required this.snapName,
    this.showOnlyUpdate = false,
    super.key,
  });

  final String snapName;
  final bool showOnlyUpdate;

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
    final hasUpdate = ref.watch(snapHasUpdateProvider(snap.name));

    final primaryAction = switch ((hasUpdate && !shouldQuitToUpdate, canOpen)) {
      (true, _) => SnapAction.update,
      (_, true) => SnapAction.open,
      _ => null,
    };

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
        if (primaryAction != null)
          OutlinedButton(
            onPressed: primaryAction.callback(
              snapData,
              snapViewModel,
              snapLauncher,
              context,
            ),
            child: Text(primaryAction.label(l10n)),
          ),
        if (!showOnlyUpdate && snapData.isInstalled) ...[
          if (primaryAction != null) const SizedBox(width: kSpacing),
          OutlinedButton(
            onPressed: SnapAction.remove.callback(
              snapData,
              snapViewModel,
              snapLauncher,
              context,
            ),
            child: Text(
              SnapAction.remove.label(l10n),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ],
    );
  }
}
