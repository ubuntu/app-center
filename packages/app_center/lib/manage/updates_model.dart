import 'dart:async';

import 'package:app_center/constants.dart';
import 'package:app_center/providers/error_stream_provider.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'updates_model.g.dart';
part 'updates_model.freezed.dart';

@freezed
class SnapListState with _$SnapListState {
  factory SnapListState({
    @Default([]) Iterable<Snap> snaps,
    @Default(true) bool hasInternet,
  }) = _snapListState;

  const SnapListState._();

  bool get isNotEmpty => snaps.isNotEmpty;
  bool get isEmpty => snaps.isEmpty;
  int get length => snaps.length;
  Snap get single => snaps.single;

  Snap? getSnap(String snapName) {
    return snaps.firstWhereOrNull((snap) => snap.name == snapName);
  }
}

final currentlyRefreshAllSnapsProvider = StateProvider<List<String>>((_) => []);
final isSilentlyiCheckingUpdatesProvider = StateProvider<bool>((_) => false);

@Riverpod(keepAlive: true)
bool hasUpdate(HasUpdateRef ref, String snapName) {
  final updatesModel = ref.watch(updatesModelProvider);
  return updatesModel.whenOrNull(
        data: (updatesData) => updatesData.snaps.any((s) => s.name == snapName),
      ) ??
      false;
}

/// Used to see which snaps that are installed but need to be restarted to be
/// refreshed (or be forced to restart after the proceedTime).
@riverpod
Future<List<Snap>> refreshInhibitSnaps(RefreshInhibitSnapsRef ref) async {
  final snapd = getService<SnapdService>();
  return snapd.getSnaps(filter: SnapsFilter.refreshInhibited);
}

@Riverpod(keepAlive: true)
class UpdatesModel extends _$UpdatesModel {
  late final _snapd = getService<SnapdService>();

  @override
  Future<SnapListState> build() async {
    final result = fetchRefreshableSnaps();
    return result;
  }

  Future<void> silentUpdatesCheck() async {
    ref.read(isSilentlyiCheckingUpdatesProvider.notifier).state = true;
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
    } finally {
      ref.read(isSilentlyiCheckingUpdatesProvider.notifier).state = false;
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

  /// Used to remove a snap from the list without reloading the whole provider.
  /// Should be used when a snap is uninstalled directly from the manage page
  /// list for example.
  void removeFromList(String snapName) {
    if (!state.hasValue) return;
    state = AsyncData(
      state.value!.copyWith(
        snaps: state.value!.snaps.where((s) => s.name != snapName),
      ),
    );
  }

  Future<void> refreshAll() async {
    if (!state.hasValue) return;
    try {
      final refreshableSnapNames = state.value?.snaps
              .where((s) => s.refreshInhibit == null)
              .map((s) => s.name)
              .toList() ??
          [];
      final refreshFutures = refreshableSnapNames.map((snapName) async {
        return ref.read(SnapModelProvider(snapName).notifier).refresh();
      });
      ref.read(currentlyRefreshAllSnapsProvider.notifier).state =
          refreshableSnapNames;
      await Future.wait(refreshFutures);
    } on SnapdException catch (e) {
      ref.read(errorStreamControllerProvider).add(e);
    }
    ref.read(currentlyRefreshAllSnapsProvider.notifier).state = [];
    ref.invalidateSelf();
  }

  Future<void> cancelRefreshAll() async {
    final snapNames = ref.read(currentlyRefreshAllSnapsProvider);
    if (snapNames.isEmpty) return;

    try {
      final cancelFutures = snapNames.map(
        (snapName) => ref.read(SnapModelProvider(snapName).notifier).cancel(),
      );
      await Future.wait(cancelFutures);
    } on SnapdException catch (e) {
      ref.read(errorStreamControllerProvider).add(e);
    } finally {
      ref.read(currentlyRefreshAllSnapsProvider.notifier).state = [];
    }
  }
}

extension IterableSnapExtensions on Iterable<Snap> {
  List<String> get snapNames => map((snap) => snap.name).toList();
}

/// This runs the [function] and if it throws an exception that indicates that
/// there is a network problem it returns a [SnapListState] with an empty list
/// and `SnapListState.hasInternet` as false.
///
/// Any other exceptions will be rethrown.
Future<SnapListState> connectionCheck(
  Future<Iterable<Snap>> Function() function,
  Ref ref,
) async {
  try {
    return SnapListState(snaps: await function());
  } on SnapdException catch (e) {
    switch (e.kind) {
      // When kind is null it is most likely a problem with the internet
      // connection.
      case 'network-timeout':
      case null:
        return Future.value(SnapListState(hasInternet: false));
      // Since the snap is just not installed when 'snap-not-found is thrown
      // we can ignore this exception.
      default:
        rethrow;
    }
  }
}
