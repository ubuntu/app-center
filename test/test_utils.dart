import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

extension WidgetTesterX on WidgetTester {
  static Type context = Scaffold;

  AppLocalizations get lang {
    final widget = element(find.byType(context).first);
    return AppLocalizations.of(widget);
  }

  Future<void> pumpUntil(
    Finder finder, {
    Duration timeout = const Duration(seconds: 40),
    bool present = true,
  }) async {
    assert(timeout.inMilliseconds >= 250);
    const delay = Duration(milliseconds: 250);

    if (present && any(finder)) return;
    if (!present && !any(finder)) return;

    return Future.doWhile(() async {
      if (present && any(finder)) return false;
      if (!present && !any(finder)) return false;
      await pump(delay);
      return true;
    }).timeout(
      timeout,
      onTimeout: () => debugPrint(
        '\nWARNING: A call to pumpUntil() with finder "$finder" did not complete within the specified timeout $timeout.\n${StackTrace.current}',
      ),
    );
  }
}
