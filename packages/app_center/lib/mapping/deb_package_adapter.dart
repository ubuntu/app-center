import 'dart:async';

import 'package:app_center/appstream/appstream_service.dart';
import 'package:app_center/mapping/package_format.dart';
import 'package:app_center/mapping/package_format_adapter.dart';
import 'package:app_center/mapping/package_runtime_state.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center/packagekit/packagekit_service.dart';
import 'package:appstream/appstream.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:packagekit/packagekit.dart';

class DebPackageAdapter implements PackageFormatAdapter {
  DebPackageAdapter({
    @visibleForTesting AppstreamService? appstream,
    @visibleForTesting PackageKitService? packageKit,
    this.pollInterval = const Duration(seconds: 30),
  }) : _appstreamService = appstream ?? AppstreamService(),
       _packageKitService = packageKit ?? PackageKitService();

  final Duration pollInterval;
  final AppstreamService _appstreamService;
  final PackageKitService _packageKitService;

  @override
  PackageFormat get format => PackageFormat.deb;

  @override
  Future<void> initialize() => _appstreamService.init();

  @override
  Future<PackageSourceDescriptor?> findByCommonId(String commonId) async {
    return _descriptorForComponent(
      await _appstreamService.findById(commonId),
    );
  }

  @override
  Future<PackageSourceDescriptor?> findByDesktopId(String desktopId) async {
    return _descriptorForComponent(
      await _appstreamService.findByDesktopId(desktopId),
    );
  }

  @override
  Future<PackageSourceDescriptor?> findByPackageName(
    String packageName,
  ) async {
    return _descriptorForComponent(
      await _appstreamService.findByPackageName(packageName),
    );
  }

  @override
  Stream<PackageRuntimeState> watchRuntimeState(String packageId) async* {
    yield await _runtimeState(packageId);
    yield* Stream.periodic(
      pollInterval,
    ).asyncMap((_) => _runtimeState(packageId));
  }

  PackageSourceDescriptor? _descriptorForComponent(
    AppstreamComponent? component,
  ) {
    if (component == null) return null;

    final desktopId = component.launchables
        .whereType<AppstreamLaunchableDesktopId>()
        .map((launchable) => launchable.desktopId)
        .firstOrNull;
    final aliases = component.provides
        .whereType<AppstreamProvidesId>()
        .map((provide) => provide.id)
        .toList();
    final packageName = component.package;

    return PackageSourceDescriptor(
      format: format,
      packageId: packageName ?? component.id,
      commonId: component.id,
      desktopId: desktopId,
      packageName: packageName,
      aliases: aliases,
      isDesktopApplication:
          component.type == AppstreamComponentType.desktopApplication,
    );
  }

  Future<PackageRuntimeState> _runtimeState(String packageName) async {
    await _packageKitService.activateService();
    final package = (await _packageKitService.resolve([
      packageName,
    ]))[packageName];
    final isInstalled = package?.info == PackageKitInfo.installed;
    final updates = await _packageKitService.getUpdates();
    final update = updates.firstWhereOrNull(
      (candidate) => candidate.packageId.name == packageName,
    );

    return PackageRuntimeState(
      isInstalled: isInstalled,
      installedVersion: isInstalled ? package?.packageId.version : null,
      availableVersion: update?.packageId.version,
      hasUpdate: update != null,
    );
  }
}
