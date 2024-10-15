import 'package:app_center/games/games.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/widgets/app_card.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';

class AppCardGrid extends StatelessWidget {
  const AppCardGrid({
    required this.appCards,
    this.small = false,
    super.key,
  });

  factory AppCardGrid.fromSnaps({
    required List<Snap> snaps,
    required ValueChanged<Snap> onTap,
  }) =>
      AppCardGrid(
        appCards: snaps.map(
          (snap) => AppCard.fromSnap(
            snap: snap,
            onTap: () => onTap(snap),
          ),
        ),
      );

  factory AppCardGrid.fromRatedSnaps({
    required List<Snap> snaps,
    required ValueChanged<Snap> onTap,
  }) =>
      AppCardGrid(
        appCards: snaps.asMap().entries.map(
              (entry) => AppCard.fromRatedSnap(
                snap: entry.value,
                onTap: () => onTap(entry.value),
                rank: entry.key + 1,
              ),
            ),
        small: true,
      );

  factory AppCardGrid.fromDebs({
    required List<AppstreamComponent> debs,
    required ValueChanged<AppstreamComponent> onTap,
  }) =>
      AppCardGrid(
        appCards: debs.map(
          (deb) => AppCard.fromDeb(
            component: deb,
            onTap: () => onTap(deb),
          ),
        ),
      );

  factory AppCardGrid.fromTools({
    required List<Tool> tools,
  }) =>
      AppCardGrid(
        appCards: tools.map(
          (tool) => AppCard.fromTool(
            tool: tool,
          ),
        ),
      );

  final Iterable<AppCard> appCards;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveLayout.of(context);
    var columnCount = layout.cardColumnCount;
    var cardAspectRatio = layout.cardSize.aspectRatio;
    if (small) {
      switch (layout.type) {
        case ResponsiveLayoutType.small:
          columnCount = 2;
          cardAspectRatio = 2.5;
        case ResponsiveLayoutType.medium:
          columnCount = 3;
          cardAspectRatio = 2.5;
        case ResponsiveLayoutType.large:
          columnCount = 4;
          cardAspectRatio = 3.0;
      }
    }

    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        childAspectRatio: cardAspectRatio,
        mainAxisSpacing: kCardSpacing - 2 * kCardMargin,
        crossAxisSpacing: kCardSpacing - 2 * kCardMargin,
      ),
      itemCount: appCards.length,
      itemBuilder: (context, index) => appCards.elementAt(index),
    );
  }
}

// TODO: generalize
class SnapImageCardGrid extends StatelessWidget {
  const SnapImageCardGrid({
    required this.snaps,
    required this.onTap,
    super.key,
  });

  final List<Snap> snaps;
  final ValueChanged<Snap> onTap;

  @override
  Widget build(BuildContext context) {
    final layoutType = ResponsiveLayout.of(context).type;
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: switch (layoutType) {
          ResponsiveLayoutType.small => 1,
          ResponsiveLayoutType.medium => 2,
          ResponsiveLayoutType.large => 4,
        },
        childAspectRatio: switch (layoutType) {
          ResponsiveLayoutType.small => 1.7,
          ResponsiveLayoutType.medium => 1.3,
          ResponsiveLayoutType.large => 1,
        },
        mainAxisSpacing: kCardSpacing - 2 * kCardMargin,
        crossAxisSpacing: kCardSpacing - 2 * kCardMargin,
      ),
      itemCount: snaps.length,
      itemBuilder: (context, index) {
        final snap = snaps[index];
        return SnapImageCard(
          key: ValueKey(snap.id),
          snap: snap,
          onTap: () => onTap(snap),
        );
      },
    );
  }
}
