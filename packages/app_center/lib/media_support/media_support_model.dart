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
class MediaSupportState with _$MediaSupportState {
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
    final ids = packages.values.whereType<PackageKitPackageInfo>().map(
      (info) => info.packageId,
    );
    final details = await _packageKit.getDetails(ids.toList());
    return MediaSupportState(
      packages: packages,
      updatePackageIds: updatePackageIds,
      size: details.isEmpty ? null : details.values.map((x) => x.size).sum,
    );
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

  Future<void> retry() => switch (state.valueOrNull?.lastAction) {
    MediaSupportAction.install => install(),
    MediaSupportAction.update => updatePackages(),
    MediaSupportAction.uninstall => uninstall(),
    null => Future.value(),
  };

  Future<void> cancel() async {
    final id = state.valueOrNull?.activeTransactionId;
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
    if (_busy || state.valueOrNull == null) return;
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
      state = AsyncData(await _load());
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
