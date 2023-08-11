import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';

import '/layout.dart';
import 'snap_card.dart';

class SnapGrid extends StatelessWidget {
  const SnapGrid({
    super.key,
    required this.snaps,
    required this.onTap,
  });

  final List<Snap> snaps;
  final ValueChanged<Snap> onTap;

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
        return SnapCard(
          key: ValueKey(snap.id),
          snap: snap,
          onTap: () => onTap(snap),
        );
      },
    );
  }
}