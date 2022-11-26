/*
 * Copyright (C) 2022 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';

class AnimatedWarningIcon extends StatefulWidget {
  const AnimatedWarningIcon({super.key});

  @override
  State<AnimatedWarningIcon> createState() => _AnimatedWarningIconState();
}

class _AnimatedWarningIconState extends State<AnimatedWarningIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation colorAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    colorAnimation =
        ColorTween(begin: Colors.red, end: Colors.red.withOpacity(0.5))
            .chain(CurveTween(curve: Curves.easeInCubic))
            .animate(controller);

    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => Icon(
        YaruIcons.warning_filled,
        size: 100,
        color: colorAnimation.value,
      ),
    );
  }
}
