import 'dart:async';

import 'package:app_center/snapd/seen_snaps_model.dart';
import 'package:app_center/snapd/snapd_cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

final _channel = SnapChannel(
  confinement: SnapConfinement.strict,
  releasedAt: DateTime(2026),
  version: '1.0',
);

void main() {
  tearDown(resetAllServices);

  late StreamController<SnapdResult> results;
  late ProviderContainer container;

  setUp(() {
    results = StreamController();
    addTearDown(results.close);
    final snapd = registerMockSnapdService();
    when(snapd.snapResults).thenAnswer((_) => results.stream);
    container = createContainer();
  });

  SeenSnaps seen() => container.read(seenSnapsModelProvider);

  Future<void> report(SnapdResult result) async {
    seen();
    results.add(result);
    await settle();
  }

  test('records snaps the service reports', () async {
    final snap = createSnap(name: 'vlc');
    await report(FoundSnaps([snap]));

    expect(seen().store, {'vlc': snap});
    expect(seen().byName, isEmpty);
  });

  test('keeps lookups by name apart from listings', () async {
    final vlc = createSnap(name: 'vlc');
    final other = createSnap(name: 'vlc-plugin');
    await report(FoundSnaps([vlc, other], name: 'vlc'));

    expect(seen().byName, {'vlc': vlc});
    expect(seen().store.keys, {'vlc', 'vlc-plugin'});
  });

  test('keeps channels over a listing without them', () async {
    final full = createSnap(name: 'vlc', channels: {'latest/stable': _channel});
    final listed = createSnap(name: 'vlc', summary: 'listed');
    await report(FoundSnaps([full], name: 'vlc'));
    await report(FoundSnaps([listed]));
    expect(seen().store['vlc'], full);

    final refreshed = full.copyWith(summary: 'refreshed');
    await report(FoundSnaps([refreshed], name: 'vlc'));
    expect(seen().store['vlc'], refreshed);
  });

  test('tracks installed snaps', () async {
    final vlc = createSnap(name: 'vlc');
    await report(LocalSnap('vlc', vlc));
    expect(seen().local, {'vlc': vlc});

    await report(const LocalSnap('vlc', null));
    expect(seen().local, isEmpty);
  });

  test('records only active revisions from snap lists', () async {
    final active = createSnap(name: 'vlc', status: SnapStatus.active);
    final inactive = createSnap(name: 'other', status: SnapStatus.installed);
    await report(InstalledSnaps([active, inactive]));

    expect(seen().local, {'vlc': active});
  });

  test('does not notify for a result it already has', () async {
    final snap = createSnap(name: 'vlc');
    await report(FoundSnaps([snap]));
    var notifications = 0;
    container.listen(seenSnapsModelProvider, (_, _) => notifications++);

    await report(FoundSnaps([snap]));
    expect(notifications, 0);
  });
}
