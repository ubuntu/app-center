abstract class Routes {
  static const explore = '/explore';
  static const detail = '/detail';
  static const manage = '/manage';
  static const search = '/search';

  static bool isDetail(String route) => route.startsWith(detail);
  static bool isSearch(String route) => route.startsWith(search);
  static String? argument(String route) => route.split('/').elementAtOrNull(2);
}
