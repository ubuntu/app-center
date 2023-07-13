import 'package:flutter/widgets.dart';

import 'store_routes.dart';

class StoreNavigator {
  static Future<void> pushDetail<T>(BuildContext context, String name) {
    return Navigator.of(context).pushDetail(name);
  }

  static Future<void> pushSearch<T>(BuildContext context, String query) {
    return Navigator.of(context).pushSearch(query);
  }

  static Future<void> pushSearchDetail<T>(
    BuildContext context,
    String query,
    String name,
  ) {
    return Navigator.of(context).pushSearchDetail(context, query, name);
  }
}

extension StoreNavigatorState on NavigatorState {
  Future<void> pushDetail(String name) {
    return pushNamed(StoreRoutes.namedDetail(name));
  }

  Future<void> pushSearch(String query) {
    return pushNamed(StoreRoutes.namedSearch(query));
  }

  Future<void> pushAndRemoveSearch(String query) {
    return pushNamedAndRemoveUntil(
      StoreRoutes.namedSearch(query),
      (route) => !StoreRoutes.isSearch(route.settings),
    );
  }

  Future<void> pushSearchDetail(
    BuildContext context,
    String query,
    String name,
  ) {
    return pushNamed(StoreRoutes.namedSearchDetail(query, name));
  }
}
