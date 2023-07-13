import 'package:flutter/widgets.dart';

// TODO: sort out "snap" vs. "detail"
abstract class Routes {
  static const explore = '/explore';
  static const detail = '/detail';
  static const manage = '/manage';
  static const search = '/search';

  static bool isDetail(RouteSettings route) =>
      route.name?.startsWith(detail) ?? false;

  static bool isSearch(RouteSettings route) =>
      route.name?.startsWith(search) ?? false;

  static String? detailOf(RouteSettings route) =>
      Uri.parse(route.name ?? '').queryParameters['snap'];

  static String? searchOf(RouteSettings route) =>
      Uri.parse(route.name ?? '').queryParameters['query'];

  static String asDetail(String name) {
    return Uri(path: detail, queryParameters: {'snap': name}).toString();
  }

  static String asSearch(String query) {
    return Uri(path: search, queryParameters: {'query': query}).toString();
  }

  static String asSearchDetail(String query, String name) {
    return Uri(path: detail, queryParameters: {
      'snap': name,
      'query': query,
    }).toString();
  }

  static Future<void> pushDetail<T>(BuildContext context, String name) {
    return Navigator.pushNamed(context, asDetail(name));
  }

  static Future<void> pushSearch<T>(BuildContext context, String query) {
    return Navigator.pushNamed(context, asSearch(query));
  }

  static Future<void> pushSearchDetail<T>(
    BuildContext context,
    String query,
    String name,
  ) {
    return Navigator.pushNamed(context, asSearchDetail(query, name));
  }
}
