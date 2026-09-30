import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/apps/package_details_backend.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center/snapd/snap_category_enum.dart';
import 'package:app_center/snapd/snap_data.dart';
import 'package:app_center/snapd/snap_launcher.dart';
import 'package:app_center/snapd/snap_model.dart';
import 'package:app_center/snapd/snapd_service.dart';
import 'package:app_center/snapd/snapx.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_logger/ubuntu_logger.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'snap_details_backend.g.dart';

final _log = Logger('snap_details_backend');

/// Installed snap, read independently so a store failure cannot hide it.
@riverpod
Future<Snap?> snapLocalState(Ref ref, String snapName) async {
  try {
    return await getService<SnapdService>().getSnap(snapName);
  } on SnapdException catch (e) {
    if (e.kind == 'snap-not-found') return null;
    rethrow;
  }
}

@riverpod
AsyncValue<PackageSourceSnapshot> snapSourceSnapshot(
  Ref ref,
  String snapName,
) {
  final model = ref.watch(snapModelProvider(snapName));
  if (!model.hasValue && model.hasError) {
    final local = ref.watch(snapLocalStateProvider(snapName));
    if (local.isLoading) return const AsyncLoading();
    final error = AsyncError<PackageSourceSnapshot>(
      model.error!,
      model.stackTrace ?? StackTrace.empty,
    );
    if (!local.hasValue) return error;
    return error.copyWithPrevious(
      AsyncData(snapSnapshotWithoutStore(snapName, local.valueOrNull)),
    );
  }

  final data = model.valueOrNull;
  final changeId = data?.activeChangeId;
  final change = changeId == null
      ? null
      : ref.watch(activeChangeProvider(changeId));
  final localSnap = data?.localSnap;
  final canLaunch =
      localSnap != null && ref.watch(launchProvider(localSnap)).isLaunchable;
  return mapAsyncValue(
    model,
    (data) => snapSnapshotFromData(data, change: change, canLaunch: canLaunch),
  );
}

@visibleForTesting
PackageSourceSnapshot snapSnapshotWithoutStore(String snapName, Snap? local) {
  return PackageSourceSnapshot(
    key: SourceKey(format: PackageFormat.snap, id: snapName),
    installState: local == null
        ? InstallState.notInstalled
        : InstallState.installed,
    appName: FieldState<String>.failed(),
    icon: FieldState<ImageRef>.failed(),
    summary: FieldState<String>.failed(),
    description: FieldState<RichContent>.failed(),
    screenshots: FieldState<List<String>>.failed(),
    publisher: FieldState<Publisher>.failed(),
    categories: FieldState<List<AppCategory>>.failed(),
    confinement: FieldState<AppConfinement>.failed(),
    license: FieldState<String>.failed(),
    links: FieldState<Map<AppLink, String>>.failed(),
    installed: local == null ? null : _installedRelease(local, null),
    installDate: FieldState.fromNullable(local?.installDate),
  );
}

@visibleForTesting
PackageSourceSnapshot snapSnapshotFromData(
  SnapData data, {
  SnapdChange? change,
  bool canLaunch = false,
}) {
  final local = data.localSnap;
  final store = data.storeSnap;
  final snap = data.snap;

  final targets = <PackageTarget>[
    for (final MapEntry(key: name, value: channel)
        in store?.channels.entries ?? <MapEntry<String, SnapChannel>>[])
      PackageTarget(
        id: name,
        label: name,
        isInstalled: local?.trackingChannel == name,
        candidate: _channelRelease(name, channel),
      ),
  ];
  final tracking = local?.trackingChannel;
  final installed = local == null ? null : _installedRelease(local, store);
  if (installed != null &&
      tracking != null &&
      targets.none((t) => t.id == tracking)) {
    targets.add(
      PackageTarget(
        id: tracking,
        label: tracking,
        isInstalled: true,
        candidate: installed,
      ),
    );
  }

  PackageRelease? updateCandidate;
  if (installed != null && data.hasUpdate && tracking != null) {
    final channel = store?.channels[tracking];
    updateCandidate = channel != null
        ? _channelRelease(tracking, channel)
        : PackageRelease(candidateId: 'channel:$tracking', channel: tracking);
  }

  final installCandidate = installed == null
      ? targets
            .firstWhereOrNull(
              (t) => t.id == SnapData.defaultSelectedChannel(local, store),
            )
            ?.candidate
      : null;

  final categories = store?.categories
      .map(
        (category) => SnapCategoryEnum.values.firstWhereOrNull(
          (value) => value.categoryName == category.name,
        ),
      )
      .whereType<AppCategory>()
      .where((category) => category != SnapCategoryEnum.featured)
      .toList();

  return PackageSourceSnapshot(
    key: SourceKey(format: PackageFormat.snap, id: data.name),
    installState: local == null
        ? InstallState.notInstalled
        : InstallState.installed,
    appName: FieldState.value(snap.titleOrName),
    icon: FieldState.fromNullable(
      snap.iconUrl == null ? null : ImageRef.network(snap.iconUrl!),
    ),
    summary: FieldState.value(snap.summary),
    description: FieldState.value(
      RichContent(text: snap.description, type: RichContentType.markdown),
    ),
    screenshots: FieldState.fromNullable(store?.screenshotUrls),
    publisher: FieldState.fromNullable(
      snap.publisher == null
          ? null
          : Publisher(
              name: snap.publisher!.displayName,
              validation: snap.verifiedPublisher
                  ? PublisherValidation.verified
                  : snap.starredPublisher
                  ? PublisherValidation.starred
                  : PublisherValidation.none,
            ),
    ),
    categories: FieldState.fromNullable(categories),
    confinement: FieldState.value(
      AppConfinement.fromSnap((local ?? snap).confinement),
    ),
    license: FieldState.fromNullable(snap.license),
    links: FieldState.value(data.links ?? const {}),
    installDate: FieldState.fromNullable(local?.installDate),
    installed: installed,
    installCandidate: installCandidate,
    updateCandidate: updateCandidate,
    capabilities: PackageCapabilities(
      canLaunch: canLaunch,
      updateBlocked: local?.refreshInhibit != null
          ? DisabledReason.appRunning
          : null,
    ),
    targets: targets,
    activeOperation: data.activeChangeId == null
        ? null
        : ObservedOperation(
            kind: _operationKind(change?.kind, isInstalled: local != null),
            progress: change == null || change.tasks.isEmpty
                ? null
                : change.progress,
            cancellable: !(change?.ready ?? false),
          ),
  );
}

PackageRelease _installedRelease(Snap local, Snap? store) {
  final channel = store?.channels[local.trackingChannel];
  final sameRevision = channel?.revision == '${local.revision}';
  return PackageRelease(
    candidateId: 'rev:${local.revision}',
    version: local.version,
    channel: local.trackingChannel,
    size: FieldState.fromNullable(
      local.installedSize == null
          ? null
          : ByteSize(bytes: local.installedSize!, kind: SizeKind.installed),
    ),
    releaseDate: FieldState.fromNullable(
      sameRevision ? channel?.releasedAt : null,
    ),
    confinement: AppConfinement.fromSnap(local.confinement),
  );
}

PackageRelease _channelRelease(String name, SnapChannel channel) =>
    PackageRelease(
      candidateId: channel.revision != null
          ? 'rev:${channel.revision}'
          : 'channel:$name:${channel.version}',
      version: channel.version,
      channel: name,
      // The store reports 0 when the size is unknown.
      size: FieldState.fromNullable(
        channel.size > 0
            ? ByteSize(bytes: channel.size, kind: SizeKind.download)
            : null,
      ),
      releaseDate: FieldState.value(channel.releasedAt),
      confinement: AppConfinement.fromSnap(channel.confinement),
    );

OperationKind _operationKind(String? kind, {required bool isInstalled}) =>
    switch (kind) {
      'install-snap' => OperationKind.install,
      'remove-snap' => OperationKind.remove,
      'switch-snap' || 'switch-snap-channel' => OperationKind.switchChannel,
      _ when isInstalled => OperationKind.update,
      _ => OperationKind.install,
    };

class SnapDetailsBackend implements PackageDetailsBackend {
  const SnapDetailsBackend();

  @override
  ProviderListenable<AsyncValue<PackageSourceSnapshot>> snapshot(
    SourceKey key,
  ) => snapSourceSnapshotProvider(key.id);

  @override
  Future<void> reconcile(Ref ref, SourceKey key) async {
    ref
      ..invalidate(snapLocalStateProvider(key.id))
      ..invalidate(snapModelProvider(key.id));
    await ref.read(snapModelProvider(key.id).future);
  }

  @override
  Future<OperationOutcome> execute(
    Ref ref,
    SourceKey key,
    PackageCommand command,
  ) async {
    final data = await ref.read(snapModelProvider(key.id).future);
    final notifier = ref.read(snapModelProvider(key.id).notifier);
    final channels = data.storeSnap?.channels ?? const {};

    try {
      switch (command.kind) {
        case OperationKind.install:
          if (data.isInstalled || !channels.containsKey(command.targetId)) {
            return OperationOutcome.failed;
          }
          await notifier.install(channel: command.targetId);
          return OperationOutcome.success;
        case OperationKind.switchChannel:
          if (!data.isInstalled || !channels.containsKey(command.targetId)) {
            return OperationOutcome.failed;
          }
          return await notifier.refresh(
                channel: command.targetId,
                removeFromList: true,
              )
              ? OperationOutcome.success
              : OperationOutcome.failed;
        case OperationKind.update:
          final tracking = data.localSnap?.trackingChannel;
          if (tracking == null ||
              tracking != command.targetId ||
              !channels.containsKey(tracking)) {
            return OperationOutcome.failed;
          }
          return await notifier.refresh(channel: tracking, removeFromList: true)
              ? OperationOutcome.success
              : OperationOutcome.failed;
        case OperationKind.remove:
          if (!data.isInstalled) return OperationOutcome.failed;
          await notifier.remove();
          return OperationOutcome.success;
      }
    } on SnapdException catch (e) {
      _log.error('Snap ${command.kind.name} of ${key.id} failed: $e');
      return e.kind == 'auth-cancelled'
          ? OperationOutcome.cancelled
          : OperationOutcome.failed;
    } on String catch (e) {
      // Failed snapd changes are reported as their error message.
      _log.error('Snap ${command.kind.name} of ${key.id} failed: $e');
      return OperationOutcome.failed;
    }
  }

  @override
  Future<void> cancel(Ref ref, SourceKey key) async {
    try {
      await ref.read(snapModelProvider(key.id).notifier).cancel();
    } on SnapdException catch (e) {
      throw PackageBackendException(e.message);
    } on String catch (e) {
      throw PackageBackendException(e);
    }
  }

  @override
  Future<void> open(Ref ref, SourceKey key) async {
    final local = (await ref.read(snapModelProvider(key.id).future)).localSnap;
    final launcher = local == null ? null : ref.read(launchProvider(local));
    if (launcher == null || !launcher.isLaunchable) {
      throw PackageBackendException('${key.id} is not launchable');
    }
    launcher.open();
  }
}
