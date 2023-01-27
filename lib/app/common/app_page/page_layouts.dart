import 'dart:math';

import 'package:flutter/material.dart';
import 'package:software/app/common/constants.dart';

class PanedPageLayout extends StatelessWidget {
  const PanedPageLayout({
    super.key,
    required this.rightChildren,
    required this.leftChild,
    required this.windowSize,
  });

  final List<Widget> rightChildren;
  final Widget leftChild;
  final Size windowSize;

  @override
  Widget build(BuildContext context) {
    final height = windowSize.height;
    final width = windowSize.width;
    var hPadding = kPagePadding + 0.0004 * pow((width - 1200) * 0.8, 2);
    hPadding = hPadding > 600 ? 600 : hPadding;
    final appBarHeight =
        Theme.of(context).appBarTheme.toolbarHeight?.toDouble() ??
            kToolbarHeight;

    return Padding(
      padding: EdgeInsets.only(
        top: kPagePadding,
        left: hPadding,
        right: hPadding,
        bottom: kPagePadding,
      ),
      child: SizedBox(
        height: height - appBarHeight,
        child: Row(
          children: [
            SizedBox(
              height: height,
              child: leftChild,
            ),
            const SizedBox(
              width: kPagePadding,
            ),
            Expanded(
              child: ListView.separated(
                shrinkWrap: false,
                itemCount: rightChildren.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(
                  height: kPagePadding,
                ),
                itemBuilder: (context, index) => rightChildren[index],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnePageLayout extends StatelessWidget {
  const OnePageLayout({
    super.key,
    required this.children,
    required this.windowSize,
    this.adaptivePadding = false,
  });

  final List<Widget> children;
  final Size windowSize;
  final bool adaptivePadding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: adaptivePadding
          ? const EdgeInsets.only(
              top: kPagePadding,
              left: kPagePadding,
              right: kPagePadding,
            )
          : const EdgeInsets.only(
              top: kPagePadding,
              left: kPagePadding,
              right: kPagePadding,
            ),
      children: [
        for (final child in children)
          Padding(
            padding: const EdgeInsets.only(bottom: kPagePadding),
            child: child,
          ),
      ],
    );
  }
}
