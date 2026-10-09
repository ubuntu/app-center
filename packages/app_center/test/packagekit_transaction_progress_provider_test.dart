import 'dart:async';

import 'package:app_center/packagekit/packagekit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';

import 'test_utils.dart';

class _FakeTransaction extends Fake implements PackageKitTransaction {
  @override
  PackageKitStatus status = PackageKitStatus.waitingForAuth;

  @override
  int percentage = 101;

  final _events = StreamController<PackageKitEvent>.broadcast();
  final _properties = StreamController<List<String>>.broadcast();

  @override
  Stream<PackageKitEvent> get events => _events.stream;

  @override
  Stream<List<String>> get propertiesChanged => _properties.stream;

  bool get hasListeners => _events.hasListener || _properties.hasListener;

  Future<void> changeStatus(PackageKitStatus status) async {
    this.status = status;
    _properties.add(['Status']);
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> changePercentage(int percentage) async {
    this.percentage = percentage;
    _properties.add(['Percentage', 'ElapsedTime']);
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> finish(PackageKitExit exit) async {
    _events.add(PackageKitFinishedEvent(exit: exit, runtime: 0));
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late _FakeTransaction transaction;
  late ProviderContainer container;
  late List<double?> values;

  setUp(() {
    transaction = _FakeTransaction();
    final packageKit = createMockPackageKitService();
    when(packageKit.getTransaction(42)).thenReturn(transaction);
    container = createContainer();
    values = [];
  });

  void listen() {
    container.listen(
      packageKitTransactionProgressProvider(42),
      (_, next) => values.add(next),
      fireImmediately: true,
    );
  }

  test('is null without a transaction id', () {
    expect(container.read(packageKitTransactionProgressProvider(null)), isNull);
  });

  test('is null for an unknown transaction', () {
    expect(container.read(packageKitTransactionProgressProvider(1)), isNull);
  });

  test('is null while the percentage is unknown', () {
    listen();
    expect(values, [null]);
  });

  test('ignores preparation phases and stale percentages', () async {
    listen();
    await transaction.changeStatus(PackageKitStatus.loadingCache);
    await transaction.changePercentage(50);
    await transaction.changePercentage(100);
    await transaction.changeStatus(PackageKitStatus.query);
    await transaction.changeStatus(PackageKitStatus.download);
    await transaction.changeStatus(PackageKitStatus.running);
    await transaction.changePercentage(101);

    expect(values, [null]);
  });

  test('combines download and install into a single progress', () async {
    listen();
    await transaction.changeStatus(PackageKitStatus.loadingCache);
    await transaction.changePercentage(100);
    await transaction.changeStatus(PackageKitStatus.download);
    await transaction.changePercentage(0);
    await transaction.changePercentage(9);
    await transaction.changePercentage(31);
    await transaction.changePercentage(64);
    await transaction.changeStatus(PackageKitStatus.running);
    await transaction.changePercentage(101);
    await transaction.changePercentage(20);
    await transaction.changeStatus(PackageKitStatus.install);
    await transaction.changePercentage(40);
    await transaction.changePercentage(80);
    await transaction.finish(PackageKitExit.success);

    expect(values, [
      null,
      0.0,
      closeTo(0.063, 1e-9),
      closeTo(0.217, 1e-9),
      closeTo(0.448, 1e-9),
      0.7, // download phase is complete
      closeTo(0.76, 1e-9),
      closeTo(0.82, 1e-9),
      closeTo(0.94, 1e-9),
      1.0,
    ]);
  });

  test('uses the full range when nothing is downloaded', () async {
    listen();
    await transaction.changeStatus(PackageKitStatus.download);
    await transaction.changeStatus(PackageKitStatus.running);
    await transaction.changePercentage(11);
    await transaction.changeStatus(PackageKitStatus.install);
    await transaction.changePercentage(88);

    expect(values, [null, closeTo(0.11, 1e-9), closeTo(0.88, 1e-9)]);
  });

  test('never goes backwards', () async {
    listen();
    await transaction.changeStatus(PackageKitStatus.running);
    await transaction.changePercentage(60);
    await transaction.changePercentage(10);
    await transaction.changePercentage(70);

    expect(values, [null, closeTo(0.6, 1e-9), closeTo(0.7, 1e-9)]);
  });

  test('completes when the transaction succeeds', () async {
    listen();
    await transaction.changeStatus(PackageKitStatus.remove);
    await transaction.changePercentage(80);
    await transaction.finish(PackageKitExit.success);

    expect(values.last, 1.0);
  });

  test('does not complete when the transaction fails', () async {
    listen();
    await transaction.changeStatus(PackageKitStatus.remove);
    await transaction.changePercentage(80);
    await transaction.finish(PackageKitExit.failed);

    expect(values.last, closeTo(0.8, 1e-9));
  });

  test('starts from the current progress of a running transaction', () {
    transaction
      ..status = PackageKitStatus.install
      ..percentage = 40;
    listen();

    expect(values, [closeTo(0.4, 1e-9)]);
  });

  test('stops listening when disposed', () {
    listen();
    expect(transaction.hasListeners, isTrue);

    container.dispose();
    expect(transaction.hasListeners, isFalse);
  });
}
