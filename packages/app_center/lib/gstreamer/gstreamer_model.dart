import 'package:app_center/gstreamer/gstreamer_resource.dart';
import 'package:app_center/packagekit/packagekit_service.dart';
import 'package:collection/collection.dart';
import 'package:dbus/dbus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:packagekit/packagekit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'gstreamer_model.freezed.dart';
part 'gstreamer_model.g.dart';

@freezed
class GStreamerData with _$GStreamerData {
  factory GStreamerData({
    required List<PackageKitPackageEvent> packageInfos,
    int? activeTransactionId,
  }) = _GStreamerData;

  GStreamerData._();

  bool get isInstalled =>
      packageInfos.every((p) => p.info == PackageKitInfo.installed);

  bool get canInstall => !isInstalled && activeTransactionId == null;
  bool get canCancel => activeTransactionId != null;
}

@riverpod
class GstreamerModel extends _$GstreamerModel {
  @override
  Future<GStreamerData> build(
    GstResourceCollection resources,
  ) async {
    final packageKit = getService<PackageKitService>();
    await packageKit.activateService();

    return _getPackageInfos();
  }

  Future<GStreamerData> _getPackageInfos() async {
    final packageKit = getService<PackageKitService>();

    final providers = await Future.wait(
      resources.list.map((resource) => packageKit.whatProvides(resource.id)),
    );
    final packageIds = providers.flattened.map((p) => p.packageId);
    final packages =
        await Future.wait(packageIds.map((id) => packageKit.resolve(id.name)));
    return GStreamerData(packageInfos: packages.nonNulls.toList());
  }

  Future<void> _emitInstallationFinishedSignal() async {
    final client = DBusClient.session();
    final object = DBusObject(
      DBusObjectPath('/io/snapcraft/Store/PackageKitInstaller/GStreamer'),
    );

    await client.registerObject(object);
    await object.emitSignal(
      'io.snapcraft.Store.PackageKitInstaller',
      'InstallationFinished',
      [
        DBusArray.string(resources.list.map((r) => r.id)),
      ],
    );

    await client.close();
  }

  Future<void> installAll() async {
    final packageKit = getService<PackageKitService>();

    final installTransaction = await packageKit
        .installAll(state.value!.packageInfos.nonNulls.map((p) => p.packageId));
    state = AsyncData(
      state.value!.copyWith(activeTransactionId: installTransaction),
    );
    await packageKit.waitTransaction(installTransaction);

    final latestPackageInfo = await _getPackageInfos();
    if (latestPackageInfo.isInstalled) {
      await _emitInstallationFinishedSignal();
    }

    state = AsyncData(latestPackageInfo);
  }

  Future<void> cancel() async {
    assert(
      state.value?.activeTransactionId != null,
      'cancel() called without active transaction',
    );

    final packageKit = getService<PackageKitService>();
    await packageKit.cancelTransaction(state.value!.activeTransactionId!);
    state = AsyncData(await _getPackageInfos());
  }
}
