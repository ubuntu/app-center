import 'package:flutter/widgets.dart';

// TODO: sort out "snap" vs. "detail"
abstract class StoreRoutes {
  static const explore = '/explore';
  static const detail = '/detail';
  static const manage = '/manage';
  static const search = '/search';

  static bool isDetail(RouteSettings route) => routeOf(route) == detail;
  static bool isSearch(RouteSettings route) => routeOf(route) == search;

  static String routeOf(RouteSettings route) =>
      Uri.parse(route.name ?? '').path;

  static String? detailOf(RouteSettings route) =>
      Uri.parse(route.name ?? '').queryParameters['snap'];

  static String? queryOf(RouteSettings route) =>
      Uri.parse(route.name ?? '').queryParameters['query'];

  static String namedRoute(String path, [Map<String, dynamic>? params]) {
    return Uri(path: path, queryParameters: params).toString();
  }

  static String namedDetail(String name) {
    return namedRoute(StoreRoutes.detail, {'snap': name});
  }

  static String namedSearch(String query) {
    return namedRoute(StoreRoutes.search, {'query': query});
  }

  static String namedSearchDetail(String query, String name) {
    return namedRoute(StoreRoutes.detail, {'snap': name, 'query': query});
  }
}
