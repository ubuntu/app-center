import 'package:app_center/search/search.dart';
import 'package:app_center/store/store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreObserver extends NavigatorObserver {
  StoreObserver(this.ref);

  final WidgetRef ref;
  // didRemove's previousRoute isn't always the top page, so track pages here.
  final _pages = <Route<dynamic>>[];

  @override
  void didPop(Route<void> route, Route<void>? previousRoute) {
    if (!_pages.remove(route)) return;
    final top = _pages.lastOrNull;
    final query = top != null ? StoreRoutes.queryOf(top.settings) : null;
    ref.read(queryProvider.notifier).state = query ?? '';
    _publishTopPage();
  }

  @override
  void didPush(Route<void> route, Route<void>? previousRoute) {
    if (route is! PageRoute) return;
    _pages.add(route);
    _publishTopPage();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_pages.remove(route)) _publishTopPage();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : _pages.indexOf(oldRoute);
    if (index != -1) _pages.removeAt(index);
    if (newRoute is PageRoute) {
      _pages.insert(index == -1 ? _pages.length : index, newRoute);
    }
    _publishTopPage();
  }

  void _publishTopPage() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final routeName = _pages.lastOrNull?.settings.name;
      ref.read(routeNameProvider.notifier).state = routeName;
    });
  }
}
