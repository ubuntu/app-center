import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/manage_l10n.dart';
import 'package:app_center/snapd/snap_action.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/store/store.dart';
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
                alignment: Alignment.centerLeft,
                child: Clickable(
                  onTap: () =>
                      StoreNavigator.pushSnap(context, name: snap.name),
                  child: Text(
                    snap.titleOrName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      )
                    : const SizedBox(),
              ),
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
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
          ],
        ),
        trailing: showUpdateButton
            ? _ButtonBarForUpdate(snap)
            : _ButtonBarForOpen(snap),
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

class _ButtonBarForUpdate extends ConsumerWidget {
  const _ButtonBarForUpdate(this.snap);

  final Snap snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snapLauncher = ref.watch(launchProvider(snap));
    final snapModel = ref.watch(snapModelProvider(snap.name));
    final activeChangeId = snapModel.value?.activeChangeId;
    final removeColor = Theme.of(context).colorScheme.error;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton(
          onPressed: activeChangeId != null || !snapModel.hasValue
              ? null
              : ref.read(snapModelProvider(snap.name).notifier).refresh,
          child: activeChangeId != null
              ? ActiveChangeContent(activeChangeId)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(YaruIcons.download),
                    const SizedBox(width: 8),
                    Text(
                      l10n.snapActionUpdateLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
        const SizedBox(width: 8),
        MenuAnchor(
          menuChildren: [
            Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: snapLauncher.isLaunchable,
              child: MenuItemButton(
                onPressed: snapLauncher.open,
                child: Text(l10n.snapActionOpenLabel),
              ),
            ),
            MenuItemButton(
              onPressed: () =>
                  StoreNavigator.pushSnap(context, name: snap.name),
              child: Text(
                l10n.managePageShowDetailsLabel,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            MenuItemButton(
              onPressed: ref.read(snapModelProvider(snap.name).notifier).remove,
              leadingIcon: Icon(SnapAction.remove.icon, color: removeColor),
              child: Text(
                SnapAction.remove.label(l10n),
                style: TextStyle(color: removeColor),
              ),
            ),
          ],
          builder: (context, controller, child) => YaruOptionButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: const Icon(YaruIcons.view_more_horizontal),
          ),
        ),
      ],
    );
  }
}

class _ButtonBarForOpen extends ConsumerWidget {
  const _ButtonBarForOpen(this.snap);

  final Snap snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snapLauncher = ref.watch(launchProvider(snap));
    final snapModel = ref.watch(snapModelProvider(snap.name));
    final activeChangeId = snapModel.value?.activeChangeId;
    final removeColor = Theme.of(context).colorScheme.error;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            if (activeChangeId != null)
              OutlinedButton(
                onPressed: null,
                child: ActiveChangeContent(activeChangeId),
              ),
            Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: snapLauncher.isLaunchable && activeChangeId == null,
              child: OutlinedButton(
                onPressed: snapLauncher.open,
                child: Text(
                  l10n.snapActionOpenLabel,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 8,
        ),
        MenuAnchor(
          menuChildren: [
            MenuItemButton(
              onPressed: () =>
                  StoreNavigator.pushSnap(context, name: snap.name),
              child: Text(
                l10n.managePageShowDetailsLabel,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            MenuItemButton(
              onPressed: ref.read(snapModelProvider(snap.name).notifier).remove,
              leadingIcon: Icon(SnapAction.remove.icon, color: removeColor),
              child: Text(
                SnapAction.remove.label(l10n),
                style: TextStyle(color: removeColor),
              ),
            ),
          ],
          builder: (context, controller, child) => YaruOptionButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: const Icon(YaruIcons.view_more_horizontal),
          ),
        ),
      ],
    );
  }
}
