import 'package:app_center/apps/app_page.dart';
import 'package:app_center/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

const _mediumWidth = 900.0;
const _otherMediumWidth = 950.0;
const _largeWidth = 1500.0;

const _smallTotalWidth = 556.0;
const _mediumTotalWidth = 848.0;
const _largeTotalWidth = 1272.0;

class _Probe extends StatelessWidget {
  const _Probe(this.read);

  final void Function(BuildContext context) read;

  @override
  Widget build(BuildContext context) {
    read(context);
    return const SizedBox.shrink();
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.onBuild, required this.onBodyBuild});

  final VoidCallback onBuild;
  final VoidCallback onBodyBuild;

  @override
  Widget build(BuildContext context) {
    onBuild();
    final layout = ResponsiveLayout.of(context);
    return AppPage(
      titleBar: const SizedBox.shrink(),
      actionBar: const SizedBox.shrink(),
      infoBar: const SizedBox.shrink(),
      body: Column(
        children: [
          _Probe((_) => onBodyBuild()),
          SizedBox(height: layout.totalWidth / 2),
        ],
      ),
    );
  }
}

const _height = 800.0;

Future<ValueNotifier<Size>> _pumpSized(
  WidgetTester tester,
  Widget child, {
  double initialWidth = _mediumWidth,
}) async {
  tester.view.physicalSize = const Size(2000, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final size = ValueNotifier(Size(initialWidth, _height));
  addTearDown(size.dispose);

  await tester.pumpWidget(
    MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: ValueListenableBuilder<Size>(
          valueListenable: size,
          builder: (_, value, child) => SizedBox.fromSize(
            size: value,
            child: child,
          ),
          child: child,
        ),
      ),
    ),
  );
  return size;
}

Future<void> _resize(
  WidgetTester tester,
  ValueNotifier<Size> size,
  double width, {
  double height = _height,
}) async {
  size.value = Size(width, height);
  await tester.pump();
}

void main() {
  tearDown(resetAllServices);

  group('breakpoint values', () {
    for (final (width, type, columns, cardSize, infoColumns, total) in [
      (
        600.0,
        ResponsiveLayoutType.small,
        1,
        kCardSizeWide,
        3,
        _smallTotalWidth,
      ),
      (
        868.9,
        ResponsiveLayoutType.small,
        1,
        kCardSizeWide,
        3,
        _smallTotalWidth,
      ),
      (
        869.0,
        ResponsiveLayoutType.medium,
        2,
        kCardSizeNormal,
        4,
        _mediumTotalWidth,
      ),
      (
        1468.9,
        ResponsiveLayoutType.medium,
        2,
        kCardSizeNormal,
        4,
        _mediumTotalWidth,
      ),
      (
        1469.0,
        ResponsiveLayoutType.large,
        3,
        kCardSizeNormal,
        6,
        _largeTotalWidth,
      ),
    ]) {
      testWidgets('$width wide is $type', (tester) async {
        late ResponsiveLayout layout;
        await _pumpSized(
          tester,
          ResponsiveLayoutBuilder(
            builder: (_) =>
                _Probe((context) => layout = ResponsiveLayout.of(context)),
          ),
          initialWidth: width,
        );

        expect(layout.type, type);
        expect(layout.cardColumnCount, columns);
        expect(layout.cardSize, cardSize);
        expect(layout.snapInfoColumnCount, infoColumns);
        expect(layout.totalWidth, total);
      });
    }
  });

  group('paddingOf', () {
    testWidgets('centers the total width in the available width', (
      tester,
    ) async {
      late EdgeInsets padding;
      await _pumpSized(
        tester,
        ResponsiveLayoutBuilder(
          builder: (_) => _Probe(
            (context) => padding = ResponsiveLayout.paddingOf(context),
          ),
        ),
      );

      expect(
        padding,
        const EdgeInsets.symmetric(
          horizontal: (_mediumWidth - _mediumTotalWidth) / 2,
        ),
      );
    });
  });

  group('without a ResponsiveLayout ancestor', () {
    testWidgets('maybeOf returns null', (tester) async {
      ResponsiveLayout? layout;
      var built = false;
      await tester.pumpWidget(
        _Probe((context) {
          built = true;
          layout = ResponsiveLayout.maybeOf(context);
        }),
      );

      expect(built, isTrue);
      expect(layout, isNull);
    });

    testWidgets('of asserts', (tester) async {
      await tester.pumpWidget(_Probe(ResponsiveLayout.of));

      expect(tester.takeException(), isAssertionError);
    });

    testWidgets('paddingOf asserts', (tester) async {
      await tester.pumpWidget(_Probe(ResponsiveLayout.paddingOf));

      expect(tester.takeException(), isAssertionError);
    });
  });

  group('rebuilds', () {
    late int builderBuilds;
    late int breakpointBuilds;
    late int paddingBuilds;
    late ResponsiveLayoutType type;
    late EdgeInsets padding;

    Future<ValueNotifier<Size>> pumpReaders(WidgetTester tester) {
      builderBuilds = breakpointBuilds = paddingBuilds = 0;
      return _pumpSized(
        tester,
        ResponsiveLayoutBuilder(
          builder: (context) {
            builderBuilds++;
            return Column(
              children: [
                _Probe((context) {
                  breakpointBuilds++;
                  type = ResponsiveLayout.of(context).type;
                }),
                _Probe((context) {
                  paddingBuilds++;
                  padding = ResponsiveLayout.paddingOf(context);
                }),
              ],
            );
          },
        ),
      );
    }

    testWidgets('resizing within a breakpoint only rebuilds padding readers', (
      tester,
    ) async {
      final size = await pumpReaders(tester);
      expect(type, ResponsiveLayoutType.medium);
      final initialPadding = padding;

      await _resize(tester, size, _otherMediumWidth);

      expect(builderBuilds, 1);
      expect(breakpointBuilds, 1);
      expect(paddingBuilds, 2);
      expect(padding.left, initialPadding.left + 25);
    });

    testWidgets('crossing a breakpoint rebuilds layout readers', (
      tester,
    ) async {
      final size = await pumpReaders(tester);

      await _resize(tester, size, _largeWidth);

      expect(builderBuilds, 1);
      expect(breakpointBuilds, 2);
      expect(paddingBuilds, 2);
      expect(type, ResponsiveLayoutType.large);
    });

    testWidgets('changing only the height rebuilds nothing', (tester) async {
      final size = await pumpReaders(tester);

      await _resize(tester, size, _mediumWidth, height: _height / 2);

      expect(builderBuilds, 1);
      expect(breakpointBuilds, 1);
      expect(paddingBuilds, 1);
    });

    testWidgets('a new builder from the parent still rebuilds the subtree', (
      tester,
    ) async {
      final label = ValueNotifier('first');
      addTearDown(label.dispose);
      await _pumpSized(
        tester,
        ValueListenableBuilder<String>(
          valueListenable: label,
          builder: (_, value, _) =>
              ResponsiveLayoutBuilder(builder: (_) => Text(value)),
        ),
      );
      expect(find.text('first'), findsOneWidget);

      label.value = 'second';
      await tester.pump();

      expect(find.text('second'), findsOneWidget);
    });
  });

  group('detail page', () {
    late int viewBuilds;
    late int bodyBuilds;

    Future<ValueNotifier<Size>> pumpDetailPage(WidgetTester tester) {
      viewBuilds = bodyBuilds = 0;
      return _pumpSized(
        tester,
        ResponsiveLayoutBuilder(
          builder: (_) => _DetailView(
            onBuild: () => viewBuilds++,
            onBodyBuild: () => bodyBuilds++,
          ),
        ),
      );
    }

    Finder contentOfWidth(double width) => find.byWidgetPredicate(
      (widget) => widget is SizedBox && widget.width == width,
    );

    testWidgets('is not rebuilt while resizing within a breakpoint', (
      tester,
    ) async {
      final size = await pumpDetailPage(tester);

      await _resize(tester, size, _otherMediumWidth);
      await _resize(tester, size, _mediumWidth + 1);

      expect(viewBuilds, 1);
      expect(bodyBuilds, 1);
      expect(contentOfWidth(_mediumTotalWidth), findsOneWidget);
    });

    testWidgets('follows the layout when crossing a breakpoint', (
      tester,
    ) async {
      final size = await pumpDetailPage(tester);

      await _resize(tester, size, _largeWidth);

      expect(viewBuilds, 2);
      expect(bodyBuilds, 2);
      expect(contentOfWidth(_largeTotalWidth), findsOneWidget);
    });
  });

  group('ResponsiveLayoutScrollView', () {
    testWidgets('updates padding without rebuilding its slivers', (
      tester,
    ) async {
      var sliverBuilds = 0;
      final size = await _pumpSized(
        tester,
        ResponsiveLayoutScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: _Probe((_) => sliverBuilds++),
              ),
            ),
          ],
        ),
      );

      await _resize(tester, size, _otherMediumWidth);

      expect(sliverBuilds, 1);
      expect(
        tester.widget<SliverPadding>(find.byType(SliverPadding)).padding,
        const EdgeInsets.symmetric(
          horizontal: (_otherMediumWidth - _mediumTotalWidth) / 2,
        ),
      );
    });
  });
}
