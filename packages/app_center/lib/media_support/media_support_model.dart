import 'package:app_center/packagekit/logger.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:packagekit/packagekit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'media_support_model.freezed.dart';
part 'media_support_model.g.dart';

const mediaSupportPackages = [
  'ubuntu-restricted-addons',
  'gstreamer1.0-fdkaac',
];

enum MediaSupportAction { install, update, uninstall }

@freezed
abstract class MediaSupportState with _$MediaSupportState {
  const factory MediaSupportState({
    required Map<String, PackageKitPackageInfo?> packages,
    required List<PackageKitPackageId> updatePackageIds,
    int? size,
    int? activeTransactionId,
    MediaSupportAction? activeAction,
    MediaSupportAction? lastAction,
    @Default(false) bool hasError,
  }) = _MediaSupportState;

  const MediaSupportState._();

  bool get isInstalled => mediaSupportPackages.every(
    (name) => packages[name]?.info == PackageKitInfo.installed,
  );

  List<PackageKitPackageId> get missingIds => [
    for (final name in mediaSupportPackages)
      if (packages[name]?.info != PackageKitInfo.installed)
        packages[name]?.packageId ??
            PackageKitPackageId(name: name, version: ''),
  ];

  List<PackageKitPackageId> get installedIds => [
    for (final name in mediaSupportPackages)
      if (packages[name]?.info == PackageKitInfo.installed)
        packages[name]!.packageId,
  ];
}

@riverpod
class MediaSupportModel extends _$MediaSupportModel {
  final _packageKit = getService<PackageKitService>();
  bool _busy = false;

  @override
  Future<MediaSupportState> build() async {
    await _packageKit.activateService();
    return _load();
  }

  Future<MediaSupportState> _load() async {
    final packages = await _packageKit.resolve(mediaSupportPackages);
    final updates = await _packageKit.getUpdates();
    final updatePackageIds = updates
        .where((u) => mediaSupportPackages.contains(u.packageId.name))
        .map((u) => u.packageId)
        .toList();
    final data = MediaSupportState(
      packages: packages,
      updatePackageIds: updatePackageIds,
    );
    if (data.isInstalled) return data;

    try {
      final planned = await _packageKit.simulateInstall(data.missingIds);
      final ids = planned.map((info) => info.packageId).toSet().toList();
      return data.copyWith(size: await _getSize(ids));
    } on Exception catch (error) {
      log.warning('Could not estimate media support install size: $error');
      final ids = packages.values
          .whereType<PackageKitPackageInfo>()
          .where((info) => info.info != PackageKitInfo.installed)
          .map((info) => info.packageId)
          .toList();
      try {
        return data.copyWith(size: await _getSize(ids));
      } on Exception catch (error) {
        log.warning('Could not get media support package sizes: $error');
        return data;
      }
    }
  }

  Future<int?> _getSize(List<PackageKitPackageId> ids) async {
    if (ids.isEmpty) return null;
    var size = 0;
    // Details are keyed by name, so query architectures separately.
    for (final group in ids.groupListsBy((id) => id.arch).values) {
      final details = await _packageKit.getDetails(group);
      if (group.any((id) => !details.containsKey(id.name))) return null;
      size += details.values.map((detail) => detail.size).sum;
    }
    return size;
  }

  Future<void> install() => _runAction(
    MediaSupportAction.install,
    () => _packageKit.installAll(state.value!.missingIds),
  );

  Future<void> updatePackages() => _runAction(
    MediaSupportAction.update,
    () => _packageKit.updateAllPackages(state.value!.updatePackageIds),
  );

  Future<void> uninstall() => _runAction(
    MediaSupportAction.uninstall,
    () => _packageKit.removeAll(state.value!.installedIds),
  );

  Future<void> retry() => switch (state.value?.lastAction) {
    MediaSupportAction.install => install(),
    MediaSupportAction.update => updatePackages(),
    MediaSupportAction.uninstall => uninstall(),
    null => Future.value(),
  };

  Future<void> cancel() async {
    final id = state.value?.activeTransactionId;
    if (id == null) return;
    try {
      await _packageKit.cancelTransaction(id);
    } on Exception catch (_) {
      // Cancellation can be refused; the transaction continues.
    }
  }

  Future<void> _runAction(
    MediaSupportAction action,
    Future<int> Function() start,
  ) async {
    if (_busy || state.value == null) return;
    _busy = true;
    final link = ref.keepAlive();
    state = AsyncData(
      state.value!.copyWith(
        activeAction: action,
        lastAction: action,
        hasError: false,
      ),
    );
    try {
      final id = await start();
      state = AsyncData(
        state.value!.copyWith(
          activeTransactionId: id,
          activeAction: action,
          lastAction: action,
          hasError: false,
        ),
      );
      await _packageKit.waitTransaction(id);
      final load = await _load();
      state = AsyncData(load);
    } on PackageKitTransactionCancelled catch (_) {
      state = AsyncData(
        state.value!.copyWith(
          activeTransactionId: null,
          activeAction: null,
          lastAction: action,
          hasError: false,
        ),
      );
    } on PackageKitTransactionError catch (error) {
      state = AsyncData(
        state.value!.copyWith(
          activeTransactionId: null,
          activeAction: null,
          lastAction: action,
          hasError: error.exit != PackageKitExit.cancelled,
        ),
      );
    } on Exception catch (_) {
      state = AsyncData(
        state.value!.copyWith(
          activeTransactionId: null,
          activeAction: null,
          lastAction: action,
          hasError: true,
        ),
      );
    } finally {
      _busy = false;
      link.close();
    }
  }
}
