import 'package:flutter/widgets.dart';

import 'store_routes.dart';

class StoreNavigator {
  static Future<void> pushDetail(
    BuildContext context, {
    required String name,
  }) {
    return Navigator.of(context).pushDetail(name: name);
  }

  static Future<void> pushSearch(
    BuildContext context, {
    String? query,
    String? category,
  }) {
    return Navigator.of(context).pushSearch(query: query, category: category);
  }

  static Future<void> pushSearchDetail(
    BuildContext context, {
    required String name,
    String? query,
    String? category,
  }) {
    return Navigator.of(context).pushSearchDetail(
      name: name,
      query: query,
      category: category,
    );
  }
}

extension StoreNavigatorState on NavigatorState {
  Future<void> pushDetail({required String name}) {
    return pushNamed(StoreRoutes.namedDetail(name: name));
  }

  Future<void> pushSearch({String? query, String? category}) {
    return pushNamed(StoreRoutes.namedSearch(query: query, category: category));
  }

  Future<void> pushAndRemoveSearch({String? query, String? category}) {
    return pushNamedAndRemoveUntil(
      StoreRoutes.namedSearch(query: query, category: category),
      (route) => !StoreRoutes.isSearch(route.settings),
    );
  }

  Future<void> pushSearchDetail({
    required String name,
    String? query,
    String? category,
  }) {
    return pushNamed(StoreRoutes.namedSearchDetail(
      name: name,
      query: query,
      category: category,
    ));
  }
}
