import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/snap_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'snap_service_test.mocks.dart';

@GenerateMocks([
  Notification,
  NotificationsClient,
  SnapdClient,
])
void main() {
  late MockSnapdClient mockSnapdClient;
  late MockNotificationsClient mockNotificationsClient;

  const snap1 = Snap(name: 'foobar1');
  const snap2 = Snap(name: 'foobar2');

  late SnapService service;

  setUp(() {
    mockSnapdClient = MockSnapdClient();
    registerMockService<SnapdClient>(mockSnapdClient);
    when(mockSnapdClient.loadAuthorization()).thenAnswer((_) => Future.value());

    mockNotificationsClient = MockNotificationsClient();
    registerMockService<NotificationsClient>(mockNotificationsClient);
    when(
      mockNotificationsClient.notify(
        any,
        body: anyNamed('body'),
        appName: snap1.name,
        appIcon: 'snap-store',
        hints: anyNamed('hints'),
      ),
    ).thenAnswer((_) => Future.value(MockNotification()));

    service = SnapService();
  });

  tearDown(() {
    unregisterMockService<NotificationsClient>();
    unregisterMockService<SnapdClient>();
  });

  test('instantiate service', () {
    expect(service.snapChanges, isEmpty);
  });

  test('init service', () async {
    verifyNever(mockSnapdClient.loadAuthorization());
    await service.init();
    verify(mockSnapdClient.loadAuthorization()).called(1);
  });

  test('find local snap', () async {
    when(mockSnapdClient.getSnap(snap1.name))
        .thenAnswer((_) => Future.value(snap1));

    final snap = await service.findLocalSnap(snap1.name);
    expect(snap, equals(snap1));
    verify(mockSnapdClient.getSnap(snap1.name)).called(1);

    when(mockSnapdClient.getSnap(snap1.name))
        .thenThrow(SnapdException(message: 'error'));

    expect(await service.findLocalSnap(snap1.name), isNull);
    verify(mockSnapdClient.getSnap(snap1.name)).called(1);
  });

  test('find snap by name', () async {
    const snapName = 'foobar';

    when(mockSnapdClient.find(name: snapName))
        .thenAnswer((_) => Future.value([snap1, snap2]));

    final snap = await service.findSnapByName(snapName);
    expect(snap, isNotNull);
    verify(mockSnapdClient.find(name: snapName)).called(1);
    expect(snap!.name, equals('foobar1'));

    when(mockSnapdClient.find(name: snapName))
        .thenThrow(SnapdException(message: 'error'));

    expect(await service.findSnapByName(snapName), isNull);
    verify(mockSnapdClient.find(name: snapName)).called(1);
  });

  test('get local snaps', () async {
    when(mockSnapdClient.getSnaps())
        .thenAnswer((_) => Future.value([snap1, snap2]));

    final snaps = await service.getLocalSnaps();
    expect(snaps, equals([snap1, snap2]));
    verify(mockSnapdClient.getSnaps()).called(1);
  });

  test('find snaps by query', () async {
    var snaps =
        await service.findSnapsByQuery(searchQuery: '', sectionName: null);
    expect(snaps, isEmpty);
    verifyNever(
      mockSnapdClient.find(
        query: anyNamed('query'),
        section: anyNamed('section'),
      ),
    );

    when(
      mockSnapdClient.find(
        query: anyNamed('query'),
        section: anyNamed('section'),
      ),
    ).thenAnswer((_) => Future.value([snap1, snap2]));

    snaps = await service.findSnapsByQuery(
      searchQuery: 'a query',
      sectionName: 'a section',
    );
    expect(snaps, equals([snap1, snap2]));
    verify(mockSnapdClient.find(query: 'a query', section: 'a section'))
        .called(1);

    when(
      mockSnapdClient.find(
        query: anyNamed('query'),
        section: anyNamed('section'),
      ),
    ).thenThrow(SnapdException(message: 'an error'));

    expect(
      service.findSnapsByQuery(
        searchQuery: 'a query',
        sectionName: 'a section',
      ),
      throwsA(isA<SnapdException>()),
    );
    verify(mockSnapdClient.find(query: 'a query', section: 'a section'))
        .called(1);
  });

  test('find snaps by section', () async {
    var snaps = await service.findSnapsBySection(sectionName: null);
    expect(snaps, isEmpty);
    verifyNever(mockSnapdClient.find(section: anyNamed('section')));

    when(mockSnapdClient.find(section: 'a section'))
        .thenAnswer((_) => Future.value([snap1, snap2]));

    snaps = await service.findSnapsBySection(sectionName: 'a section');
    expect(snaps, equals([snap1, snap2]));
    verify(mockSnapdClient.find(section: 'a section')).called(1);

    when(mockSnapdClient.find(section: anyNamed('section')))
        .thenThrow(SnapdException(message: 'an error'));

    expect(
      service.findSnapsBySection(sectionName: 'a section'),
      throwsA(isA<SnapdException>()),
    );
    verify(mockSnapdClient.find(section: 'a section')).called(1);
  });

  test('install snap', () async {
    var snap = await service.install(snap1, '', '');
    expect(snap, isNull);
    verifyNever(
      mockSnapdClient.install(
        snap1.name,
        channel: anyNamed('channel'),
        classic: anyNamed('classic'),
      ),
    );

    const changeId = '42';
    when(
      mockSnapdClient.install(
        snap1.name,
        channel: anyNamed('channel'),
        classic: anyNamed('classic'),
      ),
    ).thenAnswer((_) => Future.value(changeId));
    when(mockSnapdClient.getChange(changeId)).thenAnswer(
      (_) => Future.value(
        SnapdChange(id: changeId, spawnTime: DateTime.now(), ready: true),
      ),
    );
    when(mockSnapdClient.getSnap(snap1.name))
        .thenAnswer((_) => Future.value(snap1));

    expectLater(service.snapChangesInserted, emitsInOrder([true, true]));
    const channel = 'latest/stable';
    snap = await service.install(snap1, channel, '');
    expect(snap, equals(snap1));
    verify(
      mockSnapdClient.install(
        snap1.name,
        channel: channel,
        classic: anyNamed('classic'),
      ),
    ).called(1);
    verify(mockSnapdClient.getChange(changeId)).called(2);
    expect(service.snapChanges, isEmpty);
    verify(
      mockNotificationsClient.notify(
        any,
        body: anyNamed('body'),
        appName: snap1.name,
        appIcon: 'snap-store',
        hints: anyNamed('hints'),
      ),
    ).called(1);
  });

  test('remove snap', () async {
    const changeId = '42';
    when(mockSnapdClient.remove(snap1.name))
        .thenAnswer((_) => Future.value(changeId));
    when(mockSnapdClient.getChange(changeId)).thenAnswer(
      (_) => Future.value(
        SnapdChange(id: changeId, spawnTime: DateTime.now(), ready: true),
      ),
    );
    when(mockSnapdClient.getSnap(snap1.name))
        .thenAnswer((_) => Future.value(snap1));

    expectLater(service.snapChangesInserted, emitsInOrder([true, true]));
    final snap = await service.remove(snap1, '');
    expect(snap, equals(snap1));
    verify(mockSnapdClient.remove(snap1.name)).called(1);
    verify(mockSnapdClient.getChange(changeId)).called(2);
    expect(service.snapChanges, isEmpty);
    verify(
      mockNotificationsClient.notify(
        any,
        body: anyNamed('body'),
        appName: snap1.name,
        appIcon: 'snap-store',
        hints: anyNamed('hints'),
      ),
    ).called(1);
  });

  test('refresh snap', () async {
    when(mockSnapdClient.getSnap(snap1.name))
        .thenAnswer((_) => Future.value(snap1));

    var snap = await service.refresh(
      snap: snap1,
      message: '',
      channel: '',
      confinement: SnapConfinement.strict,
    );
    expect(snap, equals(snap1));
    verifyNever(
      mockSnapdClient.refresh(
        any,
        channel: anyNamed('channel'),
        classic: anyNamed('classic'),
      ),
    );

    const changeId = '42';
    when(
      mockSnapdClient.refresh(
        snap1.name,
        channel: anyNamed('channel'),
        classic: anyNamed('classic'),
      ),
    ).thenAnswer((_) => Future.value(changeId));
    when(mockSnapdClient.getChange(changeId)).thenAnswer(
      (_) => Future.value(
        SnapdChange(id: changeId, spawnTime: DateTime.now(), ready: true),
      ),
    );
    when(mockSnapdClient.getSnap(snap1.name))
        .thenAnswer((_) => Future.value(snap1));

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
      mockSnapdClient.refresh(snap1.name, channel: channel, classic: false),
    ).called(1);
    verify(mockSnapdClient.getChange(changeId)).called(2);
    expect(service.snapChanges, isEmpty);
    verify(
      mockNotificationsClient.notify(
        any,
        body: anyNamed('body'),
        appName: snap1.name,
        appIcon: 'snap-store',
        hints: anyNamed('hints'),
      ),
    ).called(1);
  });

  test('load plugs', () async {
    when(
      mockSnapdClient.getConnections(
        snap: snap1.name,
        filter: anyNamed('filter'),
      ),
    ).thenThrow(SnapdException(message: 'an error'));

    var plugs = await service.loadPlugs(snap1);
    expect(plugs, isEmpty);
    verify(
      mockSnapdClient.getConnections(
        snap: snap1.name,
        filter: anyNamed('filter'),
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
      mockSnapdClient.getConnections(
        snap: snap1.name,
        filter: anyNamed('filter'),
      ),
    ).thenAnswer(
      (_) => Future.value(SnapdConnectionsResponse(plugs: [plug1, plug2])),
    );

    plugs = await service.loadPlugs(snap1);
    expect(plugs.length, equals(2));
    expect(plugs.containsKey(plug1), isTrue);
    expect(plugs[plug1], isFalse);
    expect(plugs.containsKey(plug2), isTrue);
    expect(plugs[plug2], isTrue);
    verify(
      mockSnapdClient.getConnections(
        snap: snap1.name,
        filter: anyNamed('filter'),
      ),
    ).called(1);
  });

  test('toggle connection', () async {
    const plugName = 'plug1';
    const changeId = '42';
    when(mockSnapdClient.connect(snap1.name, plugName, 'snapd', plugName))
        .thenAnswer((_) => Future.value(changeId));
    when(mockSnapdClient.disconnect(snap1.name, plugName, 'snapd', plugName))
        .thenAnswer((_) => Future.value(changeId));
    when(mockSnapdClient.getChange(changeId)).thenAnswer(
      (_) => Future.value(
        SnapdChange(id: changeId, spawnTime: DateTime.now(), ready: true),
      ),
    );

    await service.toggleConnection(
      snapThatWantsAConnection: snap1,
      interface: plugName,
      doneMessage: '',
      value: true,
    );
    verify(mockSnapdClient.connect(snap1.name, plugName, 'snapd', plugName))
        .called(1);
    verifyNever(mockSnapdClient.disconnect(any, any, any, any));

    await service.toggleConnection(
      snapThatWantsAConnection: snap1,
      interface: plugName,
      doneMessage: '',
      value: false,
    );
    verifyNever(mockSnapdClient.connect(any, any, any, any));
    verify(mockSnapdClient.disconnect(snap1.name, plugName, 'snapd', plugName))
        .called(1);
  });

  test('get snap change in progress', () async {
    when(mockSnapdClient.getChanges(name: snap1.name))
        .thenAnswer((_) => Future.value([]));
    expect(await service.getSnapChangeInProgress(name: snap1.name), isFalse);

    when(mockSnapdClient.getChanges(name: snap1.name)).thenAnswer(
      (_) => Future.value(
        [SnapdChange(id: '42', spawnTime: DateTime.now(), ready: true)],
      ),
    );
    expect(await service.getSnapChangeInProgress(name: snap1.name), isTrue);
  });
}
