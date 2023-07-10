import 'package:app_store/l10n.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapd/snapd.dart';

extension WidgetTesterX on WidgetTester {
  BuildContext get context => element(find.byType(Scaffold).first);
  AppLocalizations get l10n => AppLocalizations.of(context);
  Future<void> pumpApp(WidgetBuilder builder) {
    return pumpWidget(MaterialApp(
      localizationsDelegates: localizationsDelegates,
      home: Scaffold(body: Builder(builder: builder)),
    ));
  }
}

List<Snap> Function(String) createMockSearchProvider(
    Map<String, List<Snap>> queries) {
  return (String query) =>
      queries.entries.firstWhereOrNull((e) => e.key.contains(query))?.value ??
      [];
}
