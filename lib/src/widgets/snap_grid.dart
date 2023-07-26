import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';

import '/layout.dart';
import 'snap_card.dart';

class SnapGrid extends StatelessWidget {
  const SnapGrid({super.key, required this.snaps, required this.onTap});

  final List<Snap> snaps;
  final ValueChanged<Snap> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final layout = ResponsiveLayout.fromConstraints(constraints);
      return GridView.builder(
        padding: EdgeInsets.symmetric(
            horizontal: (constraints.maxWidth - layout.totalWidth) / 2.0,
            vertical: kPagePadding + 4),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: layout.cardColumnCount,
          childAspectRatio: layout.cardSize.aspectRatio,
          mainAxisSpacing: kPagePadding - 2 * kCardMargin,
          crossAxisSpacing: kPagePadding - 2 * kCardMargin,
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
