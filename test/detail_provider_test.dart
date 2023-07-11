import 'package:app_store/snapd.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';

import 'detail_provider_test.mocks.dart';

@GenerateMocks([SnapdService])
void main() {
  const testSnap = Snap(name: 'testsnap');
  group('init', () {
    test('local snap available', () async {
      final snapdService = MockSnapdService();
      when(snapdService.getSnap(testSnap.name))
          .thenAnswer((_) async => testSnap);
      final localSnapNotifier = LocalSnapNotifier(snapdService, testSnap.name);

      expect(localSnapNotifier.debugState, equals(const LocalSnap.loading()));
      await localSnapNotifier.init();
      expect(
          localSnapNotifier.debugState, equals(const LocalSnap.data(testSnap)));

      verify(snapdService.getSnap(testSnap.name)).called(1);
    });

    test('local snap unavailable', () async {
      final snapdService = MockSnapdService();
      final exception =
          SnapdException(message: 'snap not installed', kind: 'snap-not-found');
      when(snapdService.getSnap(testSnap.name)).thenAnswer(
          (_) => Error.throwWithStackTrace(exception, StackTrace.empty));
      final localSnapNotifier = LocalSnapNotifier(snapdService, testSnap.name);

      expect(localSnapNotifier.debugState, equals(const LocalSnap.loading()));
      await localSnapNotifier.init();
      expect(localSnapNotifier.debugState,
          equals(LocalSnap.error(exception, StackTrace.empty)));

      verify(snapdService.getSnap(testSnap.name)).called(1);
    });
  });

  test('install', () async {
    final snapdService = MockSnapdService();
    when(snapdService.getSnap(testSnap.name)).thenAnswer((_) async => testSnap);
    when(snapdService.install(testSnap.name))
        .thenAnswer((_) async => 'changeId');
    final localSnapNotifier = LocalSnapNotifier(snapdService, testSnap.name);

    await localSnapNotifier.init();
    expect(localSnapNotifier.stream,
        emitsInOrder(const [LocalSnap.loading(), LocalSnap.data(testSnap)]));
    await localSnapNotifier.install();
    verify(snapdService.install(testSnap.name)).called(1);
    verify(snapdService.waitChange('changeId')).called(1);
    verify(snapdService.getSnap(testSnap.name)).called(2);
  });

  test('remove', () async {
    final snapdService = MockSnapdService();
    final exception =
        SnapdException(message: 'snap not installed', kind: 'snap-not-found');
    when(snapdService.getSnap(testSnap.name)).thenAnswer(
        (_) => Error.throwWithStackTrace(exception, StackTrace.empty));
    when(snapdService.remove(testSnap.name))
        .thenAnswer((_) async => 'changeId');
    final localSnapNotifier = LocalSnapNotifier(snapdService, testSnap.name);

    await localSnapNotifier.init();
    expect(
        localSnapNotifier.stream,
        emitsInOrder([
          const LocalSnap.loading(),
          LocalSnap.error(exception, StackTrace.empty),
        ]));
    await localSnapNotifier.remove();
    verify(snapdService.remove(testSnap.name)).called(1);
    verify(snapdService.waitChange('changeId')).called(1);
    verify(snapdService.getSnap(testSnap.name)).called(2);
  });
}
