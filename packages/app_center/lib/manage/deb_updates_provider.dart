import 'package:app_center/manage/local_deb_providers.dart';
import 'package:app_center/manage/manage_app_data.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'deb_updates_provider.g.dart';

@Riverpod(keepAlive: true)
class DebUpdates extends _$DebUpdates {
  @override
  Future<List<ManageDebData>> build() async {
    final installedDebs = await ref.watch(installedDebsProvider.future);
    final packageKit = getService<PackageKitService>();

    // Get all available updates in batch call
    final allUpdates = await packageKit.getAllAvailableUpdates();

    // Build a map of package names to their update info
    final updateInfoByName = <String, PackageKitPackageInfo>{};
    for (final update in allUpdates) {
      updateInfoByName[update.packageId.name] = update;
    }

    // Filter installed debs to those with updates
    final debsWithUpdates = <ManageDebData>[];
    for (final deb in installedDebs) {
      final updateInfo = updateInfoByName[deb.packageInfo.packageId.name];
      if (updateInfo != null &&
          updateInfo.packageId.version != deb.packageInfo.packageId.version) {
        debsWithUpdates.add(
          deb.copyWith(
            hasUpdate: true,
            updateVersion: updateInfo.packageId.version,
            updatePackageId: updateInfo.packageId,
          ),
        );
      }
    }

    return debsWithUpdates;
  }

  /// Used to remove a deb from the updates list without reloading the whole provider.
  /// Should be used after a deb is successfully updated.
  void removeFromList(String debId) {
    if (!state.hasValue) return;
    state = AsyncData(
      state.value!.where((d) => d.id != debId).toList(),
    );
  }
}

/// Returns the update info for a deb, if an update exists.
@Riverpod(keepAlive: true)
ManageDebData? debUpdateInfo(Ref ref, String debId) {
  final debUpdates = ref.watch(debUpdatesProvider);
  return debUpdates.whenOrNull(
    data: (updates) => updates.where((d) => d.id == debId).firstOrNull,
  );
}
