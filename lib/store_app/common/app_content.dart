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
import 'package:software/store_app/common/link.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AppContent extends StatelessWidget {
  const AppContent({
    Key? key,
    required this.media,
    required this.contact,
    required this.publisherName,
    required this.website,
    required this.description,
    this.lastChild,
  }) : super(key: key);

  final List<String> media;
  final String contact;
  final String publisherName;
  final String website;
  final String description;
  final Widget? lastChild;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (media.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: YaruCarousel(
              nextIcon: const Icon(YaruIcons.go_next),
              previousIcon: const Icon(YaruIcons.go_previous),
              navigationControls: media.length > 1,
              viewportFraction: 1,
              height: 250,
              children: [
                for (final url in media)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      excludeFromSemantics: true,
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => SimpleDialog(
                          children: [
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              child: YaruSafeImage(
                                url: url,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.medium,
                                fallBackIconData: YaruIcons.image,
                              ),
                            )
                          ],
                        ),
                      ),
                      child: YaruSafeImage(
                        url: url,
                        fallBackIconData: YaruIcons.image,
                      ),
                    ),
                  )
              ],
            ),
          ),
        const SizedBox(
          height: 10,
        ),
        YaruExpandable(
          header: Text(
            context.l10n.description,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          expandIcon: const Icon(YaruIcons.pan_end),
          isExpanded: media.isEmpty,
          child: Column(
            children: [
              Text(
                description,
                overflow: TextOverflow.fade,
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Link(url: website, linkText: context.l10n.website),
                    Link(
                      url: contact,
                      linkText: '${context.l10n.contact} $publisherName',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (lastChild != null) lastChild!,
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
