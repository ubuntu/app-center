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
        < 1280 => (1, kCardSizeWide),
        < 1680 => (2, kCardSizeNormal),
        _ => (3, kCardSizeNormal),
      };
      final columnWidth = columnCount * cardSize.width +
          (columnCount - 1) * (kPagePadding - kCardMargin) +
          2 * kCardMargin;
      return GridView.builder(
        padding: EdgeInsets.symmetric(
            horizontal: (constraints.maxWidth - columnWidth) / 2.0,
            vertical: kPagePadding + 4),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnCount,
          childAspectRatio: cardSize.aspectRatio,
          mainAxisSpacing: kPagePadding - kCardMargin,
          crossAxisSpacing: kPagePadding - kCardMargin,
        ),
        itemCount: snaps.length,
        itemBuilder: (context, index) {
          final snap = snaps[index];
          return SnapCard(
            key: ValueKey(snap.id),
            snap: snap,
            onTap: () => onTap(snap),
          );
        },
      );
    });
  }
}
