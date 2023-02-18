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
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:software/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';
import '../expandable_title.dart';

class AppDescription extends StatelessWidget {
  const AppDescription({super.key, required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return YaruExpandable(
      isExpanded: true,
      expandIcon: const Icon(YaruIcons.pan_end),
      header: ExpandableContainerTitle(
        context.l10n.description,
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: MarkdownBody(
          data: description,
          shrinkWrap: true,
          selectable: true,
          onTapLink: (text, href, title) =>
              href != null ? launchUrl(Uri.parse(href)) : null,
          styleSheet: MarkdownStyleSheet(
            p: Theme.of(context).textTheme.bodyMedium,
            a: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }
}
