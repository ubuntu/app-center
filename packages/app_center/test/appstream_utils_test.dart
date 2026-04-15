import 'package:app_center/appstream/appstream_utils.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppstreamComponent.iconName', () {
    final testCases = <({
      String name,
      List<AppstreamIcon> icons,
      String? want,
    })>[
      (
        name: 'no icons',
        icons: [],
        want: null,
      ),
      (
        name: 'stock icon only',
        icons: [AppstreamStockIcon('org.gnome.Nautilus')],
        want: 'org.gnome.Nautilus',
      ),
      (
        name: 'remote icon only',
        icons: [AppstreamRemoteIcon('https://example.com/nautilus.png')],
        want: null,
      ),
      (
        name: 'stock and remote icon',
        icons: [
          AppstreamStockIcon('org.gnome.Nautilus'),
          AppstreamRemoteIcon('https://example.com/nautilus.png'),
        ],
        want: 'org.gnome.Nautilus',
      ),
    ];

    for (final testCase in testCases) {
      test(testCase.name, () {
        const component = AppstreamComponent(
          id: 'org.gnome.Nautilus',
          type: AppstreamComponentType.desktopApplication,
          package: 'nautilus',
          name: {'C': 'Files'},
          summary: {'C': 'Access and organize files'},
        );
        final withIcons = AppstreamComponent(
          id: component.id,
          type: component.type,
          package: component.package,
          name: component.name,
          summary: component.summary,
          icons: testCase.icons,
        );
        expect(withIcons.iconName, equals(testCase.want));
      });
    }
  });

  group('AppstreamComponent.iconAsync', () {
    AppstreamComponent makeComponent(List<AppstreamIcon> icons) =>
        AppstreamComponent(
          id: 'org.gnome.Nautilus',
          type: AppstreamComponentType.desktopApplication,
          package: 'nautilus',
          name: const {'C': 'Files'},
          summary: const {'C': 'Access and organize files'},
          icons: icons,
        );

    test('no icons returns null', () async {
      final component = makeComponent([]);
      expect(await component.iconAsync, isNull);
    });

    test('remote icon only returns remote URL', () async {
      final component = makeComponent(
        [AppstreamRemoteIcon('https://example.com/nautilus.png')],
      );
      expect(
        await component.iconAsync,
        equals('https://example.com/nautilus.png'),
      );
    });
  });

  group('AppstreamComponent.remoteIconUrl', () {
    final testCases = <({
      String name,
      List<AppstreamIcon> icons,
      String? want,
    })>[
      (
        name: 'no icons',
        icons: [],
        want: null,
      ),
      (
        name: 'stock icon only',
        icons: [AppstreamStockIcon('org.gnome.Nautilus')],
        want: null,
      ),
      (
        name: 'remote icon only',
        icons: [AppstreamRemoteIcon('https://example.com/nautilus.png')],
        want: 'https://example.com/nautilus.png',
      ),
      (
        name: 'stock and remote icon',
        icons: [
          AppstreamStockIcon('org.gnome.Nautilus'),
          AppstreamRemoteIcon('https://example.com/nautilus.png'),
        ],
        want: 'https://example.com/nautilus.png',
      ),
    ];

    for (final testCase in testCases) {
      test(testCase.name, () {
        final component = AppstreamComponent(
          id: 'org.gnome.Nautilus',
          type: AppstreamComponentType.desktopApplication,
          package: 'nautilus',
          name: const {'C': 'Files'},
          summary: const {'C': 'Access and organize files'},
          icons: testCase.icons,
        );
        expect(component.remoteIconUrl, equals(testCase.want));
      });
    }
  });
}
