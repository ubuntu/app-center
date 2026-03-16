import 'package:app_center/constants.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/quit_to_update_notice.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/widgets/active_change_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

class ManageAppActions extends ConsumerWidget {
  const ManageAppActions({
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
          OutlinedButton(
            onPressed: SnapAction.remove.callback(
              snapData,
              snapViewModel,
              snapLauncher,
              context,
            ),
            child: Text(SnapAction.remove.label(l10n)),
          ),
        ],
      ],
    );
  }
}
