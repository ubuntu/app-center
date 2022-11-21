import 'dart:math';

import 'package:flutter/material.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

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
    final hPadding = kPagePadding + 0.0004 * pow((width - 1200) * 0.8, 2);
    final appBarHeight =
        Theme.of(context).appBarTheme.toolbarHeight?.toDouble() ??
            kToolbarHeight;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: kPagePadding,
          bottom: kPagePadding,
          left: hPadding,
          right: hPadding,
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
                child: ListView(
                  shrinkWrap: false,
                  children: [
                    for (final child in rightChildren)
                      Padding(
                        padding: const EdgeInsets.only(bottom: kPagePadding),
                        child: child,
                      ),
                  ],
                ),
              ),
            ],
          ),
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
    final width = windowSize.width;
    final hPadding = 10 + 0.0007 * pow((width - 700) * 0.9, 2);
    return ListView(
      padding: adaptivePadding
          ? EdgeInsets.only(
              top: kYaruPagePadding,
              bottom: kYaruPagePadding,
              left: hPadding,
              right: hPadding,
            )
          : const EdgeInsets.all(kYaruPagePadding),
      shrinkWrap: true,
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
