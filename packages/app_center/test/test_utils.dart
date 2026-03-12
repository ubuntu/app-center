import 'dart:async';
import 'dart:io';

import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/gstreamer/gstreamer_model.dart';
import 'package:app_center/gstreamer/gstreamer_resource.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/manage/deb_updates_provider.dart';
import 'package:app_center/manage/local_deb_providers.dart';
import 'package:app_center/manage/manage_app_data.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:app_center/providers/error_stream_provider.dart';
import 'package:app_center/providers/file_system_provider.dart';
import 'package:app_center/ratings/ratings.dart';
import 'package:app_center/snapd/multisnap_model.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:appstream/appstream.dart';
import 'package:collection/collection.dart';
import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gtk/gtk.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:packagekit/packagekit.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

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
      Uint8List.fromList(ubuntuRegular.readAsBytesSync()).buffer,
    );
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

/// A testing utility which creates a [ProviderContainer] and automatically
/// disposes it at the end of the test.
ProviderContainer createContainer({
  ProviderContainer? parent,
  List<Override> overrides = const [],
  List<ProviderObserver>? observers,
}) {
  // Create a ProviderContainer, and optionally allow specifying parameters.
  final container = ProviderContainer(
    parent: parent,
    overrides: [
      fileSystemProvider.overrideWithValue(MemoryFileSystem()),
      ...overrides,
    ],
    observers: observers,
  );

  // When the test ends, dispose the container.
  addTearDown(container.dispose);

  return container;
}

Stream<List<Snap>> Function(SnapSearchParameters) createMockSnapSearchProvider(
  Map<SnapSearchParameters, List<Snap>> searchResults,
) {
  return (searchParameters) => Stream.value(
        searchResults.entries
                .firstWhereOrNull((e) => e.key == searchParameters)
                ?.value ??
            [],
      );
}

Stream<List<AppstreamComponent>> Function(String) createMockDebSearchProvider(
  Map<String, List<AppstreamComponent>> searchResults,
) {
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

@GenerateMocks([GstreamerModel])
GstreamerModel createMockGstreamerModel({
  required List<GstResource> resources,
}) {
  final model = MockGstreamerModel();
  when(model.resources).thenReturn(GstResourceCollection(resources));
  when(model.state)
      .thenReturn(AsyncValue.data(GStreamerData(packageInfos: [])));
  return model;
}

@GenerateMocks([ErrorStreamController])
MockErrorStreamController registerMockErrorStreamControllerService() {
  final service = MockErrorStreamController();
  registerMockService<ErrorStreamController>(service);
  return service;
}

@GenerateMocks([SnapdService])
MockSnapdService registerMockSnapdService({
  Snap? localSnap,
  Snap? storeSnap,
  List<Snap>? refreshableSnaps,
  List<Snap>? installedSnaps,
  List<SnapdChange>? changes,
  int? storeSnapsCount,
}) {
  final service = MockSnapdService();
  when(service.defaultFileSystem).thenReturn(MemoryFileSystem());
  when(service.getStoreSnaps(any))
      .thenAnswer((_) => Stream.value([if (storeSnap != null) storeSnap]));
  if (localSnap != null) {
    when(service.getSnap(any)).thenAnswer((_) async => localSnap);
  } else if (storeSnap != null && localSnap == null) {
    when(service.getSnap(any)).thenThrow(
      SnapdException(
        message: 'snap not installed',
        kind: 'snap-not-found',
      ),
    );
  } else {
    when(service.getSnap(any)).thenAnswer((invocation) async {
      final name = invocation.positionalArguments.first as String;
      return [...?installedSnaps, ...?refreshableSnaps]
          .firstWhere((s) => s.name == name);
    });
  }
  when(
    service.install(
      any,
      channel: anyNamed('channel'),
      classic: anyNamed('classic'),
    ),
  ).thenAnswer((_) async => 'id');
  when(
    service.refresh(
      any,
      channel: anyNamed('channel'),
      classic: anyNamed('classic'),
    ),
  ).thenAnswer((_) async => 'id');
  when(service.refreshMany(any)).thenAnswer((_) async => 'id');
  when(service.remove(any)).thenAnswer((_) async => 'id');
  when(service.revert(any)).thenAnswer((_) async => 'id');
  when(service.hasPreviousRevision(any))
      .thenAnswer((_) async => localSnap != null);
  when(service.find(filter: SnapFindFilter.refresh))
      .thenAnswer((_) async => refreshableSnaps ?? []);
  when(service.find(name: anyNamed('name')))
      .thenAnswer((_) async => [if (storeSnap != null) storeSnap]);
  when(service.getSnaps()).thenAnswer((_) async => installedSnaps ?? []);
  when(service.getSnaps(filter: SnapsFilter.refreshInhibited)).thenAnswer(
    (_) async =>
        installedSnaps?.where((s) => s.refreshInhibit != null).toList() ?? [],
  );
  when(service.getChanges(name: anyNamed('name')))
      .thenAnswer((_) async => changes ?? []);
  when(service.watchChange(any)).thenAnswer(
    (_) => Stream.fromIterable(
      changes ?? [SnapdChange(id: '', spawnTime: DateTime(1970), ready: true)],
    ),
  );
  when(service.abortChange(any))
      .thenAnswer((_) async => SnapdChange(id: '', spawnTime: DateTime.now()));
  when(
    service.installMany(
      any,
    ),
  ).thenAnswer((_) async => 'id');
  when(service.getStoreSnaps(any)).thenAnswer(
    (_) => Stream.value(
      List<Snap>.generate(
        storeSnapsCount!,
        (index) => storeSnap!,
        growable: false,
      ),
    ),
  );
  registerMockService<SnapdService>(service);
  return service;
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
MockPackageKitClient createMockPackageKitClient({
  PackageKitTransaction? transaction,
}) {
  final client = MockPackageKitClient();
  when(client.createTransaction()).thenAnswer(
    (_) async => transaction ?? createMockPackageKitTransaction(),
  );
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
    await Future<void>.delayed(Duration.zero);
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
  when(transaction.installFiles(any))
      .thenAnswer((_) async => unawaited(emitEvents()));
  when(transaction.getDetailsLocal(any))
      .thenAnswer((_) async => unawaited(emitEvents()));
  when(transaction.whatProvides(any))
      .thenAnswer((_) async => unawaited(emitEvents()));
  when(transaction.updatePackages(any))
      .thenAnswer((_) async => unawaited(emitEvents()));
  when(transaction.getUpdates(filter: anyNamed('filter')))
      .thenAnswer((_) async => unawaited(emitEvents()));
  when(transaction.getDetails(any))
      .thenAnswer((_) async => unawaited(emitEvents()));
  when(transaction.cancel()).thenAnswer((_) async {});
  return transaction;
}

@GenerateMocks([RatingsService])
MockRatingsService registerMockRatingsService({
  Rating? rating,
  List<Vote>? snapVotes,
}) {
  final service = MockRatingsService();
  when(service.getRating(any, any)).thenAnswer(
    (_) async =>
        rating ??
        const Rating(
          snapId: '',
          totalVotes: 0,
          ratingsBand: RatingsBand.insufficientVotes,
          snapName: '',
        ),
  );
  when(service.getSnapVotes(any)).thenAnswer((_) async => snapVotes ?? []);
  registerMockService<RatingsService>(service);

  return service;
}

@GenerateMocks([RatingsClient])
MockRatingsClient createMockRatingsClient({
  String? token,
  Rating? rating,
  List<Vote>? snapVotes,
  List<ChartData>? chartData,
}) {
  final client = MockRatingsClient();
  when(client.authenticate(any)).thenAnswer((_) async => token ?? '');
  when(client.getRating(any, any, any)).thenAnswer(
    (_) async =>
        rating ??
        const Rating(
          snapId: '',
          totalVotes: 0,
          ratingsBand: RatingsBand.insufficientVotes,
          snapName: '',
        ),
  );
  when(client.getSnapVotes(any, any)).thenAnswer((_) async => snapVotes ?? []);
  when(client.getChart(any, any, any)).thenAnswer((_) async => chartData ?? []);
  return client;
}

@GenerateMocks([AppstreamService])
MockAppstreamService createMockAppstreamService({
  AppstreamComponent? component,
  List<AppstreamComponent>? components,
  bool initialized = true,
}) {
  final appstream = MockAppstreamService();
  when(appstream.initialized).thenReturn(initialized);
  when(appstream.init()).thenAnswer((_) async {});
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
  when(appstream.components)
      .thenReturn(components ?? [if (component != null) component]);

  registerMockService<AppstreamService>(appstream);
  addTearDown(unregisterService<AppstreamService>);
  return appstream;
}

@GenerateMocks([PackageKitService])
MockPackageKitService createMockPackageKitService({
  PackageKitPackageInfo? packageInfo,
  PackageKitPackageDetails? packageDetails,
  PackageKitUpdateDetailEvent? packageUpdates,
  Iterable<PackageKitPackageEvent>? packageEvents,
  List<PackageKitPackageInfo>? availableUpdates,
  Map<String, PackageKitPackageDetails>? packageDetailsMany,
  Map<String, PackageKitPackageEvent?>? resolveMap,
  int transactionId = 0,
  Future<void>? waitTransaction,
  Stream<PackageKitServiceError> errorStream = const Stream.empty(),
}) {
  final packageKit = MockPackageKitService();
  when(packageKit.activateService()).thenAnswer((_) async {});
  when(packageKit.resolve(any)).thenAnswer((invocation) async {
    final names = invocation.positionalArguments[0] as List<String>;
    if (resolveMap != null) {
      return {for (final name in names) name: resolveMap[name]};
    }
    return {for (final name in names) name: packageInfo};
  });
  when(
    packageKit.resolve(any, installedOnly: anyNamed('installedOnly')),
  ).thenAnswer((invocation) async {
    final names = invocation.positionalArguments[0] as List<String>;
    if (resolveMap != null) {
      return {for (final name in names) name: resolveMap[name]};
    }
    return {for (final name in names) name: packageInfo};
  });
  when(packageKit.getDetailsLocal(any)).thenAnswer((_) async => packageDetails);
  when(packageKit.getDetailsMany(any))
      .thenAnswer((_) async => packageDetailsMany ?? {});
  when(packageKit.getAllAvailableUpdates())
      .thenAnswer((_) async => availableUpdates ?? []);
  when(packageKit.install(any)).thenAnswer((_) async => transactionId);
  when(packageKit.installAll(any)).thenAnswer((_) async => transactionId);
  when(packageKit.installLocal(any)).thenAnswer((_) async => transactionId);
  when(packageKit.getUpdates(any)).thenAnswer((_) async => packageUpdates);
  when(packageKit.update(any)).thenAnswer((_) async => transactionId);
  when(packageKit.whatProvides(any)).thenAnswer((_) async => packageEvents!);
  when(packageKit.remove(any)).thenAnswer((_) async => transactionId);
  when(packageKit.cancelTransaction(any)).thenAnswer((_) async {});
  when(packageKit.errorStream).thenAnswer((_) => errorStream);
  when(packageKit.waitTransaction(any))
      .thenAnswer((_) async => waitTransaction);

  registerMockService<PackageKitService>(packageKit);
  addTearDown(unregisterService<PackageKitService>);
  return packageKit;
}

@GenerateMocks([
  MultiSnapModel,
  Vote,
])
class _Dummy {} // ignore: unused_element

class EmptyInstalledDebs extends InstalledDebs {
  @override
  Future<List<ManageDebData>> build() async => [];
}

class EmptyDebUpdates extends DebUpdates {
  @override
  Future<List<ManageDebData>> build() async => [];
}

final emptyDebOverrides = [
  installedDebsProvider.overrideWith(EmptyInstalledDebs.new),
  debUpdatesProvider.overrideWith(EmptyDebUpdates.new),
];

class DebMockEntry {
  const DebMockEntry({
    required this.id,
    required this.name,
    String? packageName,
    this.version = '1.0',
    this.updateVersion,
    this.size,
  }) : packageName = packageName ?? id;

  final String id;
  final String name;
  final String packageName;
  final String version;
  final String? updateVersion;
  final int? size;

  bool get hasUpdate => updateVersion != null && updateVersion != version;
}

/// Registers mock AppstreamService and PackageKitService configured for the
/// given [entries].
void registerDebMocks(List<DebMockEntry> entries) {
  final components = [
    for (final e in entries)
      createAppstreamComponent(
        id: e.id,
        name: e.name,
        packageName: e.packageName,
      ),
  ];
  createMockAppstreamService(components: components);

  final resolveMap = <String, PackageKitPackageEvent?>{
    for (final e in entries)
      e.packageName: PackageKitPackageEvent(
        info: PackageKitInfo.installed,
        packageId: PackageKitPackageId(name: e.packageName, version: e.version),
        summary: e.name,
      ),
  };

  final availableUpdates = <PackageKitPackageEvent>[
    for (final e in entries)
      if (e.hasUpdate)
        PackageKitPackageEvent(
          info: PackageKitInfo.available,
          packageId: PackageKitPackageId(
            name: e.packageName,
            version: e.updateVersion!,
          ),
          summary: '${e.name} update',
        ),
  ];

  final detailsMap = <String, PackageKitDetailsEvent>{
    for (final e in entries)
      if (e.size != null)
        e.packageName: PackageKitDetailsEvent(
          packageId:
              PackageKitPackageId(name: e.packageName, version: e.version),
          size: e.size!,
        ),
  };

  createMockPackageKitService(
    availableUpdates: availableUpdates,
    packageDetailsMany: detailsMap,
    resolveMap: resolveMap,
  );
}

AppstreamComponent createAppstreamComponent({
  String? id,
  String? name,
  String? packageName,
  AppstreamComponentType type = AppstreamComponentType.desktopApplication,
  List<AppstreamLaunchable>? launchables,
}) {
  return AppstreamComponent(
    id: id ?? 'test-component',
    type: type,
    package: packageName ?? 'test-package',
    name: {'C': name ?? 'Test Component'},
    summary: const {'C': 'A test component'},
    launchables:
        launchables ?? [const AppstreamLaunchableDesktopId('test.desktop')],
  );
}

ManageDebData createManageDebData({
  String? id,
  String? name,
  String? packageName,
  String? version,
  bool hasUpdate = false,
  String? updateVersion,
  PackageKitPackageId? updatePackageId,
  int? size,
  List<AppstreamLaunchable>? launchables,
}) {
  final component = createAppstreamComponent(
    id: id,
    name: name,
    packageName: packageName,
    launchables: launchables,
  );
  final packageInfo = PackageKitPackageInfo(
    info: PackageKitInfo.installed,
    packageId: PackageKitPackageId(
      name: packageName ?? 'test-package',
      version: version ?? '1.0',
    ),
    summary: 'summary',
  );
  return ManageDebData(
    component: component,
    packageInfo: packageInfo,
    hasUpdate: hasUpdate,
    updateVersion: updateVersion,
    updatePackageId: updatePackageId,
    size: size,
  );
}

Snap createSnap({
  String? id,
  String? name,
  int? revision,
  String? version,
  String? channel,
  String? base,
  String? contact,
  String? description,
  String? type,
  List<SnapApp>? apps,
  List<SnapCategory>? categories,
  Map<String, SnapChannel>? channels,
  List<String>? commonIds,
  SnapConfinement? confinement,
  bool? devmode,
  int? downloadSize,
  DateTime? hold,
  DateTime? installDate,
  int? installedSize,
  bool? jailmode,
  String? license,
  List<SnapMedia>? media,
  String? mountedFrom,
  bool? private,
  SnapPublisher? publisher,
  SnapStatus? status,
  String? storeUrl,
  String? summary,
  String? title,
  String? trackingChannel,
  List<String>? tracks,
  String? website,
  RefreshInhibit? refreshInhibit,
}) {
  return Snap(
    id: id ?? '',
    name: name ?? '',
    revision: revision ?? 0,
    version: version ?? '',
    channel: channel ?? '',
    contact: contact ?? '',
    description: description ?? '',
    type: type ?? '',
    base: base,
    apps: apps ?? [],
    categories: categories ?? [],
    channels: channels ?? {},
    commonIds: commonIds ?? [],
    confinement: confinement ?? SnapConfinement.strict,
    devmode: devmode ?? false,
    downloadSize: downloadSize,
    hold: hold,
    installDate: installDate,
    installedSize: installedSize,
    jailmode: jailmode ?? false,
    license: license,
    media: media ?? [],
    mountedFrom: mountedFrom,
    private: private ?? false,
    publisher: publisher,
    status: status ?? SnapStatus.unknown,
    storeUrl: storeUrl,
    summary: summary ?? '',
    title: title,
    trackingChannel: trackingChannel,
    tracks: tracks ?? [],
    website: website,
    refreshInhibit: refreshInhibit,
  );
}
