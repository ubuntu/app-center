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
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_colors/yaru_colors.dart';

class Link extends StatelessWidget {
  const Link({
    required this.url,
    required this.linkText,
    this.textStyle,
    super.key,
  });

  final String url;
  final String linkText;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: url == context.l10n.unknown
          ? null
          : () async => await launchUrl(Uri.parse(url)),
      child: Text(
        linkText,
        style: textStyle ??
            Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.linkColor),
      ),
    );
  }
}

extension LinkColor on BuildContext {
  Color get linkColor => Theme.of(this).brightness == Brightness.light
      ? YaruColors.blue[700]!
      : YaruColors.blue[500]!;
}
