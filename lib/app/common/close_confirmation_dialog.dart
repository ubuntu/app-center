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
import 'package:software/app/common/animated_warning_icon.dart';
import 'package:software/app/common/dangerous_delayed_button.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class CloseWindowConfirmDialog extends StatelessWidget {
  const CloseWindowConfirmDialog({
    super.key,
    this.onConfirm,
  });

  final Function()? onConfirm;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const YaruCloseButton(
        alignment: Alignment.centerRight,
      ),
      titlePadding: const EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 0.0),
      contentPadding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SizedBox(
            width: 500,
            child: Column(
              children: [
                const AnimatedWarningIcon(),
                Text(
                  context.l10n.attention,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontSize: 24.0),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Text(
                    context.l10n.quitDanger,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: DangerousDelayedButton(
                  duration: const Duration(seconds: 3),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    context.l10n.quit,
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    context.l10n.cancel,
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
