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
import 'package:yaru_icons/yaru_icons.dart';

import '../border_container.dart';
import 'page_layouts.dart';

class AppLoadingPage extends StatelessWidget {
  const AppLoadingPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    final windowWidth = windowSize.width;
    final isWindowNormalSized = windowWidth > 800 && windowWidth < 1200;
    final isWindowWide = windowWidth > 1200;

    final light = Theme.of(context).brightness == Brightness.light;
    final shimmerBase = light
        ? const Color.fromARGB(120, 228, 228, 228)
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.03);
    final shimmerHighLight = light
        ? const Color.fromARGB(200, 247, 247, 247)
        : Theme.of(context).colorScheme.onSurface;

    final media = Shimmer.fromColors(
      baseColor: shimmerBase,
      highlightColor: shimmerHighLight,
      child: const BorderContainer(
        child: SizedBox(height: 400),
      ),
    );

    final description = Shimmer.fromColors(
      baseColor: shimmerBase,
      highlightColor: shimmerHighLight,
      child: const BorderContainer(
        child: SizedBox(height: 300),
      ),
    );

    final ratingsAndReviews = Shimmer.fromColors(
      baseColor: shimmerBase,
      highlightColor: shimmerHighLight,
      child: const BorderContainer(
        child: SizedBox(height: 400),
      ),
    );

    final permissionContainer = Shimmer.fromColors(
      baseColor: shimmerBase,
      highlightColor: shimmerHighLight,
      child: const BorderContainer(
        child: SizedBox(height: 600),
      ),
    );

    final normalWindowAppHeader = Shimmer.fromColors(
      baseColor: shimmerBase,
      highlightColor: shimmerHighLight,
      child: const BorderContainer(
        child: SizedBox(height: 150),
      ),
    );

    final wideWindowAppHeader = Shimmer.fromColors(
      baseColor: shimmerBase,
      highlightColor: shimmerHighLight,
      child: const BorderContainer(
        child: SizedBox(width: 500),
      ),
    );

    final narrowWindowAppHeader = Shimmer.fromColors(
      baseColor: shimmerBase,
      highlightColor: shimmerHighLight,
      child: const BorderContainer(
        height: 700,
        child: SizedBox.shrink(),
      ),
    );

    final normalWindowLayout = OnePageLayout(
      adaptivePadding: true,
      windowSize: windowSize,
      children: [
        normalWindowAppHeader,
        Shimmer.fromColors(
          baseColor: shimmerBase,
          highlightColor: shimmerHighLight,
          child: const BorderContainer(
            child: SizedBox(height: 40),
          ),
        ),
        media,
        description,
        permissionContainer,
        ratingsAndReviews
      ],
    );

    final wideWindowLayout = PanedPageLayout(
      leftChild: wideWindowAppHeader,
      rightChildren: [
        media,
        description,
        permissionContainer,
        ratingsAndReviews
      ],
      windowSize: windowSize,
    );

    final narrowWindowLayout = OnePageLayout(
      windowSize: windowSize,
      children: [
        narrowWindowAppHeader,
        media,
        description,
        permissionContainer,
        ratingsAndReviews
      ],
    );

    final body = isWindowWide
        ? wideWindowLayout
        : isWindowNormalSized
            ? normalWindowLayout
            : narrowWindowLayout;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        titleSpacing: 0,
        leading: _CustomBackButton(
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          Navigator.of(context).pop();
        },
        child: body,
      ),
    );
  }
}

class _CustomBackButton extends StatelessWidget {
  const _CustomBackButton({
    this.onPressed,
  });

  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        style: IconButton.styleFrom(fixedSize: const Size(40, 40)),
        onPressed: () {
          Navigator.maybePop(context);
          if (onPressed != null) onPressed!.call();
        },
        icon: const Icon(YaruIcons.go_previous),
      ),
    );
  }
}
