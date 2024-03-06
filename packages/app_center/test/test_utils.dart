import 'dart:async';
import 'dart:io';

import 'package:app_center/appstream.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/packagekit.dart';
import 'package:app_center/ratings.dart';
import 'package:app_center/snapd.dart';
import 'package:app_center/src/deb/deb_model.dart';
import 'package:app_center/src/manage/manage_model.dart';
import 'package:app_center/src/snapd/multisnap_model.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:appstream/appstream.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gtk/gtk.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';
import 'package:snapd/snapd.dart';

import 'test_utils.mocks.dart';

extension WidgetTesterX on WidgetTester {
  BuildContext get context => element(find.byType(Scaffold).first);
  AppLocalizations get l10n => AppLocalizations.of(context);
  Future<void> pumpApp(WidgetBuilder builder) async {
    // The intended minimum size of the window.
    view.physicalSize =
        (const Size(800, 600) + const Offset(54, 54)) * view.devicePixelRatio;
    final ubuntuRegular = File('test/fonts/Ubuntu-Regular.ttf');
    final content = ByteData.view(
        Uint8List.fromList(ubuntuRegular.readAsBytesSync()).buffer);
    final fontLoader = FontLoader('UbuntuRegular')
      ..addFont(Future.value(content));
    await fontLoader.load();
    return pumpWidget(
      MaterialApp(
        theme: ThemeData(fontFamily: 'UbuntuRegular'),
        localizationsDelegates: localizationsDelegates,
        home: Scaffold(body: Builder(builder: builder)),
      ),
    );
  }
}

Stream<List<Snap>> Function(SnapSearchParameters) createMockSnapSearchProvider(
    Map<SnapSearchParameters, List<Snap>> searchResults) {
  return (searchParameters) => Stream.value(
        searchResults.entries
                .firstWhereOrNull((e) => e.key == searchParameters)
                ?.value ??
            [],
      );
}

Stream<List<AppstreamComponent>> Function(String) createMockDebSearchProvider(
    Map<String, List<AppstreamComponent>> searchResults) {
  return (query) => Stream.value(
        searchResults.entries.firstWhereOrNull((e) => e.key == query)?.value ??
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

@GenerateMocks([RatingsModel])
RatingsModel createMockRatingsModel({
  AsyncValue<void>? state,
  Rating? snapRating,
  String? snapId,
  VoteStatus? voteStatus,
  Future<void> Function(bool voteUp)? mockVote,
}) {
  final model = MockRatingsModel();

  when(model.state).thenReturn(state ?? AsyncValue.data(() {}()));
  when(model.snapRating).thenReturn(snapRating);
  when(model.snapId).thenReturn(snapId ?? '');
  when(model.vote).thenReturn(voteStatus);

  if (mockVote != null) {
    when(model.castVote(any)).thenAnswer((invocation) async {
      await mockVote(invocation.positionalArguments[0] as bool);
    });
  }

  return model;
}

@GenerateMocks([SnapModel])
SnapModel createMockSnapModel({
  bool? hasUpdate,
  Snap? localSnap,
  Snap? storeSnap,
  String? selectedChannel,
  String? snapName,
  AsyncValue<void>? state,
  Stream<SnapdException>? errorStream,
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
  when(model.errorStream)
      .thenAnswer((_) => errorStream ?? const Stream.empty());
  return model;
}

@GenerateMocks([DebModel])
DebModel createMockDebModel({
  String? id,
  AppstreamComponent? component,
  PackageKitPackageInfo? packageInfo,
  AsyncValue<void>? state,
  Stream<PackageKitServiceError>? errorStream,
}) {
  final model = MockDebModel();
  when(model.id).thenReturn(id ?? '');
  when(model.state).thenReturn(state ?? AsyncValue.data(() {}()));
  when(model.component).thenReturn(
    component ??
        const AppstreamComponent(
          id: '',
          type: AppstreamComponentType.desktopApplication,
          package: '',
          name: {'C': ''},
          summary: {'C': ''},
        ),
  );
  when(model.packageInfo).thenReturn(packageInfo);
  when(model.isInstalled)
      .thenReturn(packageInfo?.info == PackageKitInfo.installed);
  when(model.activeTransactionId).thenReturn(null);
  when(model.errorStream)
      .thenAnswer((_) => errorStream ?? const Stream.empty());
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
  List<SnapdChange>? changes,
  int? storeSnapsCount,
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
  when(service.refreshMany(any)).thenAnswer((_) async => 'id');
  when(service.remove(any)).thenAnswer((_) async => 'id');
  when(service.find(filter: SnapFindFilter.refresh))
      .thenAnswer((_) async => refreshableSnaps ?? []);
  when(service.getSnaps()).thenAnswer((_) async => installedSnaps ?? []);
  when(service.getChanges(name: anyNamed('name')))
      .thenAnswer((_) async => changes ?? []);
  when(service.watchChange(any)).thenAnswer((_) => const Stream.empty());
  when(service.abortChange(any))
      .thenAnswer((_) async => SnapdChange(spawnTime: DateTime.now()));
  when(service.installMany(
    any,
  )).thenAnswer((_) async => 'id');
  when(service.getStoreSnaps(any)).thenAnswer((_) => Stream.value(
      List<Snap>.generate(storeSnapsCount!, (index) => storeSnap!,
          growable: false)));
  return service;
}

@GenerateMocks([UpdatesModel])
MockUpdatesModel createMockUpdatesModel({
  Iterable<String>? refreshableSnapNames,
  Stream<SnapdException>? errorStream,
  bool isBusy = false,
}) {
  final model = MockUpdatesModel();
  when(model.refreshableSnapNames)
      .thenReturn(refreshableSnapNames ?? const Iterable.empty());
  when(model.hasUpdate(any)).thenAnswer((i) =>
      refreshableSnapNames?.contains(i.positionalArguments.single) ?? false);
  when(model.state).thenReturn(AsyncValue.data(() {}()));
  when(model.activeChangeId).thenReturn(isBusy ? 'changeId' : null);
  when(model.errorStream)
      .thenAnswer((_) => errorStream ?? const Stream.empty());
  return model;
}

@GenerateMocks([GtkApplicationNotifier])
MockGtkApplicationNotifier createMockGtkApplicationNotifier() {
  final notifier = MockGtkApplicationNotifier();
  when(notifier.commandLine).thenReturn(null);
  return notifier;
}

/// Assumes that only a single `PackageKitTransaction` is used in a test. Needs
/// to be generalized in order to test methods that use multiple transactions.
@GenerateMocks([PackageKitClient])
MockPackageKitClient createMockPackageKitClient(
    {PackageKitTransaction? transaction}) {
  final client = MockPackageKitClient();
  when(client.createTransaction()).thenAnswer(
      (_) async => transaction ?? createMockPackageKitTransaction());
  return client;
}

/// Creates a mock transaction that emits a series of `events` when any action
/// listed below is performed. Make sure to independently verify that the desired
/// action has been called.
/// Awaits the optional `start` and `end` futures before and after emitting the
/// provided `events`, respectively.
/// Emits 'finished' and 'destroy' events before closing the stream.
@GenerateMocks([PackageKitTransaction])
MockPackageKitTransaction createMockPackageKitTransaction({
  Iterable<PackageKitEvent>? events,
  PackageKitExit? exit,
  int? runtime,
  Future<void>? start,
  Future<void>? end,
}) {
  final transaction = MockPackageKitTransaction();
  final controller = StreamController<PackageKitEvent>.broadcast();
  when(transaction.events).thenAnswer((_) => controller.stream);

  Future<void> emitEvents() async {
    if (start != null) await start;
    for (final event in events ?? <PackageKitEvent>[]) {
      controller.add(event);
    }
    if (end != null) await end;

    controller.add(
      PackageKitFinishedEvent(
        exit: exit ?? PackageKitExit.success,
        runtime: runtime ?? 0,
      ),
    );
    controller.add(const PackageKitDestroyEvent());
    await controller.close();
  }

  // Add similar statements for further methods as needed.
  when(transaction.installPackages(any))
      .thenAnswer((_) async => unawaited(emitEvents()));
  when(transaction.removePackages(any))
      .thenAnswer((_) async => unawaited(emitEvents()));
  when(transaction.resolve(any))
      .thenAnswer((_) async => unawaited(emitEvents()));
  return transaction;
}

@GenerateMocks([RatingsService])
MockRatingsService createMockRatingsService({
  Rating? rating,
  List<Vote>? snapVotes,
}) {
  final service = MockRatingsService();
  when(service.getRating(any)).thenAnswer((_) async =>
      rating ??
      const Rating(
        snapId: '',
        totalVotes: 0,
        ratingsBand: RatingsBand.insufficientVotes,
      ));
  when(service.getSnapVotes(any)).thenAnswer((_) async => snapVotes ?? []);

  return service;
}

@GenerateMocks([RatingsClient])
MockRatingsClient createMockRatingsClient({
  String? token,
  Rating? rating,
  List<Vote>? myVotes,
  List<Vote>? snapVotes,
}) {
  final client = MockRatingsClient();
  when(client.authenticate(any)).thenAnswer((_) async => token ?? '');
  when(client.getRating(any, any)).thenAnswer((_) async =>
      rating ??
      const Rating(
        snapId: '',
        totalVotes: 0,
        ratingsBand: RatingsBand.insufficientVotes,
      ));
  when(client.listMyVotes(any, any)).thenAnswer((_) async => myVotes ?? []);
  when(client.getSnapVotes(any, any)).thenAnswer((_) async => snapVotes ?? []);
  return client;
}

@GenerateMocks([AppstreamService])
MockAppstreamService createMockAppstreamService({
  AppstreamComponent? component,
  bool initialized = true,
}) {
  final appstream = MockAppstreamService();
  when(appstream.initialized).thenReturn(initialized);
  when(appstream.getFromId(any)).thenAnswer(
    (_) =>
        component ??
        const AppstreamComponent(
          id: '',
          type: AppstreamComponentType.unknown,
          package: '',
          name: {},
          summary: {},
        ),
  );
  return appstream;
}

@GenerateMocks([PackageKitService])
MockPackageKitService createMockPackageKitService({
  PackageKitPackageInfo? packageInfo,
  int transactionId = 0,
  Stream<PackageKitServiceError> errorStream = const Stream.empty(),
}) {
  final packageKit = MockPackageKitService();
  when(packageKit.resolve(any)).thenAnswer((_) async => packageInfo);
  when(packageKit.install(any)).thenAnswer((_) async => transactionId);
  when(packageKit.remove(any)).thenAnswer((_) async => transactionId);
  when(packageKit.errorStream).thenAnswer((_) => errorStream);
  return packageKit;
}

@GenerateMocks([MultiSnapModel])
MultiSnapModel createMockMultiSnapModel() {
  final model = MockMultiSnapModel();
  return model;
}
