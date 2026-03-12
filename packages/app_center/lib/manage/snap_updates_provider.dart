import 'package:app_center/constants.dart';
import 'package:app_center/manage/deb_updates_provider.dart';
import 'package:app_center/manage/local_snap_providers.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'snap_updates_provider.g.dart';

final currentlyRefreshAllSnapsProvider = StateProvider<List<String>>((_) => []);
final isSilentlyCheckingUpdatesProvider = StateProvider<bool>((_) => false);

@Riverpod(keepAlive: true)
bool snapHasUpdate(Ref ref, String snapName) {
  final snapUpdates = ref.watch(snapUpdatesProvider);
  return snapUpdates.whenOrNull(
        data: (updatesData) => updatesData.snaps.any((s) => s.name == snapName),
      ) ??
      false;
}

/// Returns the available update version for a snap, if an update exists.
/// The version returned is from the store (the version to update TO).
@riverpod
String? snapUpdateVersion(Ref ref, String snapName) {
  final snapUpdates = ref.watch(snapUpdatesProvider);
  return snapUpdates.whenOrNull(
    data: (updatesData) => updatesData.getSnap(snapName)?.version,
  );
}

/// Returns the currently installed version for a snap.
@riverpod
Future<String?> localVersion(Ref ref, String snapName) async {
  final snapd = getService<SnapdService>();
  try {
    final localSnap = await snapd.getSnap(snapName);
    return localSnap.version;
  } on SnapdException {
    return null;
  }
}

/// Used to see which snaps that are installed but need to be restarted to be
/// refreshed (or be forced to restart after the proceedTime).
@riverpod
Future<List<Snap>> refreshInhibitSnaps(Ref ref) async {
  final snapd = getService<SnapdService>();
  return snapd.getSnaps(filter: SnapsFilter.refreshInhibited);
}

@Riverpod(keepAlive: true)
class SnapUpdates extends _$SnapUpdates {
  late final _snapd = getService<SnapdService>();

  @override
  Future<SnapListState> build() async {
    return fetchRefreshableSnaps();
  }

  Future<void> silentUpdatesCheck() async {
    ref.read(isSilentlyCheckingUpdatesProvider.notifier).state = true;
    try {
      final newSnapListState = await fetchRefreshableSnaps();
      final isSameList = const ListEquality().equals(
        state.valueOrNull?.snaps.toList() ?? [],
        newSnapListState.snaps.toList(),
      );
      if (!isSameList ||
          newSnapListState.hasInternet != state.valueOrNull?.hasInternet) {
        state = AsyncData(newSnapListState);
      }
      // Also refresh deb updates
      ref.invalidate(debUpdatesProvider);
    } finally {
      ref.read(isSilentlyCheckingUpdatesProvider.notifier).state = false;
    }
  }

  Future<SnapListState> fetchRefreshableSnaps() {
    return connectionCheck(
      () => _snapd
          .find(filter: SnapFindFilter.refresh)
          .then((snaps) => snaps.where((s) => s.name != kSnapName)),
      ref,
    );
  }

  /// Used to add a snap to the updates list without reloading the whole provider.
  void addToList(Snap snap) {
    if (!state.hasValue) return;
    state = AsyncData(
      state.value!.copyWith(
        snaps: state.value!.snaps.toList()..add(snap),
      ),
    );
  }

  /// Used to remove a snap from the updates list without reloading the whole provider.
  void removeFromList(String snapName) {
    if (!state.hasValue) return;
    state = AsyncData(
      state.value!.copyWith(
        snaps: state.value!.snaps.where((s) => s.name != snapName),
      ),
    );
  }
}

extension IterableSnapExtensions on Iterable<Snap> {
  List<String> get snapNames => map((snap) => snap.name).toList();
}
