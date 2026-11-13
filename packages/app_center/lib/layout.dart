import 'package:flutter/material.dart';

const kMargin = 4.0;
const kMarginLarge = 24.0;
const kCardMargin = 4.0;
const kCardSpacing = 16.0;
const kPaneWidth = 210.0;
const kPagePadding = 24.0;
const kSpacingSmall = 8.0;
const kSpacing = 16.0;
const kSearchBarWidth = 424.0 - 2 * kCardMargin;
const kIconSize = 56.0;
const kSectionSpacing = 48.0;

const kCardSizeNormal = Size(416.0, 170.0);
const kCardSizeWide = Size(548.0, 170.0);

const kBreakPointSmall = 1080.0;
const kBreakPointLarge = 1680.0;

const kPrimaryButtonMaxWidth = 136.0;

const kMaxDialogWidth = 500.0;
const kDialogContentPadding = EdgeInsets.all(20.0);

enum ResponsiveLayoutType {
  small,
  medium,
  large,
}

enum ResponsiveLayoutAspect {
  breakpoint,
  width,
}

class ResponsiveLayout extends InheritedModel<ResponsiveLayoutAspect> {
  ResponsiveLayout({
    required BoxConstraints constraints,
    required super.child,
    super.key,
  }) : _maxWidth = constraints.maxWidth {
    final (
      cardColumnCount,
      cardSize,
      snapInfoColumnCount,
      type,
    ) = switch (_maxWidth + kPaneWidth + 1) {
      // 1px for YaruNavigationRail's separator
      < kBreakPointSmall => (1, kCardSizeWide, 3, ResponsiveLayoutType.small),
      < kBreakPointLarge => (
        2,
        kCardSizeNormal,
        4,
        ResponsiveLayoutType.medium,
      ),
      _ => (3, kCardSizeNormal, 6, ResponsiveLayoutType.large),
    };
    this.cardColumnCount = cardColumnCount;
    this.cardSize = cardSize;
    this.snapInfoColumnCount = snapInfoColumnCount;
    this.type = type;
  }

  final double _maxWidth;

  late final int cardColumnCount;
  late final Size cardSize;
  late final int snapInfoColumnCount;
  late final ResponsiveLayoutType type;

  double get totalWidth =>
      cardColumnCount * cardSize.width + // cards
      (cardColumnCount - 1) * (kCardSpacing - 2 * kCardMargin) + // spacing
      2 * kCardMargin; // left+right margin of outermost cards

  EdgeInsets get _padding => EdgeInsets.symmetric(
    horizontal: (_maxWidth - totalWidth) / 2.0,
  );

  static ResponsiveLayout? maybeOf(BuildContext context) =>
      InheritedModel.inheritFrom<ResponsiveLayout>(
        context,
        aspect: ResponsiveLayoutAspect.breakpoint,
      );

  static ResponsiveLayout of(BuildContext context) {
    final layout = ResponsiveLayout.maybeOf(context);
    assert(layout != null, 'No ResponsiveLayout found in this context');
    return layout!;
  }

  static EdgeInsets paddingOf(BuildContext context) {
    final layout = InheritedModel.inheritFrom<ResponsiveLayout>(
      context,
      aspect: ResponsiveLayoutAspect.width,
    );
    assert(layout != null, 'No ResponsiveLayout found in this context');
    return layout!._padding;
  }

  @override
  bool updateShouldNotify(covariant ResponsiveLayout oldWidget) {
    return oldWidget._maxWidth != _maxWidth;
  }

  @override
  bool updateShouldNotifyDependent(
    covariant ResponsiveLayout oldWidget,
    Set<ResponsiveLayoutAspect> dependencies,
  ) {
    return (dependencies.contains(ResponsiveLayoutAspect.breakpoint) &&
            oldWidget.type != type) ||
        (dependencies.contains(ResponsiveLayoutAspect.width) &&
            oldWidget._maxWidth != _maxWidth);
  }
}

class ResponsiveLayoutBuilder extends StatelessWidget {
  const ResponsiveLayoutBuilder({required this.builder, super.key});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final child = Builder(builder: builder);
    return LayoutBuilder(
      builder: (context, constraints) =>
          ResponsiveLayout(constraints: constraints, child: child),
    );
  }
}

class ResponsiveLayoutScrollView extends StatelessWidget {
  const ResponsiveLayoutScrollView({super.key, this.slivers = const []});

  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      builder: (context) {
        return CustomScrollView(
          slivers: slivers
              .map(
                (s) => SliverPadding(
                  padding: ResponsiveLayout.paddingOf(context),
                  sliver: s,
                ),
              )
              .toList(),
        );
      },
    );
  }
}
