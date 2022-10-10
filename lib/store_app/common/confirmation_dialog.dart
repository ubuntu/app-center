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
import 'package:software/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class ConfirmationDialog extends StatefulWidget {
  const ConfirmationDialog({
    Key? key,
    this.onConfirm,
    required this.iconData,
    this.title,
    this.message,
    this.positiveConfirm = true,
  }) : super(key: key);

  final Function()? onConfirm;
  final IconData iconData;
  final String? title;
  final String? message;
  final bool positiveConfirm;

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation sizeAnimation;
  late Animation colorAnimation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    sizeAnimation = Tween<double>(begin: 100.0, end: 400.0).animate(controller);
    colorAnimation =
        ColorTween(begin: Colors.red, end: Colors.red.withOpacity(0.2))
            .animate(controller);
    controller.addListener(() {
      setState(() {});
    });
    controller.repeat();
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      titlePadding: EdgeInsets.zero,
      title: YaruDialogTitle(
        mainAxisAlignment: MainAxisAlignment.center,
        closeIconData: YaruIcons.window_close,
        title: widget.title,
      ),
      contentPadding: EdgeInsets.zero,
      children: [
        if (widget.message != null)
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: 500,
              child: Text(
                widget.message!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        Icon(
          widget.iconData,
          size: 100,
          color: colorAnimation.value,
        ),
        const SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 500 / 3,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      context.l10n.cancel,
                      style: TextStyle(color: Theme.of(context).errorColor),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: widget.positiveConfirm
                      ? ElevatedButton(
                          onPressed: widget.onConfirm,
                          child: Text(
                            context.l10n.confirm,
                          ),
                        )
                      : OutlinedButton(
                          onPressed: widget.onConfirm,
                          child: Text(
                            context.l10n.confirm,
                          ),
                        ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
