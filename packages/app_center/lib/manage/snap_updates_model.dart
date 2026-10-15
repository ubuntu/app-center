import 'dart:async';

import 'package:app_center/constants.dart';
import 'package:app_center/error/error.dart';
import 'package:app_center/providers/error_stream_provider.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'snap_updates_model.g.dart';
part 'snap_updates_model.freezed.dart';

@freezed
abstract class SnapListState with _$SnapListState {
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

/// A bulk refresh started by [SnapUpdatesModel.refreshAll].
///
/// `snapNames` is filled as soon as the refresh starts, so the affected snaps
/// are locked while snapd asks for authorisation. `changeId` follows once snapd
/// has accepted the request, and `snapNames` is then narrowed to the snaps that
/// snapd actually put in the change.
typedef RefreshAllSnaps = ({String? changeId, List<String> snapNames});

final currentlyRefreshAllSnapsProvider = StateProvider<RefreshAllSnaps>(
  (_) => (changeId: null, snapNames: const []),
);
final isSilentlyCheckingUpdatesProvider = StateProvider<bool>((_) => false);

@Riverpod(keepAlive: true)
bool hasUpdate(Ref ref, String snapName) {
  final updatesModel = ref.watch(snapUpdatesModelProvider);
  return updatesModel.whenOrNull(
        data: (updatesData) => updatesData.snaps.any((s) => s.name == snapName),
      ) ??
      false;
}

/// Returns the available update version for a snap, if an update exists.
@Riverpod(keepAlive: true)
String? updateVersion(Ref ref, String snapName) {
  final updatesModel = ref.watch(snapUpdatesModelProvider);
  return updatesModel.whenOrNull(
    data: (updatesData) => updatesData.getSnap(snapName)?.version,
  );
}

/// Returns all locally installed snaps.
@riverpod
Future<SnapListState> localSnaps(Ref ref) {
  return connectionCheck(getService<SnapdService>().getSnaps, ref);
}

/// Returns the currently installed version for a snap.
@riverpod
Future<String?> localVersion(Ref ref, String snapName) async {
  final snaps = await ref.watch(localSnapsProvider.future);
  return snaps.getSnap(snapName)?.version;
}

/// Used to see which snaps that are installed but need to be restarted to be
/// refreshed (or be forced to restart after the proceedTime).
@riverpod
Future<List<Snap>> refreshInhibitSnaps(Ref ref) async {
  final snapd = getService<SnapdService>();
  return snapd.getSnaps(filter: SnapsFilter.refreshInhibited);
}

@Riverpod(keepAlive: true)
class SnapUpdatesModel extends _$SnapUpdatesModel {
  late final _snapd = getService<SnapdService>();

  /// Set when the user aborts the change, so that the error snapd records for
  /// an aborted change is not shown back to them as a failure.
  bool _abortRequested = false;

  @override
  Future<SnapListState> build() async {
    final result = fetchRefreshableSnaps();
    return result;
  }

  Future<void> silentUpdatesCheck() async {
    ref.read(isSilentlyCheckingUpdatesProvider.notifier).state = true;
    try {
      final newSnapListState = await fetchRefreshableSnaps();
      final isSameList = const ListEquality().equals(
        state.value?.snaps.toList() ?? [],
        newSnapListState.snaps.toList(),
      );
      if (!isSameList ||
          newSnapListState.hasInternet != state.value?.hasInternet) {
        state = AsyncData(newSnapListState);
      }
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

  /// Used to add a snap from the list without reloading the whole provider.
  /// Should be used when a snap is uninstalled directly from the manage page
  /// list for example.
  void addToList(Snap snap) {
    if (!state.hasValue) return;
    state = AsyncData(
      state.value!.copyWith(
        snaps: state.value!.snaps.toList()..add(snap),
      ),
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
    if (!state.hasValue) {
      return;
    }
    try {
      final refreshableSnapNames =
          state.value?.snaps.map((s) => s.name).toList() ?? [];
      if (refreshableSnapNames.isEmpty) {
        return;
      }
      _abortRequested = false;
      final refreshing = ref.read(currentlyRefreshAllSnapsProvider.notifier);
      refreshing.state = (changeId: null, snapNames: refreshableSnapNames);

      // An empty list asks snapd to refresh everything it can. Held snaps and
      // snaps with running apps are local state that the store list cannot
      // see, so snapd is the one to decide. It leaves them out of the change
      // without reporting them, though, so they do not show up as errors.
      final changeId = await _snapd.refreshMany([]);
      // Only used to narrow the list. If snapd cannot say, the store list is a
      // safe superset and the refresh itself carries on regardless.
      final snapNamesInChange = await _snapd
          .getChange(changeId)
          .then((change) => change.snapNames)
          .catchError((_) => <String>[], test: (e) => e is SnapdException);
      refreshing.state = (
        changeId: changeId,
        snapNames: snapNamesInChange.isNotEmpty
            ? snapNamesInChange
            : refreshableSnapNames,
      );
      await _snapd.waitChange(changeId);

      // Waiting only tells us the change is over, not how it went. A snap that
      // fails inside it does not fail the request, so its error has to be read
      // from the finished change.
      final finished = await _snapd
          .getChange(changeId)
          .then<SnapdChange?>((change) => change)
          .catchError((_) => null, test: (e) => e is SnapdException);
      final err = finished?.err;
      if (err != null && !_abortRequested) {
        final errors = _errorsBySnap(err);
        ref.read(errorStreamControllerProvider).add(
          switch (errors.length) {
            0 => SnapdException(message: err),
            1 => errors.values.first,
            _ => ConsolidatedSnapdException(errors),
          },
        );
      }
    } on SnapdException catch (e) {
      if (e.kind != 'auth-cancelled') {
        ref.read(errorStreamControllerProvider).add(e);
      }
    } finally {
      ref.read(currentlyRefreshAllSnapsProvider.notifier).state = (
        changeId: null,
        snapNames: const [],
      );
      ref.invalidateSelf();
      ref.invalidate(localSnapsProvider);
    }
  }

  /// Aborts the change started by [refreshAll]. The state is cleared by
  /// [refreshAll] once the aborted change finishes, so a failed attempt leaves
  /// the change id in place and can be retried.
  Future<void> cancelRefreshAll() async {
    final changeId = ref.read(currentlyRefreshAllSnapsProvider).changeId;
    if (changeId == null) return;

    _abortRequested = true;
    try {
      await _snapd.abortChange(changeId);
    } on SnapdException catch (e) {
      ref.read(errorStreamControllerProvider).add(e);
    }
  }

  /// Splits the error of a finished change by snap, so it can be shown in the
  /// same per-snap form as when each snap was refreshed on its own. snapd
  /// reports one `- ` line per failed task, and task summaries name their snap
  /// in quotes. If any task line does not name one, nothing is split, so that
  /// the caller shows the whole message rather than drop part of it.
  static Map<String, SnapdException> _errorsBySnap(String err) {
    final messages = <String, List<String>>{};
    for (final line in err.split('\n').map((l) => l.trim())) {
      if (!line.startsWith('- ')) continue;
      final snapName = RegExp('"([^"]+)"').firstMatch(line)?.group(1);
      if (snapName == null) return {};
      (messages[snapName] ??= []).add(line.substring(2));
    }
    return messages.map(
      (snapName, lines) =>
          MapEntry(snapName, SnapdException(message: lines.join('\n'))),
    );
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
