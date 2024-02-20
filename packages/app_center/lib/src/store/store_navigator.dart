import 'package:app_center/src/store/store_routes.dart';
import 'package:flutter/widgets.dart';

class StoreNavigator {
  static Future<void> pushDeb(
    BuildContext context, {
    required String id,
  }) {
    return Navigator.of(context).pushDeb(id: id);
  }

  static Future<void> pushSnap(
    BuildContext context, {
    required String name,
  }) {
    return Navigator.of(context).pushSnap(name: name);
  }

  static Future<void> pushSearch(
    BuildContext context, {
    String? query,
    String? category,
  }) {
    return Navigator.of(context).pushSearch(query: query, category: category);
  }

  static Future<void> pushSearchSnap(
    BuildContext context, {
    required String name,
    String? query,
    String? category,
  }) {
    return Navigator.of(context).pushSearchSnap(
      name: name,
      query: query,
      category: category,
    );
  }

  static Future<void> pushExternalTools(BuildContext context) {
    return Navigator.of(context).pushExternalTools();
  }
}

extension StoreNavigatorState on NavigatorState {
  Future<void> pushDeb({required String id}) {
    return pushNamed(StoreRoutes.namedDeb(id: id));
  }

  Future<void> pushSnap({required String name}) {
    return pushNamed(StoreRoutes.namedSnap(name: name));
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

  Future<void> pushSearchSnap({
    required String name,
    String? query,
    String? category,
  }) {
    return pushNamed(StoreRoutes.namedSearchSnap(
      name: name,
      query: query,
      category: category,
    ));
  }

  Future<void> pushExternalTools({String? query, String? category}) {
    return pushNamed(StoreRoutes.externalTools);
  }
}
