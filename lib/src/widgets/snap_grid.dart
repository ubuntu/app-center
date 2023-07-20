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
    return GridView.builder(
      padding: const EdgeInsets.all(kPagePadding) - const EdgeInsets.all(4),
      gridDelegate: kGridDelegate,
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
