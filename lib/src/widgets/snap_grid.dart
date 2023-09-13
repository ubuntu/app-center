import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';

import '/layout.dart';
import '../ratings/exports.dart';
import 'snap_card.dart';

class SnapCardGrid extends StatelessWidget {
  const SnapCardGrid({
    super.key,
    required this.snaps,
    required this.ratings,
    required this.onTap,
  });

  final List<Snap> snaps;
  final ValueChanged<Snap> onTap;
  final Map<String, Rating?> ratings;

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveLayout.of(context);
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: layout.cardColumnCount,
        childAspectRatio: layout.cardSize.aspectRatio,
        mainAxisSpacing: kCardSpacing - 2 * kCardMargin,
        crossAxisSpacing: kCardSpacing - 2 * kCardMargin,
      ),
      itemCount: snaps.length,
      itemBuilder: (context, index) {
        final snap = snaps[index];
        final rating = ratings[snap.id];
        return SnapCard(
          key: ValueKey(snap.id),
          snap: snap,
          rating: rating,
          onTap: () => onTap(snap),
        );
      },
    );
  }
}

class SnapImageCardGrid extends StatelessWidget {
  const SnapImageCardGrid({
    super.key,
    required this.snaps,
    required this.onTap,
    required this.ratings,
  });

  final List<Snap> snaps;
  final ValueChanged<Snap> onTap;
  final Map<String, Rating?> ratings;

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
        final rating = ratings[snap.id];
        return SnapImageCard(
          key: ValueKey(snap.id),
          snap: snap,
          onTap: () => onTap(snap),
          rating: rating,
        );
      },
    );
  }
}
