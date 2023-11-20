import 'package:app_center/src/store/store_providers.dart';
import 'package:app_center/src/store/store_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockInitialRouteListener extends Mock {
  void call(String? previous, String? next);
}

void main() {
  test('search query', () {
    final container = ProviderContainer(overrides: [
      commandLineProvider.overrideWith((ref) => ['--search', 'foo'])
    ]);
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
    final container = ProviderContainer(overrides: [
      commandLineProvider.overrideWith((ref) => ['--snap', 'bar'])
    ]);
    addTearDown(container.dispose);

    final listener = MockInitialRouteListener();
    container.listen<String?>(
      initialRouteProvider,
      listener.call,
      fireImmediately: true,
    );

    verify(listener(null, StoreRoutes.namedSnap(name: 'bar'))).called(1);
  });

  test('snap url', () {
    final container = ProviderContainer(overrides: [
      commandLineProvider.overrideWith((ref) => ['snap://bar'])
    ]);
    addTearDown(container.dispose);

    final listener = MockInitialRouteListener();
    container.listen<String?>(
      initialRouteProvider,
      listener.call,
      fireImmediately: true,
    );

    verify(listener(null, StoreRoutes.namedSnap(name: 'bar'))).called(1);
  });

  test('no arguments', () {
    final container = ProviderContainer(
        overrides: [commandLineProvider.overrideWith((ref) => [])]);
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
