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
import 'package:shimmer/shimmer.dart';
import 'package:software/app/common/app_icon.dart';
import 'package:software/app/common/constants.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class LoadingBannerGrid extends StatelessWidget {
  const LoadingBannerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var light = theme.brightness == Brightness.light;
    final shimmerBase =
        light ? const Color.fromARGB(120, 228, 228, 228) : YaruColors.jet;
    final shimmerHighLight =
        light ? const Color.fromARGB(200, 247, 247, 247) : YaruColors.coolGrey;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: shimmerBase,
          highlightColor: shimmerHighLight,
          child: Padding(
            padding: const EdgeInsets.only(
              top: kPagePadding,
              left: kPagePadding,
              bottom: kPagePadding - 5,
            ),
            child: Wrap(
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: 10,
              children: const [_DummyButton(), _DummyButton()],
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.only(
              bottom: 15,
              right: 15,
              left: 15,
            ),
            gridDelegate: kGridDelegate,
            shrinkWrap: true,
            itemCount: 40,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: shimmerBase,
                highlightColor: shimmerHighLight,
                child: YaruBanner.tile(
                  title: const Text(
                    '',
                  ),
                  icon: const Padding(
                    padding: kIconPadding,
                    child: AppIcon(
                      iconUrl: null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DummyButton extends StatelessWidget {
  const _DummyButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 150,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
