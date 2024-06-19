import 'package:app_center/appstream/appstream.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'appstream_service_test.mocks.dart';

@GenerateMocks([AppstreamPool])
void main() {
  late AppstreamPool pool;
  late List<AppstreamComponent> components;
  late AppstreamService service;

  const component1 = AppstreamComponent(
    id: 'com.play0ad.zeroad',
    type: AppstreamComponentType.desktopApplication,
    package: '0ad',
    name: {'C': '0 A.D.'},
    summary: {'C': 'Real-Time Strategy Game of Ancient Warfare'},
    description: {
      'C': '''0 A.D. is a real-time strategy (RTS) game of ancient warfare.
          Each civilization is complete with substantially unique artwork,
          technologies and civilization bonuses.'''
    },
    keywords: {
      'C': [
        'RTS',
        'Real-Time Strategy',
        'Economic Simulation Game',
        'History',
        'Warfare',
      ]
    },
    provides: [AppstreamProvidesMediatype('application/x-pyromod+zip')],
  );

  const component2 = AppstreamComponent(
    id: 'qbrew.desktop',
    type: AppstreamComponentType.desktopApplication,
    package: 'qbrew',
    name: {'C': 'QBrew'},
    summary: {},
  );

  const component3 = AppstreamComponent(
    id: 'gperiodic.desktop',
    type: AppstreamComponentType.desktopApplication,
    package: 'gperiodic',
    name: {'C': 'GPeriodic'},
    summary: {},
  );

  setUp(() {
    pool = MockAppstreamPool();
    components = [];
    when(pool.components).thenReturn(components);
    service = AppstreamService(pool: pool);
  });

  test('initialize service', () async {
    verifyNever(pool.load());
    expect(service.initialized, isFalse);
    await service.init();
    verify(pool.load()).called(1);
    expect(service.cacheSize, 0);
    expect(service.initialized, isTrue);
  });

  test('load and cache components', () async {
    components.add(component1);
    await service.init();
    expect(service.cacheSize, 1);
  });

  test('search', () async {
    components.addAll([component1, component2, component3]);
    await service.init();
    expect(service.cacheSize, 3);

    // Match on package ID
    var results = await service.search('play0ad');
    expect(results.length, 1);
    expect(results[0], component1);

    // Match on name
    results = await service.search('A.D.');
    expect(results.length, 1);
    expect(results[0], component1);

    // Match on keywords
    results = await service.search('rts');
    expect(results.length, 1);
    expect(results[0], component1);

    // Match on summary
    results = await service.search('game');
    expect(results.length, 1);
    expect(results[0], component1);

    // Match on description
    results = await service.search('artwork');
    expect(results.length, 1);
    expect(results[0], component1);

    // Match on package name
    results = await service.search('0ad');
    expect(results.length, 1);
    expect(results[0], component1);

    // Match on media type
    results = await service.search('pyromod');
    expect(results.length, 1);
    expect(results[0], component1);

    // Match several components
    results = await service.search('desktop');
    expect(results.length, 2);
    expect(results.contains(component2), isTrue);
    expect(results.contains(component3), isTrue);

    // Empty search matches all components
    results = await service.search('');
    expect(results.length, 3);

    // Invalid search
    results = await service.search('<html>');
    expect(results, isEmpty);

    // 'application' is grey-listed
    results = await service.search('foobar application');
    expect(results, isEmpty);

    // 'application' and 'tool' are grey-listed
    results = await service.search('package tool');
    expect(results, isEmpty);
  });
}
