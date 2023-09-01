import 'package:app_center/src/store/store_routes.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('route of', () {
    const root = RouteSettings(name: '/');
    expect(StoreRoutes.routeOf(root), equals('/'));
    expect(StoreRoutes.isDetail(root), isFalse);
    expect(StoreRoutes.detailOf(root), isNull);
    expect(StoreRoutes.isSearch(root), isFalse);
    expect(StoreRoutes.queryOf(root), isNull);

    const detail = RouteSettings(name: '/detail?snap=foo');
    expect(StoreRoutes.routeOf(detail), equals('/detail'));
    expect(StoreRoutes.isDetail(detail), isTrue);
    expect(StoreRoutes.detailOf(detail), equals('foo'));
    expect(StoreRoutes.isSearch(detail), isFalse);
    expect(StoreRoutes.queryOf(detail), isNull);

    const search = RouteSettings(name: '/search?query=bar');
    expect(StoreRoutes.routeOf(search), equals('/search'));
    expect(StoreRoutes.isDetail(search), isFalse);
    expect(StoreRoutes.detailOf(search), isNull);
    expect(StoreRoutes.isSearch(search), isTrue);
    expect(StoreRoutes.queryOf(search), equals('bar'));

    const searchDetail = RouteSettings(name: '/detail?query=bar&snap=foo');
    expect(StoreRoutes.routeOf(searchDetail), equals('/detail'));
    expect(StoreRoutes.isDetail(searchDetail), isTrue);
    expect(StoreRoutes.detailOf(searchDetail), equals('foo'));
    expect(StoreRoutes.isSearch(searchDetail), isFalse);
    expect(StoreRoutes.queryOf(searchDetail), equals('bar'));
  });

  test('named route', () {
    expect(StoreRoutes.namedRoute('/'), equals('/'));
    expect(StoreRoutes.namedRoute('/foo'), equals('/foo'));
    expect(
        StoreRoutes.namedRoute('/foo', {'bar': 'baz'}), equals('/foo?bar=baz'));

    expect(StoreRoutes.namedDetail(name: 'foo'), equals('/detail?snap=foo'));
    expect(StoreRoutes.namedSearch(query: 'bar'), equals('/search?query=bar'));
    expect(StoreRoutes.namedSearchDetail(query: 'bar', name: 'foo'),
        equals('/detail?snap=foo&query=bar'));
  });
}
