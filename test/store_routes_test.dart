import 'package:app_center/src/store/store_routes.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('route of', () {
    const root = RouteSettings(name: '/');
    expect(StoreRoutes.routeOf(root), equals('/'));
    expect(StoreRoutes.isSnap(root), isFalse);
    expect(StoreRoutes.snapOf(root), isNull);
    expect(StoreRoutes.isSearch(root), isFalse);
    expect(StoreRoutes.queryOf(root), isNull);

    const snap = RouteSettings(name: '/snap?snap=foo');
    expect(StoreRoutes.routeOf(snap), equals('/snap'));
    expect(StoreRoutes.isSnap(snap), isTrue);
    expect(StoreRoutes.snapOf(snap), equals('foo'));
    expect(StoreRoutes.isSearch(snap), isFalse);
    expect(StoreRoutes.queryOf(snap), isNull);

    const search = RouteSettings(name: '/search?query=bar');
    expect(StoreRoutes.routeOf(search), equals('/search'));
    expect(StoreRoutes.isSnap(search), isFalse);
    expect(StoreRoutes.snapOf(search), isNull);
    expect(StoreRoutes.isSearch(search), isTrue);
    expect(StoreRoutes.queryOf(search), equals('bar'));

    const searchSnap = RouteSettings(name: '/snap?query=bar&snap=foo');
    expect(StoreRoutes.routeOf(searchSnap), equals('/snap'));
    expect(StoreRoutes.isSnap(searchSnap), isTrue);
    expect(StoreRoutes.snapOf(searchSnap), equals('foo'));
    expect(StoreRoutes.isSearch(searchSnap), isFalse);
    expect(StoreRoutes.queryOf(searchSnap), equals('bar'));
  });

  test('named route', () {
    expect(StoreRoutes.namedRoute('/'), equals('/'));
    expect(StoreRoutes.namedRoute('/foo'), equals('/foo'));
    expect(
        StoreRoutes.namedRoute('/foo', {'bar': 'baz'}), equals('/foo?bar=baz'));

    expect(StoreRoutes.namedSnap(name: 'foo'), equals('/snap?snap=foo'));
    expect(StoreRoutes.namedSearch(query: 'bar'), equals('/search?query=bar'));
    expect(StoreRoutes.namedSearchSnap(query: 'bar', name: 'foo'),
        equals('/snap?snap=foo&query=bar'));
  });
}
