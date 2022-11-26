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

import 'dart:async';

import 'package:flutter/material.dart';

class DangerousDelayedButton extends StatefulWidget {
  const DangerousDelayedButton({
    super.key,
    this.onPressed,
    required this.duration,
    required this.child,
  });

  final Function()? onPressed;
  final Duration duration;
  final Widget child;

  @override
  State<DangerousDelayedButton> createState() => _DangerousDelayedButtonState();
}

class _DangerousDelayedButtonState extends State<DangerousDelayedButton> {
  bool disabled = true;
  late int remainingSeconds;
  late Stopwatch stopwatch;

  @override
  void initState() {
    super.initState();

    final periodic = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => setState(() {}),
    );

    stopwatch = Stopwatch()..start();
    Timer(
      widget.duration,
      () => setState(() {
        disabled = false;
        periodic.cancel();
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remainingSeconds =
        (widget.duration.inSeconds - stopwatch.elapsed.inSeconds).toString();

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).errorColor,
      ),
      onPressed: disabled ? null : widget.onPressed,
      child: disabled
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [widget.child, Text(' ($remainingSeconds)')],
            )
          : widget.child,
    );
  }
}
