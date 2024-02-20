import 'package:flutter/widgets.dart';

abstract class StoreRoutes {
  static const explore = '/explore';
  static const deb = '/deb';
  static const snap = '/snap';
  static const manage = '/manage';
  static const search = '/search';
  static const externalTools = '/externalTools';

  static bool isSnap(RouteSettings route) => routeOf(route) == snap;
  static bool isSearch(RouteSettings route) => routeOf(route) == search;
  static bool isDeb(RouteSettings route) => routeOf(route) == deb;

  static String routeOf(RouteSettings route) =>
      Uri.parse(route.name ?? '').path;

  static String? categoryOf(RouteSettings route) =>
      Uri.parse(route.name ?? '').queryParameters['category'];

  static String? debOf(RouteSettings route) =>
      Uri.parse(route.name ?? '').queryParameters['deb'];

  static String? snapOf(RouteSettings route) =>
      Uri.parse(route.name ?? '').queryParameters['snap'];

  static String? queryOf(RouteSettings route) =>
      Uri.parse(route.name ?? '').queryParameters['query'];

  static String namedRoute(String path, [Map<String, dynamic>? params]) {
    return Uri(path: path, queryParameters: params).toString();
  }

  static String namedDeb({required String id}) {
    return namedRoute(StoreRoutes.deb, {'deb': id});
  }

  static String namedSnap({required String name}) {
    return namedRoute(StoreRoutes.snap, {'snap': name});
  }

  static String namedSearch({String? query, String? category}) {
    return namedRoute(StoreRoutes.search, {
      if (query != null) 'query': query,
      if (category != null) 'category': category,
    });
  }

  static String namedSearchSnap({
    required String name,
    String? query,
    String? category,
  }) {
    return namedRoute(StoreRoutes.snap, {
      'snap': name,
      if (query != null) 'query': query,
      if (category != null) 'category': category,
    });
  }
}
