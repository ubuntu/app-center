//file: utils/integration_test_helpers.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore: prefer_typing_uninitialized_variables
var _originalOnError;
void initCustomExpect() {
  _originalOnError = FlutterError.onError;
}

// A workaround for: https://github.com/flutter/flutter/issues/34499
void expectCustom(
  dynamic actual,
  dynamic matcher, {
  String? reason,
  dynamic skip, // true or a String
}) {
  final onError = FlutterError.onError;
  FlutterError.onError = _originalOnError;
  expect(actual, matcher, reason: reason, skip: skip);
  FlutterError.onError = onError;
}
