import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/routes.dart';
import '/search.dart';

class StoreObserver extends NavigatorObserver {
  StoreObserver(this.ref);

  final WidgetRef ref;

  @override
  void didPop(Route route, Route? previousRoute) {
    final search =
        previousRoute != null ? Routes.searchOf(previousRoute.settings) : null;
    ref.read(queryProvider.notifier).state = search ?? '';
  }
}
