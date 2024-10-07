import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/manage_l10n.dart';
import 'package:app_center/manage/update_button.dart';
import 'package:app_center/snapd/snap_action.dart';
import 'package:app_center/snapd/snapd.dart';
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
    this.hasFixedSize = false,
    super.key,
  });

  final Snap snap;
  final ManageTilePosition position;
  final bool showUpdateButton;
  final bool hasFixedSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final border = BorderSide(color: Theme.of(context).colorScheme.outline);
    final dateTimeSinceUpdate = snap.installDate != null
        ? DateTime.now().difference(snap.installDate!)
        : null;
    const radius = Radius.circular(8);
    final buttonBar = Align(
      alignment: Alignment.centerRight,
      child: _ButtonBar(snap, showUpdateButton),
    );

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
        trailing: hasFixedSize
            ? SizedBox(width: 180, child: buttonBar)
            : IntrinsicWidth(child: buttonBar),
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (initialWidgets.isNotEmpty) ...[
          initialWidgets.first,
          const SizedBox(width: kSpacing),
        ],
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
        ActiveChangeStatus(
          snapName: snapModel.valueOrNull?.name,
          activeChangeId: activeChangeId,
        )
      else ...[
        if (showUpdateButton)
          UpdateButton(snapModel: snapModel, activeChangeId: activeChangeId),
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
