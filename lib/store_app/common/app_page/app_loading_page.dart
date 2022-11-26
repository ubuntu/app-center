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
import 'package:software/store_app/common/app_page/page_layouts.dart';
import 'package:software/store_app/common/border_container.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:yaru_icons/yaru_icons.dart';

class AppLoadingPage extends StatefulWidget {
  const AppLoadingPage({
    super.key,
  });

  @override
  State<AppLoadingPage> createState() => _AppLoadingPageState();
}

class _AppLoadingPageState extends State<AppLoadingPage> {
  double width = 50;
  double height = 50;

  double xPosition = 0;
  double yPosition = 0;

  double currentExtent = 0;

  bool isVisible = false;

  void onPanUpdate(DragUpdateDetails details) {
    if (details.delta.dx > 0 &&
        details.delta.dy < 50 &&
        details.delta.dy > -50 &&
        currentExtent <= kMaxExtent) {
      currentExtent += details.delta.dx;

      setState(() {
        xPosition += details.delta.dx * 0.2;
      });
    }

    if (details.delta.dx < 0 &&
        details.delta.dy < 50 &&
        details.delta.dy > -50 &&
        currentExtent >= -width) {
      currentExtent -= -details.delta.dx;
      setState(() {
        xPosition -= -details.delta.dx * 0.2;
      });
    }
  }

  void onPanStart(DragStartDetails details) {
    currentExtent = 0;
    xPosition = 0 - width;
    yPosition =
        (MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height -
                height) /
            2;
    setState(() {
      isVisible = true;
    });
  }

  void onPanEnd(DragEndDetails details) {
    if (currentExtent > (kMaxExtent / 2)) {
      Navigator.of(context).pop();
    }
    setState(() {
      isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final windowSize = MediaQuery.of(context).size;
    final windowWidth = windowSize.width;
    final isWindowNormalSized = windowWidth > 800 && windowWidth < 1200;
    final isWindowWide = windowWidth > 1200;

    var light = Theme.of(context).brightness == Brightness.light;
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
        onPanUpdate: onPanUpdate,
        onPanStart: onPanStart,
        onPanEnd: onPanEnd,
        child: Stack(
          children: <Widget>[
            body,
            Positioned(
              top: yPosition,
              left: xPosition,
              child: Visibility(
                visible: isVisible,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(255, 127, 80, 1),
                    shape: BoxShape.circle,
                  ),
                  width: 50,
                  height: 50,
                  child: const Icon(
                    Icons.arrow_back_rounded,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomBackButton extends StatelessWidget {
  const _CustomBackButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        style: IconButton.styleFrom(fixedSize: const Size(40, 40)),
        onPressed: () {
          Navigator.maybePop(context);
          if (onPressed != null) onPressed!();
        },
        icon: const Icon(YaruIcons.go_previous),
      ),
    );
  }
}
