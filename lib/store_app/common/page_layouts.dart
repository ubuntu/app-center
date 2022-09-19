import 'package:flutter/material.dart';
import 'package:software/store_app/common/constants.dart';

class WidePageLayout extends StatelessWidget {
  const WidePageLayout({
    super.key,
    required this.rightChildren,
    required this.leftChild,
  });

  final List<Widget> rightChildren;
  final Widget leftChild;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final appBarHeight =
        Theme.of(context).appBarTheme.toolbarHeight?.toDouble() ??
            kToolbarHeight;
    return Center(
      child: SizedBox(
        height: height - appBarHeight,
        child: Row(
          children: [
            SizedBox(
              height: height,
              child: leftChild,
            ),
            Expanded(
              child: ListView(
                shrinkWrap: false,
                children: [
                  const SizedBox(
                    height: pagePadding,
                  ),
                  for (final child in rightChildren) child,
                ],
              ),
            ),

            // BorderContainer(),
          ],
        ),
      ),
    );
  }
}

class NarrowPageLayout extends StatelessWidget {
  const NarrowPageLayout({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        for (final child in children) child,
      ],
    );
  }
}
