import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snapd/snapd.dart';
import 'package:software/app/common/snap/snap_section.dart';
import 'package:software/services/snap_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class MockNotification extends Mock implements Notification {}

class MockNotificationsClient extends Mock implements NotificationsClient {}

class MockSnapdClient extends Mock implements SnapdClient {}

void main() {
  late MockSnapdClient mockSnapdClient;
  late MockNotificationsClient mockNotificationsClient;

  const snap1 = Snap(name: 'foobar1');
  const snap2 = Snap(name: 'foobar2');

  late SnapService service;

  setUp(() {
    mockSnapdClient = MockSnapdClient();
    registerMockService<SnapdClient>(mockSnapdClient);
    when(mockSnapdClient.loadAuthorization).thenAnswer((_) async {});

    mockNotificationsClient = MockNotificationsClient();
    registerMockService<NotificationsClient>(mockNotificationsClient);
    when(
      () => mockNotificationsClient.notify(
        any(),
        body: any(named: 'body'),
        appName: snap1.name,
        appIcon: 'snap-store',
        hints: any(named: 'hints'),
      ),
    ).thenAnswer((_) async => MockNotification());

    service = SnapService();
  });

  tearDown(() {
    unregisterMockService<NotificationsClient>();
    unregisterMockService<SnapdClient>();
  });

  test('instantiate service', () {
    expect(service.snapChanges, isEmpty);
  });

  test('authorize service', () async {
    verifyNever(mockSnapdClient.loadAuthorization);
    await service.authorize();
    verify(mockSnapdClient.loadAuthorization).called(1);
  });

  test('initialize service', () async {
    when(() => mockSnapdClient.find(section: any(named: 'section'))).thenAnswer(
      (i) async {
        return i.namedArguments[const Symbol('section')] ==
                SnapSection.development.title
            ? [snap1]
            : [];
      },
    );
    service.sectionsChanged
        .listen(expectAsync1((_) {}, count: SnapSection.values.length));
    service.init();
    await service.initialized;
    verify(mockSnapdClient.loadAuthorization).called(1);
    expect(service.sectionNameToSnapsMap[SnapSection.development], [snap1]);
  });

  test('find local snap', () async {
    when(() => mockSnapdClient.getSnap(snap1.name))
        .thenAnswer((_) async => snap1);

    final snap = await service.findLocalSnap(snap1.name);
    expect(snap, equals(snap1));
    verify(() => mockSnapdClient.getSnap(snap1.name)).called(1);

    when(() => mockSnapdClient.getSnap(snap1.name))
        .thenThrow(SnapdException(message: 'error'));

    expect(await service.findLocalSnap(snap1.name), isNull);
    verify(() => mockSnapdClient.getSnap(snap1.name)).called(1);
  });

  test('find snap by name', () async {
    const snapName = 'foobar';

    when(() => mockSnapdClient.find(name: snapName))
        .thenAnswer((_) async => [snap1, snap2]);

    final snap = await service.findSnapByName(snapName);
    expect(snap, isNotNull);
    verify(() => mockSnapdClient.find(name: snapName)).called(1);
    expect(snap!.name, equals('foobar1'));

    when(() => mockSnapdClient.find(name: snapName))
        .thenThrow(SnapdException(message: 'error'));

    expect(await service.findSnapByName(snapName), isNull);
    verify(() => mockSnapdClient.find(name: snapName)).called(1);
  });

  test('get local snaps', () async {
    when(mockSnapdClient.getSnaps).thenAnswer((_) async => [snap1, snap2]);
    await service.loadLocalSnaps();
    final snaps = service.localSnaps;
    expect(snaps, equals([snap1, snap2]));
    verify(mockSnapdClient.getSnaps).called(1);
  });

  test('find snaps by query', () async {
    var snaps =
        await service.findSnapsByQuery(searchQuery: '', sectionName: null);
    expect(snaps, isEmpty);
    verifyNever(
      () => mockSnapdClient.find(
        query: any(named: 'query'),
        section: any(named: 'section'),
      ),
    );

    when(
      () => mockSnapdClient.find(
        query: any(named: 'query'),
        section: any(named: 'section'),
      ),
    ).thenAnswer((_) async => [snap1, snap2]);

    snaps = await service.findSnapsByQuery(
      searchQuery: 'a query',
      sectionName: 'a section',
    );
    expect(snaps, equals([snap1, snap2]));
    verify(() => mockSnapdClient.find(query: 'a query', section: 'a section'))
        .called(1);

    when(
      () => mockSnapdClient.find(
        query: any(named: 'query'),
        section: any(named: 'section'),
      ),
    ).thenThrow(SnapdException(message: 'an error'));

    expect(
      service.findSnapsByQuery(
        searchQuery: 'a query',
        sectionName: 'a section',
      ),
      throwsA(isA<SnapdException>()),
    );
    verify(() => mockSnapdClient.find(query: 'a query', section: 'a section'))
        .called(1);
  });

  test('find snaps by section', () async {
    var snaps = await service.findSnapsBySection(sectionName: null);
    expect(snaps, isEmpty);
    verifyNever(() => mockSnapdClient.find(section: any(named: 'section')));

    when(() => mockSnapdClient.find(section: 'a section'))
        .thenAnswer((_) async => [snap1, snap2]);

    snaps = await service.findSnapsBySection(sectionName: 'a section');
    expect(snaps, equals([snap1, snap2]));
    verify(() => mockSnapdClient.find(section: 'a section')).called(1);

    when(() => mockSnapdClient.find(section: any(named: 'section')))
        .thenThrow(SnapdException(message: 'an error'));

    expect(
      service.findSnapsBySection(sectionName: 'a section'),
      throwsA(isA<SnapdException>()),
    );
    verify(() => mockSnapdClient.find(section: 'a section')).called(1);
  });

  test('install snap', () async {
    var snap = await service.install(snap1, '', '');
    expect(snap, isNull);
    verifyNever(
      () => mockSnapdClient.install(
        snap1.name,
        channel: any(named: 'channel'),
        classic: any(named: 'classic'),
      ),
    );

    const changeId = '42';
    when(
      () => mockSnapdClient.install(
        snap1.name,
        channel: any(named: 'channel'),
        classic: any(named: 'classic'),
      ),
    ).thenAnswer((_) async => changeId);
    when(() => mockSnapdClient.getChange(changeId)).thenAnswer(
      (_) async =>
          SnapdChange(id: changeId, spawnTime: DateTime.now(), ready: true),
    );
    when(() => mockSnapdClient.getSnap(snap1.name))
        .thenAnswer((_) async => snap1);

    expectLater(service.snapChangesInserted, emitsInOrder([true, true]));
    const channel = 'latest/stable';
    snap = await service.install(snap1, channel, '');
    expect(snap, equals(snap1));
    verify(
      () => mockSnapdClient.install(
        snap1.name,
        channel: channel,
        classic: any(named: 'classic'),
      ),
    ).called(1);
    verify(() => mockSnapdClient.getChange(changeId)).called(2);
    expect(service.snapChanges, isEmpty);
    verify(
      () => mockNotificationsClient.notify(
        any(),
        body: any(named: 'body'),
        appName: snap1.name,
        appIcon: 'snap-store',
        hints: any(named: 'hints'),
      ),
    ).called(1);
  });

  test('remove snap', () async {
    const changeId = '42';
    when(() => mockSnapdClient.remove(snap1.name))
        .thenAnswer((_) async => changeId);
    when(() => mockSnapdClient.getChange(changeId)).thenAnswer(
      (_) async =>
          SnapdChange(id: changeId, spawnTime: DateTime.now(), ready: true),
    );
    when(() => mockSnapdClient.getSnap(snap1.name))
        .thenAnswer((_) async => snap1);

    expectLater(service.snapChangesInserted, emitsInOrder([true, true]));
    final snap = await service.remove(snap1, '');
    expect(snap, equals(snap1));
    verify(() => mockSnapdClient.remove(snap1.name)).called(1);
    verify(() => mockSnapdClient.getChange(changeId)).called(2);
    expect(service.snapChanges, isEmpty);
    verify(
      () => mockNotificationsClient.notify(
        any(),
        body: any(named: 'body'),
        appName: snap1.name,
        appIcon: 'snap-store',
        hints: any(named: 'hints'),
      ),
    ).called(1);
  });

  test('refresh snap', () async {
    when(() => mockSnapdClient.getSnap(snap1.name))
        .thenAnswer((_) async => snap1);

    var snap = await service.refresh(
      snap: snap1,
      message: '',
      channel: '',
      confinement: SnapConfinement.strict,
    );
    expect(snap, equals(snap1));
    verifyNever(
      () => mockSnapdClient.refresh(
        any(),
        channel: any(named: 'channel'),
        classic: any(named: 'classic'),
      ),
    );

    const changeId = '42';
    when(
      () => mockSnapdClient.refresh(
        snap1.name,
        channel: any(named: 'channel'),
        classic: any(named: 'classic'),
      ),
    ).thenAnswer((_) async => changeId);
    when(() => mockSnapdClient.getChange(changeId)).thenAnswer(
      (_) async =>
          SnapdChange(id: changeId, spawnTime: DateTime.now(), ready: true),
    );
    when(() => mockSnapdClient.getSnap(snap1.name))
        .thenAnswer((_) async => snap1);

    expectLater(service.snapChangesInserted, emitsInOrder([true, true]));
    const channel = 'latest/stable';
    snap = await service.refresh(
      snap: snap1,
      message: '',
      channel: channel,
      confinement: SnapConfinement.strict,
    );
    expect(snap, equals(snap1));
    verify(
      () =>
          mockSnapdClient.refresh(snap1.name, channel: channel, classic: false),
    ).called(1);
    verify(() => mockSnapdClient.getChange(changeId)).called(2);
    expect(service.snapChanges, isEmpty);
    verify(
      () => mockNotificationsClient.notify(
        any(),
        body: any(named: 'body'),
        appName: snap1.name,
        appIcon: 'snap-store',
        hints: any(named: 'hints'),
      ),
    ).called(1);

    when(
      () => mockSnapdClient.refresh(
        snap1.name,
        channel: any(named: 'channel'),
        classic: any(named: 'classic'),
      ),
    ).thenThrow(SnapdException(message: 'has running apps'));
    service.refreshError.listen(expectAsync1((_) {}));
    snap = await service.refresh(
      snap: snap1,
      message: '',
      channel: channel,
      confinement: SnapConfinement.strict,
    );
  });

  test('load plugs', () async {
    when(
      () => mockSnapdClient.getConnections(
        snap: snap1.name,
        filter: any(named: 'filter'),
      ),
    ).thenThrow(SnapdException(message: 'an error'));

    var plugs = await service.loadPlugs(snap1);
    expect(plugs, isEmpty);
    verify(
      () => mockSnapdClient.getConnections(
        snap: snap1.name,
        filter: any(named: 'filter'),
      ),
    ).called(1);

    final plug1 = SnapPlug(
      snap: snap1.name,
      plug: 'plug1',
      interface: 'iface1',
      connections: [],
    );
    final plug2 = SnapPlug(
      snap: snap1.name,
      plug: 'plug2',
      interface: 'iface2',
      connections: [SnapSlot(snap: snap2.name, slot: 'slot1')],
    );
    when(
      () => mockSnapdClient.getConnections(
        snap: snap1.name,
        filter: any(named: 'filter'),
      ),
    ).thenAnswer((_) async => SnapdConnectionsResponse(plugs: [plug1, plug2]));

    plugs = await service.loadPlugs(snap1);
    expect(plugs.length, equals(2));
    expect(plugs.containsKey(plug1), isTrue);
    expect(plugs[plug1], isFalse);
    expect(plugs.containsKey(plug2), isTrue);
    expect(plugs[plug2], isTrue);
    verify(
      () => mockSnapdClient.getConnections(
        snap: snap1.name,
        filter: any(named: 'filter'),
      ),
    ).called(1);
  });

  test('toggle connection', () async {
    const plugName = 'plug1';
    const changeId = '42';
    when(() => mockSnapdClient.connect(snap1.name, plugName, 'snapd', plugName))
        .thenAnswer((_) async => changeId);
    when(
      () => mockSnapdClient.disconnect(snap1.name, plugName, 'snapd', plugName),
    ).thenAnswer((_) async => changeId);
    when(() => mockSnapdClient.getChange(changeId)).thenAnswer(
      (_) async =>
          SnapdChange(id: changeId, spawnTime: DateTime.now(), ready: true),
    );

    await service.toggleConnection(
      snapThatWantsAConnection: snap1,
      interface: plugName,
      doneMessage: '',
      value: true,
    );
    verify(
      () => mockSnapdClient.connect(snap1.name, plugName, 'snapd', plugName),
    ).called(1);
    verifyNever(() => mockSnapdClient.disconnect(any(), any(), any(), any()));

    await service.toggleConnection(
      snapThatWantsAConnection: snap1,
      interface: plugName,
      doneMessage: '',
      value: false,
    );
    verifyNever(() => mockSnapdClient.connect(any(), any(), any(), any()));
    verify(
      () => mockSnapdClient.disconnect(snap1.name, plugName, 'snapd', plugName),
    ).called(1);
  });

  test('get snap change in progress', () async {
    when(() => mockSnapdClient.getChanges(name: snap1.name))
        .thenAnswer((_) async => []);
    expect(await service.getSnapChangeInProgress(name: snap1.name), isFalse);

    when(() => mockSnapdClient.getChanges(name: snap1.name)).thenAnswer(
      (_) async =>
          [SnapdChange(id: '42', spawnTime: DateTime.now(), ready: true)],
    );
    expect(await service.getSnapChangeInProgress(name: snap1.name), isTrue);
  });

  test('get snap changes', () async {
    when(() => mockSnapdClient.getChanges(name: snap1.name))
        .thenAnswer((_) async => []);
    expect(await service.getSnapChanges(name: snap1.name), isNull);

    final testChange =
        SnapdChange(id: '42', spawnTime: DateTime.now(), ready: true);
    when(() => mockSnapdClient.getChanges(name: snap1.name)).thenAnswer(
      (_) async => [testChange],
    );
    expect(await service.getSnapChanges(name: snap1.name), testChange);
  });

  test('load snaps with update', () async {
    const snapWithUpdateOld = Snap(
      name: 'snapWithUpdate',
      version: '1',
      tracks: ['latest'],
      trackingChannel: 'latest/stable',
    );
    final snapWithUpdateNew = Snap(
      name: 'snapWithUpdate',
      version: '2',
      tracks: ['latest'],
      trackingChannel: 'latest/stable',
      channels: {
        'latest/stable': SnapChannel(releasedAt: DateTime.now(), version: '2')
      },
    );
    final snapWithoutUpdate = Snap(
      name: 'snapWithoutUpdate',
      version: '1',
      tracks: ['latest'],
      trackingChannel: 'latest/stable',
      channels: {
        'latest/stable': SnapChannel(releasedAt: DateTime.now(), version: '1')
      },
    );
    when(mockSnapdClient.getSnaps).thenAnswer(
      (_) async => [snapWithUpdateOld, snapWithoutUpdate],
    );
    when(() => mockSnapdClient.find(filter: SnapFindFilter.refresh))
        .thenAnswer((_) async => [snapWithUpdateNew]);
    await service.loadSnapsWithUpdate();
    expect(service.snapsWithUpdate, [snapWithUpdateNew]);
  });
}
