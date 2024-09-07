import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/manage_l10n.dart';
import 'package:app_center/snapd/snap_action.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/src/l10n/app_localizations.g.dart';
import 'package:app_center/store/store.dart';
import 'package:app_center/widgets/snap_menu_item.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru/yaru.dart';

enum ManageTilePosition { first, middle, last, single }

class ManageSnapTile extends StatelessWidget {
  const ManageSnapTile({
    required this.snap,
    this.position = ManageTilePosition.middle,
    this.showUpdateButton = false,
    super.key,
  });

  final Snap snap;
  final ManageTilePosition position;
  final bool showUpdateButton;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final border = BorderSide(color: Theme.of(context).colorScheme.outline);
    final dateTimeSinceUpdate = snap.installDate != null
        ? DateTime.now().difference(snap.installDate!)
        : null;
    const radius = Radius.circular(8);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: switch (position) {
          ManageTilePosition.first =>
            const BorderRadius.only(topLeft: radius, topRight: radius),
          ManageTilePosition.middle => BorderRadius.zero,
          ManageTilePosition.last =>
            const BorderRadius.only(bottomLeft: radius, bottomRight: radius),
          ManageTilePosition.single => const BorderRadius.all(radius),
        },
        border: switch (position) {
          ManageTilePosition.first => Border(
              top: border,
              left: border,
              right: border,
              bottom: border,
            ),
          ManageTilePosition.middle => Border(
              left: border,
              right: border,
              bottom: border,
            ),
          ManageTilePosition.last => Border(
              bottom: border,
              left: border,
              right: border,
            ),
          ManageTilePosition.single => Border.fromBorderSide(border),
        },
      ),
      child: ListTile(
        key: ValueKey(snap.id),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Clickable(
          onTap: () => StoreNavigator.pushSnap(context, name: snap.name),
          child: AppIcon(iconUrl: snap.iconUrl, size: 40),
        ),
        title: Row(
          children: [
            Expanded(
              flex: 2,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Clickable(
                  onTap: () =>
                      StoreNavigator.pushSnap(context, name: snap.name),
                  child: Text(
                    snap.titleOrName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            ),
            if (ResponsiveLayout.of(context).type !=
                ResponsiveLayoutType.small) ...[
              Expanded(
                flex: 2,
                child: dateTimeSinceUpdate != null
                    ? Text(
                        dateTimeSinceUpdate
                            .managePageUpdateSinceDateTimeAgo(l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      )
                    : const SizedBox(),
              ),
              Expanded(
                child: snap.installedSize != null
                    ? Text(
                        context.formatByteSize(
                          snap.installedSize!,
                          precision: 0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      )
                    : const SizedBox(),
              ),
              const Spacer(),
            ],
          ],
        ),
        subtitle: Column(
          children: [
            Row(
              children: [
                Text(snap.channel),
                const SizedBox(width: 4),
                Text(snap.version),
              ],
            ),
            if (ResponsiveLayout.of(context).type == ResponsiveLayoutType.small)
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: dateTimeSinceUpdate != null
                        ? Text(
                            dateTimeSinceUpdate
                                .managePageUpdateSinceDateTimeAgo(l10n),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : const SizedBox(),
                  ),
                  Expanded(
                    child: snap.installedSize != null
                        ? Text(
                            context.formatByteSize(
                              snap.installedSize!,
                              precision: 0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          )
                        : const SizedBox(),
                  ),
                  const Spacer(),
                ],
              ),
          ],
        ),
        trailing: _ButtonBar(snap, showUpdateButton),
      ),
    );
  }
}

ManageTilePosition determineTilePosition({
  required int index,
  required int length,
}) {
  if (length == 1) {
    return ManageTilePosition.single;
  }

  if (index == length - 1) {
    return ManageTilePosition.last;
  }

  if (index == 0) {
    return ManageTilePosition.first;
  } else {
    return ManageTilePosition.middle;
  }
}

class _ButtonBar extends ConsumerWidget {
  const _ButtonBar(this.snap, this.showUpdateButton);

  final Snap snap;
  final bool showUpdateButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snapLauncher = ref.watch(launchProvider(snap));
    final snapModel = ref.watch(snapModelProvider(snap.name));
    final activeChangeId = snapModel.valueOrNull?.activeChangeId;
    final removeColor = Theme.of(context).colorScheme.error;
    final initialWidgets = _initialWidgetOrder(
      snapModel: snapModel,
      snapLauncher: snapLauncher,
      l10n: l10n,
      activeChangeId: activeChangeId,
      showUpdateButton: showUpdateButton,
    );
    final primaryWidget = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 100),
      child: initialWidgets.firstOrNull ?? const SizedBox(),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        primaryWidget,
        const SizedBox(width: 16),
        MenuAnchor(
          menuChildren: [
            ...initialWidgets.skip(1),
            SnapMenuItem(
              onPressed: () =>
                  StoreNavigator.pushSnap(context, name: snap.name),
              title: l10n.managePageShowDetailsLabel,
            ),
            SnapMenuItem(
              onPressed: ref.read(snapModelProvider(snap.name).notifier).remove,
              title: SnapAction.remove.label(l10n),
              textStyle: TextStyle(color: removeColor),
            ),
          ],
          builder: (context, controller, child) => YaruOptionButton(
            onPressed: controller.isOpen ? controller.close : controller.open,
            child: const Icon(YaruIcons.view_more_horizontal),
          ),
        ),
      ],
    );
  }

  List<Widget> _initialWidgetOrder({
    required AsyncValue<SnapData> snapModel,
    required AppLocalizations l10n,
    required SnapLauncher snapLauncher,
    required bool showUpdateButton,
    required String? activeChangeId,
  }) {
    final hasActiveChange = activeChangeId != null;
    final canOpen = snapLauncher.isLaunchable;
    return [
      if (hasActiveChange)
        // TODO: Add cancel button!
        ActiveChangeContent(activeChangeId)
      else ...[
        if (showUpdateButton)
          _UpdateButton(snapModel: snapModel, activeChangeId: activeChangeId),
        if (!showUpdateButton && canOpen)
          OutlinedButton(
            onPressed: snapLauncher.open,
            child: Text(l10n.snapActionOpenLabel),
          ),
        if (showUpdateButton && canOpen)
          SnapMenuItem(
            onPressed: snapLauncher.open,
            title: l10n.snapActionOpenLabel,
          ),
      ],
    ];
  }
}

class _UpdateButton extends ConsumerWidget {
  const _UpdateButton({
    required this.snapModel,
    required this.activeChangeId,
  });

  final AsyncValue<SnapData> snapModel;
  final String? activeChangeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final shouldQuitToUpdate =
        snapModel.valueOrNull?.localSnap?.refreshInhibit != null;
    final snap =
        snapModel.valueOrNull?.localSnap ?? snapModel.valueOrNull?.storeSnap;

    if (shouldQuitToUpdate) {
      return const QuitToUpdateNotice();
    } else {
      return OutlinedButton(
        onPressed: activeChangeId != null || !snapModel.hasValue
            ? null
            : ref.read(snapModelProvider(snap!.name).notifier).refresh,
        child: activeChangeId != null
            ? ActiveChangeContent(activeChangeId!)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(YaruIcons.download),
                  const SizedBox(width: kSpacingSmall),
                  Text(
                    l10n.snapActionUpdateLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
      );
    }
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
