import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class IndeterminateCircularProgressIcon extends StatelessWidget {
  const IndeterminateCircularProgressIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 24,
      child: Center(
        child: SizedBox.square(
          dimension: 20,
          child: YaruCircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
