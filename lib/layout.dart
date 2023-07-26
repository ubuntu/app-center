import 'package:flutter/material.dart';

const kCardMargin = 4.0;
const kPaneWidth = 204.0;
const kPagePadding = 16.0;
const kSearchBarWidth = 424.0 - 2 * kCardMargin;
const kIconSize = 56.0;

const kCardSizeNormal = Size(416.0, 170.0);
const kCardSizeWide = Size(548.0, 170.0);

const kBreakPointSmall = 1280.0;
const kBreakPointLarge = 1680.0;

class ResponsiveLayout {
  const ResponsiveLayout({
    required this.cardColumnCount,
    required this.cardSize,
    required this.snapInfoColumnCount,
    required this.totalWidth,
  });

  final int cardColumnCount;
  final Size cardSize;
  final int snapInfoColumnCount;
  final double totalWidth;

  factory ResponsiveLayout.fromConstraints(BoxConstraints constraints) {
    final (cardColumnCount, cardSize, snapInfoColumnCount) =
        switch (constraints.maxWidth + kPaneWidth + 1) {
      // 1px for YaruNavigationRail's separator
      < kBreakPointSmall => (1, kCardSizeWide, 3),
      < kBreakPointLarge => (2, kCardSizeNormal, 4),
      _ => (3, kCardSizeNormal, 6),
    };
    final totalWidth = cardColumnCount * cardSize.width + // cards
        (cardColumnCount - 1) * (kPagePadding - 2 * kCardMargin) + // spacing
        2 * kCardMargin; // left+right margin of outermost cards
    return ResponsiveLayout(
      cardColumnCount: cardColumnCount,
      cardSize: cardSize,
      snapInfoColumnCount: snapInfoColumnCount,
      totalWidth: totalWidth,
    );
  }
}
