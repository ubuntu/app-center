import 'package:app_store/snapd.dart';
import 'package:app_store/src/detail/detail_provider.dart';
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
      final detailModelProvider = DetailNotifier(snapdService, testSnap.name);

      expect(
          detailModelProvider.debugState, equals(const DetailState.loading()));
      await detailModelProvider.init();
      expect(detailModelProvider.debugState,
          equals(const DetailState.data(testSnap)));

      verify(snapdService.getSnap(testSnap.name)).called(1);
    });

    test('local snap unavailable', () async {
      final snapdService = MockSnapdService();
      final exception =
          SnapdException(message: 'snap not installed', kind: 'snap-not-found');
      when(snapdService.getSnap(testSnap.name)).thenAnswer(
          (_) => Error.throwWithStackTrace(exception, StackTrace.empty));
      final detailModelProvider = DetailNotifier(snapdService, testSnap.name);

      expect(
          detailModelProvider.debugState, equals(const DetailState.loading()));
      await detailModelProvider.init();
      expect(detailModelProvider.debugState,
          equals(DetailState.error(exception, StackTrace.empty)));

      verify(snapdService.getSnap(testSnap.name)).called(1);
    });
  });

  test('install', () async {
    final snapdService = MockSnapdService();
    when(snapdService.getSnap(testSnap.name)).thenAnswer((_) async => testSnap);
    when(snapdService.install(testSnap.name))
        .thenAnswer((_) async => 'changeId');
    final detailModelProvider = DetailNotifier(snapdService, testSnap.name);

    await detailModelProvider.init();
    expectLater(
        detailModelProvider.stream,
        emitsInOrder(
            const [DetailState.loading(), DetailState.data(testSnap)]));
    await detailModelProvider.install();
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
    final detailModelProvider = DetailNotifier(snapdService, testSnap.name);

    await detailModelProvider.init();
    expectLater(
        detailModelProvider.stream,
        emitsInOrder([
          const DetailState.loading(),
          DetailState.error(exception, StackTrace.empty),
        ]));
    await detailModelProvider.remove();
    verify(snapdService.remove(testSnap.name)).called(1);
    verify(snapdService.waitChange('changeId')).called(1);
    verify(snapdService.getSnap(testSnap.name)).called(2);
  });
}
