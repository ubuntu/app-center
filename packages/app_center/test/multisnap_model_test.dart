import 'dart:async';

import 'package:app_center/snapd/multisnap_model.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';
import 'test_utils.mocks.dart';

void main() {
  tearDown(resetAllServices);

  test('install-many uses the refreshed snapshot only once', () async {
    const category = SnapCategoryEnum.gameDev;
    final names = category.featuredSnapNames!;
    final availableNames = names.skip(1).toList();
    final service = registerMockSnapdService();
    final snapshots = StreamController<List<Snap>>();
    when(service.getStoreSnaps(names)).thenAnswer(
      (_) => snapshots.stream,
    );
    final model = MultiSnapModel(snapd: service, category: category);
    addTearDown(model.dispose);
    final loading = model.init();

    snapshots.add(names.map((name) => createSnap(name: name)).toList());
    await Future<void>.delayed(Duration.zero);
    expect(model.canInstall, isFalse);

    snapshots.add(
      availableNames.map((name) => createSnap(name: name)).toList(),
    );
    await snapshots.close();
    await loading;

    await model.installAll();

    verify(service.installMany(availableNames)).called(1);
  });

  group('mixed classic and strict bundle', () {
    const category = SnapCategoryEnum.gameDev;
    final names = category.featuredSnapNames!;
    final classic = createSnap(
      name: names.first,
      confinement: SnapConfinement.classic,
    );
    late MockSnapdService service;
    late Completer<SnapdChange> classicChange;
    late List<SnapdException> errors;
    late MultiSnapModel model;

    setUp(() async {
      service = registerMockSnapdService();
      when(service.getStoreSnaps(names)).thenAnswer(
        (_) => Stream.value([
          classic,
          ...names.skip(1).map((name) => createSnap(name: name)),
        ]),
      );
      when(service.getChange('id')).thenAnswer(
        (_) async => const SnapdChange(id: 'id', status: 'Doing'),
      );
      classicChange = Completer<SnapdChange>();
      when(service.watchChange('id')).thenAnswer(
        (_) => Stream.fromFuture(classicChange.future),
      );
      errors = [];
      model = MultiSnapModel(
        snapd: service,
        category: category,
        onInstallError: errors.add,
      );
      addTearDown(model.dispose);
      await model.init();
    });

    test('waits for accepted changes if a later request fails', () async {
      final failure = SnapdException(message: 'cannot install strict snaps');
      when(service.installMany(names.sublist(1))).thenThrow(failure);

      final install = model.installAll();
      await Future<void>.delayed(Duration.zero);
      await model.installAll();

      expect(model.isInstalling, isTrue);
      expect(errors, isEmpty);
      verify(service.install(classic.name, classic: true)).called(1);
      verify(service.installMany(names.sublist(1))).called(1);
      verify(service.watchChange('id')).called(1);

      classicChange.complete(const SnapdChange(id: 'id', ready: true));
      await install;

      expect(model.isInstalling, isFalse);
      expect(errors, [failure]);
    });

    test('reports a failed change after both changes finish', () async {
      const strictId = 'strict';
      final strictChange = Completer<SnapdChange>();
      when(service.installMany(names.sublist(1)))
          .thenAnswer((_) async => strictId);
      when(service.watchChange(strictId)).thenAnswer(
        (_) => Stream.fromFuture(strictChange.future),
      );

      final install = model.installAll();
      await Future<void>.delayed(Duration.zero);
      classicChange.complete(
        const SnapdChange(id: 'id', ready: true, err: 'classic install failed'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(model.isInstalling, isTrue);
      expect(errors, isEmpty);

      strictChange.complete(const SnapdChange(id: strictId, ready: true));
      await install;

      expect(model.isInstalling, isFalse);
      expect(errors.single.message, 'classic install failed');
    });
  });
}
