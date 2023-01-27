import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:software/app/common/connectivity_notifier.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  test('connectivity', () async {
    final controller = StreamController<ConnectivityResult>(sync: true);

    final mock = MockConnectivity();
    when(() => mock.checkConnectivity())
        .thenAnswer((_) async => ConnectivityResult.none);
    when(() => mock.onConnectivityChanged).thenAnswer((_) => controller.stream);

    final notifier = ConnectivityNotifier(mock);
    expect(notifier.isOnline, isTrue); // considered online by default

    var wasNotified = 0;
    var expectedNotified = 0;
    notifier.addListener(() => wasNotified++);

    await notifier.init();
    expect(notifier.isOnline, isFalse);
    expect(wasNotified, ++expectedNotified);

    controller.add(ConnectivityResult.wifi);
    expect(notifier.isOnline, isTrue);
    expect(wasNotified, ++expectedNotified);

    controller.add(ConnectivityResult.ethernet);
    expect(notifier.isOnline, isTrue);
    expect(wasNotified, ++expectedNotified);

    controller.add(ConnectivityResult.none);
    expect(notifier.isOnline, isFalse);
    expect(wasNotified, ++expectedNotified);
  });
}
