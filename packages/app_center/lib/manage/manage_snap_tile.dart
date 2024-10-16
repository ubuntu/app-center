import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/manage_l10n.dart';
import 'package:app_center/manage/snap_actions_button.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/store/store.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';

enum ManageTilePosition { first, middle, last, single }

class ManageSnapTile extends StatelessWidget {
  const ManageSnapTile({
    required this.snap,
    this.position = ManageTilePosition.middle,
    this.hasFixedSize = false,
    super.key,
  });

  final Snap snap;
  final ManageTilePosition position;
  final bool hasFixedSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final border = BorderSide(color: Theme.of(context).colorScheme.outline);
    final dateTimeSinceUpdate = snap.installDate != null
        ? DateTime.now().difference(snap.installDate!)
        : null;
    const radius = Radius.circular(8);
    final actionButtons = Align(
      alignment: Alignment.centerRight,
      child: SnapActionButtons(snapName: snap.name, isPrimary: false),
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
            ? SizedBox(width: 200, child: actionButtons)
            : IntrinsicWidth(child: actionButtons),
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
