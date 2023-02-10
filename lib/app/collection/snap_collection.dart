import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/app/collection/collection_model.dart';
import 'package:software/app/collection/collection_tile.dart';
import 'package:software/app/collection/simple_snap_controls.dart';
import 'package:software/app/common/border_container.dart';
import 'package:software/app/common/snap/snap_page.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/snapx.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapCollection extends StatelessWidget {
  const SnapCollection({super.key});

  @override
  Widget build(BuildContext context) {
    final installedSnaps =
        context.select((CollectionModel m) => m.installedSnaps);
    final snapUpdates =
        context.select((CollectionModel m) => m.snapsWithUpdate);

    final checkingForSnapUpdates =
        context.select((CollectionModel m) => m.checkingForSnapUpdates);

    if (checkingForSnapUpdates == false &&
        installedSnaps != null &&
        installedSnaps.isEmpty) {
      return Center(
        child: Text(context.l10n.noSnapsInstalled),
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            if (snapUpdates.isNotEmpty)
              BorderContainer(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(
                  left: kYaruPagePadding,
                  right: kYaruPagePadding,
                  bottom: kYaruPagePadding,
                ),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapUpdates.length,
                  itemBuilder: (context, i) {
                    final snap = snapUpdates[i];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CollectionTile(
                          key: ValueKey(snap),
                          iconUrl: snap.iconUrl,
                          name: snap.name,
                          collectionTilePosition: snapUpdates.length == 1
                              ? CollectionTilePosition.only
                              : (i == 0
                                  ? CollectionTilePosition.top
                                  : (i == snapUpdates.length - 1
                                      ? CollectionTilePosition.bottom
                                      : CollectionTilePosition.middle)),
                          enabled: checkingForSnapUpdates == false,
                          onTap: () =>
                              SnapPage.push(context: context, snap: snap),
                          trailing: SimpleSnapControls.create(
                            context: context,
                            snap: snap,
                            hasUpdate: true,
                            enabled: checkingForSnapUpdates == false,
                          ),
                        ),
                        if ((i == 0 && snapUpdates.length > 1) ||
                            (i != snapUpdates.length - 1))
                          const Divider(
                            thickness: 0.0,
                            height: 0,
                          )
                      ],
                    );
                  },
                ),
              ),
            if (installedSnaps == null)
              const SizedBox.shrink()
            else if (installedSnaps.isNotEmpty)
              BorderContainer(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(
                  left: kYaruPagePadding,
                  right: kYaruPagePadding,
                  bottom: kYaruPagePadding,
                ),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: installedSnaps.length,
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    final snap = installedSnaps[i];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CollectionTile(
                          key: ValueKey(snap),
                          iconUrl: snap.iconUrl,
                          name: snap.name,
                          collectionTilePosition: installedSnaps.length == 1
                              ? CollectionTilePosition.only
                              : (i == 0
                                  ? CollectionTilePosition.top
                                  : (i == installedSnaps.length - 1
                                      ? CollectionTilePosition.bottom
                                      : CollectionTilePosition.middle)),
                          enabled: checkingForSnapUpdates == false,
                          onTap: () =>
                              SnapPage.push(context: context, snap: snap),
                          trailing: SimpleSnapControls.create(
                            context: context,
                            snap: snap,
                            hasUpdate: false,
                            enabled: checkingForSnapUpdates == false,
                          ),
                        ),
                        if ((i == 0 && installedSnaps.length > 1) ||
                            (i != installedSnaps.length - 1))
                          const Divider(
                            thickness: 0.0,
                            height: 0,
                          )
                      ],
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}
