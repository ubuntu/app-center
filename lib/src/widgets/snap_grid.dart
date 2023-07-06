import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_widgets/constants.dart';

import '/routes.dart';
import 'constants.dart';
import 'snap_card.dart';

class SnapGrid extends StatelessWidget {
  const SnapGrid({super.key, required this.snaps});

  final List<Snap> snaps;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(kYaruPagePadding),
      gridDelegate: kGridDelegate,
      itemCount: snaps.length,
      itemBuilder: (context, index) {
        final snap = snaps[index];
        return SnapCard(
          key: ValueKey(snap.id),
          snap: snap,
          onTap: () =>
              Navigator.pushNamed(context, Routes.detail, arguments: snap.name),
        );
      },
    );
  }
}
