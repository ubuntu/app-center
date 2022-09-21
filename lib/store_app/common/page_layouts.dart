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
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final appBarHeight =
        Theme.of(context).appBarTheme.toolbarHeight?.toDouble() ??
            kToolbarHeight;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(windowSize.width / 30),
        child: SizedBox(
          height: height - appBarHeight,
          child: Row(
            children: [
              SizedBox(
                height: height,
                child: leftChild,
              ),
              const SizedBox(
                width: pagePadding,
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: false,
                  children: [
                    for (final child in rightChildren)
                      Padding(
                        padding: const EdgeInsets.only(bottom: pagePadding),
                        child: child,
                      ),
                  ],
                ),
              ),

              // BorderContainer(),
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
      padding: EdgeInsets.all(windowSize.width / 30),
      shrinkWrap: true,
      children: [
        for (final child in children)
          Padding(
            padding: const EdgeInsets.only(bottom: pagePadding),
            child: child,
          ),
      ],
    );
  }
}
