import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';

import '/constants.dart';
import 'snap_card.dart';

class SnapGrid extends StatelessWidget {
  const SnapGrid({super.key, required this.snaps, required this.onTap});

  final List<Snap> snaps;
  final ValueChanged<Snap> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final (columnCount, cardSize) =
          switch (constraints.maxWidth + kPaneWidth + 1) {
        // 1px for YaruNavigationRail's separator
        < 1280 => (2, kCardSizeSmall),
        < 1680 => (3, kCardSizeMedium),
        _ => (3, kCardSizeLarge),
      };
      final columnWidth = columnCount * (cardSize.width + 2 * kCardMargin) +
          (columnCount - 1) * kPagePadding;
      return GridView.builder(
        padding: const EdgeInsets.all(kPagePadding) -
            const EdgeInsets.all(4) +
            EdgeInsets.symmetric(
                horizontal: (constraints.maxWidth - columnWidth) / 2.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          childAspectRatio: cardSize.aspectRatio,
          mainAxisSpacing: kPagePadding,
          crossAxisSpacing: kPagePadding,
        ),
        itemCount: snaps.length,
        itemBuilder: (context, index) {
          final snap = snaps[index];
          return SnapCard(
            key: ValueKey(snap.id),
            snap: snap,
            onTap: () => onTap(snap),
            compact: cardSize == kCardSizeSmall,
          );
        },
      );
    });
  }
}
