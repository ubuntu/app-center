import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapCard extends StatelessWidget {
  const SnapCard({super.key, required this.snap});

  final Snap snap;

  @override
  Widget build(BuildContext context) {
    return YaruBanner.tile(
      title: Text(snap.name),
      subtitle: Text(snap.summary),
      icon: const SizedBox(height: 48, width: 48, child: Placeholder()),
    );
  }
}
