abstract class Routes {
  static const explore = '/explore';
  static const detail = '/detail';
  static const manage = '/manage';
  static const search = '/search';

  static bool isDetail(String route) => route.startsWith(detail);
  static bool isSearch(String route) => route.startsWith(search);

  static String? getArgument(String route, String name) {
    return Uri.parse(route).queryParameters[name];
  }

  static String withArgument(String route, String name, String value) {
    return Uri(path: route, queryParameters: {name: value}).toString();
  }
}
