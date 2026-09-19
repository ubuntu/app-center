import 'dart:async';

import 'package:app_center/mapping/identifier_normalization.dart';
import 'package:app_center/mapping/package_format.dart';
import 'package:app_center/mapping/package_format_adapter.dart';
import 'package:app_center/mapping/package_runtime_state.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center/snapd/snapd_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:snapd/snapd.dart';

class SnapPackageAdapter implements PackageFormatAdapter {
  SnapPackageAdapter({
    @visibleForTesting SnapdService? snapd,
    this.pollInterval = const Duration(seconds: 5),
  }) : _snapdService = snapd ?? SnapdService();

  final Duration pollInterval;
  final SnapdService _snapdService;

  @override
  PackageFormat get format => PackageFormat.snap;

  @override
  Future<void> initialize() async {}

  @override
  Future<PackageSourceDescriptor?> findByCommonId(String commonId) async {
    final snaps = await _snapdService.find(
      commonId: commonId,
      scope: SnapFindScope.wide,
    );
    return _firstDescriptor(snaps, (snap) {
      return snap.commonIds.any(
        (id) => normalizeCommonId(id) == normalizeCommonId(commonId),
      );
    });
  }

  @override
  Future<PackageSourceDescriptor?> findByDesktopId(String desktopId) async {
    final snaps = await _snapdService.find(
      query: desktopId,
      scope: SnapFindScope.wide,
    );
    return _firstDescriptor(snaps, (snap) {
      return snap.apps.any(
        (app) =>
            normalizeDesktopId(app.desktopFile) ==
            normalizeDesktopId(desktopId, snapName: snap.name),
      );
    });
  }

  @override
  Future<PackageSourceDescriptor?> findByPackageName(String packageName) async {
    final snaps = await _snapdService.find(
      name: packageName,
      scope: SnapFindScope.wide,
    );
    return _firstDescriptor(
      snaps,
      (snap) => normalizeCommonId(snap.name) == normalizeCommonId(packageName),
    );
  }

  @override
  Stream<PackageRuntimeState> watchRuntimeState(String packageId) async* {
    yield await _runtimeState(packageId);
    await for (final _ in _snapdService.watchChanges(
      name: packageId,
      interval: pollInterval,
    )) {
      yield await _runtimeState(packageId);
    }
  }

  PackageSourceDescriptor? _firstDescriptor(
    Iterable<Snap> snaps,
    bool Function(Snap) matches,
  ) {
    final matching = snaps.where(matches).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return matching.firstOrNull == null
        ? null
        : _descriptorForSnap(matching.first);
  }

  PackageSourceDescriptor _descriptorForSnap(Snap snap) {
    final app = snap.apps.firstWhereOrNull(
      (app) => app.commonId != null || app.desktopFile != null,
    );
    final commonId = app?.commonId ?? snap.commonIds.firstOrNull;
    final desktopId = app?.desktopFile;
    final aliases = {
      ...snap.commonIds,
      ...snap.apps.map((app) => app.commonId).whereType<String>(),
    }.toList()..sort();

    return PackageSourceDescriptor(
      format: format,
      packageId: snap.name,
      commonId: commonId,
      desktopId: desktopId,
      packageName: snap.name,
      aliases: aliases,
      isDesktopApplication: snap.apps.isNotEmpty,
    );
  }

  Future<PackageRuntimeState> _runtimeState(String name) async {
    Snap? localSnap;
    try {
      localSnap = await _snapdService.getSnap(name);
    } on SnapdException catch (error) {
      if (error.kind != 'snap-not-found') rethrow;
    }

    if (localSnap == null) {
      return const PackageRuntimeState(isInstalled: false);
    }

    return PackageRuntimeState(
      isInstalled: true,
      installedVersion: localSnap.version,
      channelOrOrigin: localSnap.trackingChannel,
      isBusy: localSnap.refreshInhibit != null,
    );
  }
}
