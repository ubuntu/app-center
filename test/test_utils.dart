import 'package:app_store/l10n.dart';
import 'package:app_store/snapd.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';

import 'test_utils.mocks.dart';

extension WidgetTesterX on WidgetTester {
  BuildContext get context => element(find.byType(Scaffold).first);
  AppLocalizations get l10n => AppLocalizations.of(context);
  Future<void> pumpApp(WidgetBuilder builder) {
    return pumpWidget(MaterialApp(
      localizationsDelegates: localizationsDelegates,
      home: Scaffold(body: Builder(builder: builder)),
    ));
  }
}

List<Snap> Function(String) createMockSearchProvider(
    Map<String, List<Snap>> queries) {
  return (String query) =>
      queries.entries.firstWhereOrNull((e) => e.key.contains(query))?.value ??
      [];
}

@GenerateMocks([SnapLauncher])
SnapLauncher createMockSnapLauncher({
  bool isLaunchable = false,
}) {
  final launcher = MockSnapLauncher();
  when(launcher.isLaunchable).thenReturn(isLaunchable);
  return launcher;
}

@GenerateMocks([SnapModel])
SnapModel createMockSnapModel({
  Snap? localSnap,
  Snap? storeSnap,
  String? selectedChannel,
  AsyncValue<void>? state,
}) {
  final model = MockSnapModel();
  when(model.localSnap).thenReturn(localSnap);
  when(model.storeSnap).thenReturn(storeSnap);
  when(model.state).thenReturn(state ?? AsyncValue.data(() {}()));
  when(model.availableChannels).thenReturn(storeSnap?.channels.keys.toList());
  when(model.selectedChannel).thenReturn(
      selectedChannel ?? localSnap?.trackingChannel ?? 'latest/stable');
  when(model.activeChanges).thenReturn([]);
  return model;
}

@GenerateMocks([SnapdService])
SnapdService createMockSnapdService({
  Snap? localSnap,
  Snap? storeSnap,
}) {
  final service = MockSnapdService();
  when(service.getStoreSnap(any)).thenAnswer((_) => Stream.value(storeSnap));
  if (localSnap != null) {
    when(service.getSnap(any)).thenAnswer((_) async => localSnap);
  } else {
    when(service.getSnap(any)).thenThrow(SnapdException(
      message: 'snap not installed',
      kind: 'snap-not-found',
    ));
  }
  when(service.install(any, channel: anyNamed('channel')))
      .thenAnswer((_) async => 'id');
  when(service.refresh(any, channel: anyNamed('channel')))
      .thenAnswer((_) async => 'id');
  when(service.remove(any)).thenAnswer((_) async => 'id');
  return service;
}
