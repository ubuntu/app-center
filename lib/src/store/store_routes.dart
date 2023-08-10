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

  static String? categoryOf(RouteSettings route) =>
      Uri.parse(route.name ?? '').queryParameters['category'];

  static String? detailOf(RouteSettings route) =>
      Uri.parse(route.name ?? '').queryParameters['snap'];

  static String? queryOf(RouteSettings route) =>
      Uri.parse(route.name ?? '').queryParameters['query'];

  static String namedRoute(String path, [Map<String, dynamic>? params]) {
    return Uri(path: path, queryParameters: params).toString();
  }

  static String namedDetail({required String name}) {
    return namedRoute(StoreRoutes.detail, {'snap': name});
  }

  static String namedSearch({String? query, String? category}) {
    return namedRoute(StoreRoutes.search, {
      if (query != null) 'query': query,
      if (category != null) 'category': category,
    });
  }

  static String namedSearchDetail({
    required String name,
    String? query,
    String? category,
  }) {
    return namedRoute(StoreRoutes.detail, {
      'snap': name,
      if (query != null) 'query': query,
      if (category != null) 'category': category,
    });
  }
}
