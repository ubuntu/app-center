import 'package:app_store/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterX on WidgetTester {
  BuildContext get context => element(find.byType(Scaffold).first);
  AppLocalizations get lang => AppLocalizations.of(context);
  Future<void> pumpApp(WidgetBuilder builder) {
    return pumpWidget(MaterialApp(
      localizationsDelegates: localizationsDelegates,
      home: Scaffold(body: Builder(builder: builder)),
    ));
  }
}

extension CommonFindersX on CommonFinders {
  /// Finds [MarkdownBody] by [data].
  Finder markdownBody(String data, {bool skipOffstage = true}) {
    return byWidgetPredicate(
      (w) => w is MarkdownBody && w.data == data,
      skipOffstage: skipOffstage,
    );
  }
}
