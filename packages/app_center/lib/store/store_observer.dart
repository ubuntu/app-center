import 'package:app_center/search/search.dart';
import 'package:app_center/store/store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreObserver extends NavigatorObserver {
  StoreObserver(this.ref);

  final WidgetRef ref;

  @override
  void didPop(Route<void> route, Route<void>? previousRoute) {
    final query = previousRoute != null
        ? StoreRoutes.queryOf(previousRoute.settings)
        : null;
    ref.read(queryProvider.notifier).state = query ?? '';
    _updateRouteNameProvider(previousRoute);
  }

  @override
  void didPush(Route<void> route, Route<void>? previousRoute) {
    _updateRouteNameProvider(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateRouteNameProvider(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _updateRouteNameProvider(newRoute);
  }

  void _updateRouteNameProvider(Route<dynamic>? route) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final routeName = route?.settings.name;
      ref.read(routeNameProvider.notifier).state = routeName;
    });
  }
}
