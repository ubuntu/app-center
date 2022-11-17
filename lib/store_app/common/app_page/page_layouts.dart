import 'dart:math';

import 'package:flutter/material.dart';
import 'package:software/store_app/common/constants.dart';

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
    final hPadding = 0.0004 * pow(width * 0.4, 2) - 20;
    final appBarHeight =
        Theme.of(context).appBarTheme.toolbarHeight?.toDouble() ??
            kToolbarHeight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kPagePadding),
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
                  clipBehavior: Clip.none,
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
  });

  final List<Widget> children;
  final Size windowSize;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(kPagePadding),
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
