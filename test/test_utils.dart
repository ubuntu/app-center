import 'package:app_store/l10n.dart';
import 'package:app_store/search.dart';
import 'package:app_store/snapd.dart';
import 'package:app_store/src/manage/manage_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gtk/gtk.dart';
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

Stream<List<Snap>> Function(SnapSearchParameters) createMockSearchProvider(
    Map<SnapSearchParameters, List<Snap>> searchResults) {
  return (SnapSearchParameters searchParameters) => Stream.value(
        searchResults.entries
                .firstWhereOrNull((e) => e.key == searchParameters)
                ?.value ??
            [],
      );
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
  bool? hasUpdate,
  Snap? localSnap,
  Snap? storeSnap,
  String? selectedChannel,
  String? snapName,
  AsyncValue<void>? state,
}) {
  final model = MockSnapModel();
  when(model.localSnap).thenReturn(localSnap);
  when(model.storeSnap).thenReturn(storeSnap);
  when(model.state).thenReturn(state ?? AsyncValue.data(() {}()));
  when(model.availableChannels).thenReturn(storeSnap?.channels);
  when(model.selectedChannel).thenReturn(
      selectedChannel ?? localSnap?.trackingChannel ?? 'latest/stable');
  when(model.activeChangeId).thenReturn(null);
  when(model.snap).thenReturn(storeSnap ?? localSnap!);
  when(model.channelInfo).thenReturn(model.selectedChannel != null
      ? storeSnap?.channels[model.selectedChannel]
      : null);
  when(model.isInstalled).thenReturn(model.localSnap != null);
  when(model.hasGallery).thenReturn(
      model.storeSnap != null && model.storeSnap!.screenshotUrls.isNotEmpty);
  when(model.snapName)
      .thenReturn(snapName ?? localSnap?.name ?? storeSnap?.name ?? '');
  return model;
}

@GenerateMocks([ManageModel])
ManageModel createMockManageModel({
  Iterable<Snap>? refreshableSnaps,
  Iterable<Snap>? nonRefreshableSnaps,
  AsyncValue<void>? state,
}) {
  final model = MockManageModel();
  when(model.state).thenReturn(state ?? AsyncValue.data(() {}()));
  when(model.refreshableSnaps)
      .thenReturn(refreshableSnaps ?? const Iterable.empty());
  when(model.nonRefreshableSnaps)
      .thenReturn(nonRefreshableSnaps ?? const Iterable.empty());
  return model;
}

@GenerateMocks([SnapdService])
MockSnapdService createMockSnapdService({
  Snap? localSnap,
  Snap? storeSnap,
  List<Snap>? refreshableSnaps,
  List<Snap>? installedSnaps,
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
  when(service.install(
    any,
    channel: anyNamed('channel'),
    classic: anyNamed('classic'),
  )).thenAnswer((_) async => 'id');
  when(service.refresh(
    any,
    channel: anyNamed('channel'),
    classic: anyNamed('classic'),
  )).thenAnswer((_) async => 'id');
  when(service.remove(any)).thenAnswer((_) async => 'id');
  when(service.find(filter: SnapFindFilter.refresh))
      .thenAnswer((_) async => refreshableSnaps ?? []);
  when(service.getSnaps()).thenAnswer((_) async => installedSnaps ?? []);
  return service;
}

@GenerateMocks([UpdatesModel])
MockUpdatesModel createMockUpdatesModel(
    {Iterable<String>? refreshableSnapNames}) {
  final model = MockUpdatesModel();
  when(model.refreshableSnapNames)
      .thenReturn(refreshableSnapNames ?? const Iterable.empty());
  when(model.hasUpdate(any)).thenAnswer((i) =>
      refreshableSnapNames?.contains(i.positionalArguments.single) ?? false);
  when(model.state).thenReturn(AsyncValue.data(() {}()));
  when(model.activeChangeId).thenReturn(null);
  return model;
}

@GenerateMocks([GtkApplicationNotifier])
MockGtkApplicationNotifier createMockGtkApplicationNotifier() {
  final notifier = MockGtkApplicationNotifier();
  when(notifier.commandLine).thenReturn(null);
  return notifier;
}
