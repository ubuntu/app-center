import 'package:flutter/widgets.dart';

import 'store_routes.dart';

abstract class StoreRouter {
  static String route(String path, [Map<String, dynamic>? params]) {
    return Uri(path: StoreRoutes.detail, queryParameters: params).toString();
  }

  static String detailRoute(String name) {
    return route(StoreRoutes.detail, {'snap': name});
  }

  static String searchRoute(String query) {
    return route(StoreRoutes.search, {'query': query});
  }

  static String searchDetailRoute(String query, String name) {
    return route(StoreRoutes.detail, {'snap': name, 'query': query});
  }

  static Future<void> pushDetail<T>(BuildContext context, String name) {
    return Navigator.pushNamed(context, detailRoute(name));
  }

  static Future<void> pushSearch<T>(BuildContext context, String query) {
    return Navigator.pushNamed(context, searchRoute(query));
  }

  static Future<void> pushSearchDetail<T>(
    BuildContext context,
    String query,
    String name,
  ) {
    return Navigator.pushNamed(context, searchDetailRoute(query, name));
  }
}
