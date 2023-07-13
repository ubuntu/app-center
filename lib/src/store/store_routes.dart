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
}
