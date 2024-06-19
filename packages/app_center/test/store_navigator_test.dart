import 'dart:async';

import 'package:app_center/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('navigator', (tester) async {
    final expectedRoutes = <String>[];
    final generatedRoutes = <String>[];

    await tester.pumpWidget(MaterialApp(
      home: const Scaffold(),
      onGenerateRoute: (settings) {
        expect(settings.arguments, isNull);
        generatedRoutes.add(settings.name!);
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Text(settings.name!),
        );
      },
    ));

    final context = tester.element(find.byType(Scaffold));
    unawaited(StoreNavigator.pushSnap(context, name: 'foo'));
    await tester.pump();
    expect(
      generatedRoutes,
      expectedRoutes..add(StoreRoutes.namedSnap(name: 'foo')),
    );

    unawaited(
      StoreNavigator.pushSearch(context, query: 'bar', category: 'baz'),
    );
    await tester.pump();
    expect(
      generatedRoutes,
      expectedRoutes
        ..add(StoreRoutes.namedSearch(query: 'bar', category: 'baz')),
    );

    unawaited(
      Navigator.of(context).pushAndRemoveSearch(query: 'bar', category: 'baz'),
    );
    await tester.pump();
    expect(
      generatedRoutes,
      expectedRoutes
        ..add(StoreRoutes.namedSearch(query: 'bar', category: 'baz')),
    );

    unawaited(
      StoreNavigator.pushSearchSnap(
        context,
        name: 'foo',
        query: 'bar',
        category: 'baz',
      ),
    );
    await tester.pump();
    expect(
      generatedRoutes,
      expectedRoutes
        ..add(StoreRoutes.namedSearchSnap(
            name: 'foo', query: 'bar', category: 'baz')),
    );

    unawaited(StoreNavigator.pushDeb(context, id: 'qux'));
    await tester.pump();
    expect(
      generatedRoutes,
      expectedRoutes..add(StoreRoutes.namedDeb(id: 'qux')),
    );
  });
}
