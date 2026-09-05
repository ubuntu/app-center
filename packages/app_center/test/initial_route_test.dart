import 'package:app_center/store/store_providers.dart';
import 'package:app_center/store/store_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

class MockInitialRouteListener extends Mock {
  void call(String? previous, String? next);
}

void main() {
  tearDown(resetAllServices);

  for (final entry in {
    'appcenter://addons': StoreRoutes.addons,
    'appcenter://addons/media-support': StoreRoutes.mediaSupport,
    'appcenter://addons/': StoreRoutes.addons,
    'appcenter://addons?source=website#details': StoreRoutes.addons,
    'appcenter://addons/unknown': StoreRoutes.addons,
    'appcenter://addons/unknown/nested': StoreRoutes.addons,
    'appcenter://addons/media-support/': StoreRoutes.mediaSupport,
    'appcenter://addons/media-support?source=website#details':
        StoreRoutes.mediaSupport,
    'appcenter://addons/media-support/?source=website#details':
        StoreRoutes.mediaSupport,
    'APPCENTER://ADDONS/media-support': StoreRoutes.mediaSupport,
    'appcenter://addons/media-support/unknown': StoreRoutes.addons,
    'appcenter://addons/unknown.deb': StoreRoutes.addons,
    'appcenter://unknown': null,
    'appcenter://unknown/media-support': null,
    'appcenter://unknown/file.deb': null,
    'appcenter://[': null,
  }.entries) {
    test('deep link ${entry.key}', () {
      final container = createContainer(
        overrides: [
          commandLineProvider.overrideWith((ref) => [entry.key]),
        ],
      );
      expect(container.read(initialRouteProvider), entry.value);
    });
  }

  test('search query', () {
    final container = ProviderContainer(
      overrides: [
        commandLineProvider.overrideWith((ref) => ['--search', 'foo']),
      ],
    );
    addTearDown(container.dispose);

    final listener = MockInitialRouteListener();
    container.listen<String?>(
      initialRouteProvider,
      listener.call,
      fireImmediately: true,
    );

    verify(listener(null, StoreRoutes.namedSearch(query: 'foo'))).called(1);
  });

  test('snap name', () {
    final container = ProviderContainer(
      overrides: [
        commandLineProvider.overrideWith((ref) => ['--snap', 'bar']),
      ],
    );
    addTearDown(container.dispose);

    final listener = MockInitialRouteListener();
    container.listen<String?>(
      initialRouteProvider,
      listener.call,
      fireImmediately: true,
    );

    verify(listener(null, StoreRoutes.namedSnap(name: 'bar'))).called(1);
  });

  test('unified details flag is disabled by default', () {
    final container = ProviderContainer(
      overrides: [
        commandLineProvider.overrideWith((ref) => ['--snap', 'bar']),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(unifiedDetailsEnabledProvider), isFalse);
  });

  test('unified details flag is enabled when passed', () {
    final container = ProviderContainer(
      overrides: [
        commandLineProvider.overrideWith(
          (ref) => ['--unified-details', '--snap', 'bar'],
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(unifiedDetailsEnabledProvider), isTrue);
    expect(
      container.read(initialRouteProvider),
      StoreRoutes.namedSnap(name: 'bar'),
    );
  });

  test('snap url', () {
    final container = ProviderContainer(
      overrides: [
        commandLineProvider.overrideWith((ref) => ['snap://bar']),
      ],
    );
    addTearDown(container.dispose);

    final listener = MockInitialRouteListener();
    container.listen<String?>(
      initialRouteProvider,
      listener.call,
      fireImmediately: true,
    );

    verify(listener(null, StoreRoutes.namedSnap(name: 'bar'))).called(1);
  });

  test('snap url with channel', () {
    final container = ProviderContainer(
      overrides: [
        commandLineProvider.overrideWith(
          (ref) => ['snap://bar?channel=preview/stable'],
        ),
      ],
    );
    addTearDown(container.dispose);

    final listener = MockInitialRouteListener();
    container.listen<String?>(
      initialRouteProvider,
      listener.call,
      fireImmediately: true,
    );

    verify(
      listener(
        null,
        StoreRoutes.namedSnap(name: 'bar', channel: 'preview/stable'),
      ),
    ).called(1);
  });

  test('local debian package', () {
    final container = ProviderContainer(
      overrides: [
        commandLineProvider.overrideWith((ref) => ['/path/to/local.deb']),
      ],
    );
    addTearDown(container.dispose);

    final listener = MockInitialRouteListener();
    container.listen<String?>(
      initialRouteProvider,
      listener.call,
      fireImmediately: true,
    );

    verify(
      listener(
        null,
        StoreRoutes.namedLocalDeb(path: '/path/to/local.deb'),
      ),
    ).called(1);
  });

  test('updates', () {
    final container = ProviderContainer(
      overrides: [
        commandLineProvider.overrideWith((ref) => ['--updates']),
      ],
    );
    addTearDown(container.dispose);

    final listener = MockInitialRouteListener();
    container.listen<String?>(
      initialRouteProvider,
      listener.call,
      fireImmediately: true,
    );

    verify(listener(null, StoreRoutes.manage)).called(1);
  });

  test('legacy codec request', () {
    const resource = 'H.265 decoder|gstreamer1(decoder-video/x-h265)()(64bit)';
    final container = createContainer(
      overrides: [
        commandLineProvider.overrideWith((ref) => ['--gst', resource]),
      ],
    );
    expect(
      container.read(initialRouteProvider),
      StoreRoutes.namedGStreamer(resources: [resource]),
    );
  });

  test('no arguments', () {
    final container = ProviderContainer(
      overrides: [commandLineProvider.overrideWith((ref) => [])],
    );
    addTearDown(container.dispose);

    final listener = MockInitialRouteListener();
    container.listen<String?>(
      initialRouteProvider,
      listener.call,
      fireImmediately: true,
    );

    verify(listener(null, null)).called(1);
  });
}
