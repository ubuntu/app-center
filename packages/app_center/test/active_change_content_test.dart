import 'package:app_center/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  testWidgets('progress can become unknown after being known', (tester) async {
    final progress = ValueNotifier<double?>(0.5);
    addTearDown(progress.dispose);
    await tester.pumpApp(
      (_) => ValueListenableBuilder(
        valueListenable: progress,
        builder: (_, value, _) =>
            ActiveChangeStatus(progress: value, onCancelPressed: null),
      ),
    );

    progress.value = null;
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
