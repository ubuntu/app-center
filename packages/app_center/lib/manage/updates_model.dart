import 'dart:async';

import 'package:app_center/providers/error_stream_provider.dart';
import 'package:app_center/snapd/snapd.dart';
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
}

final updateChangeIdProvider = StateProvider<String?>((_) => null);

@Riverpod(keepAlive: true)
bool hasUpdate(HasUpdateRef ref, String snapName) {
  final updatesModel = ref.watch(updatesModelProvider);
  return updatesModel.whenOrNull(
        data: (updatesData) => updatesData.snaps.any((s) => s.name == snapName),
      ) ??
      false;
}

@Riverpod(keepAlive: true)
class UpdatesModel extends _$UpdatesModel {
  late final _snapd = getService<SnapdService>();

  @override
  Future<SnapListState> build() async {
    final result = await connectionCheck(
      () => _snapd.find(filter: SnapFindFilter.refresh),
      ref,
    );
    return result;
  }

  /// Used to remove a snap from the list without reloading the whole provider.
  /// Should be used when a snap is uninstalled directly from the manage page
  /// list for example.
  void remove(String snapName) {
    if (!state.hasValue) return;
    state = AsyncData(
      state.value!.copyWith(
        snaps: state.value!.snaps.where((s) => s.name != snapName),
      ),
    );
  }

  Future<void> updateAll() async {
    if (!state.hasValue) return;
    try {
      final changeId = await _snapd.refreshMany([]);
      ref.read(updateChangeIdProvider.notifier).state = changeId;
      await _snapd.waitChange(changeId);
    } on SnapdException catch (e) {
      ref.read(errorStreamControllerProvider).add(e);
    }
    ref.read(updateChangeIdProvider.notifier).state = null;
    ref.invalidateSelf();
  }

  Future<void> cancelChange(String changeId) async {
    if (changeId.isEmpty) return;

    try {
      final changeDetails = await _snapd.getChange(changeId);

      // If the change is already completed, ignore silently.
      // If it wouldn't be ignored, an error would be displayed to the user,
      // which might be confusing.
      if (changeDetails.ready) {
        return;
      }

      final abortChange = await _snapd.abortChange(changeId);
      await _snapd.waitChange(abortChange.id);
      ref.read(updateChangeIdProvider.notifier).state = null;
    } on SnapdException catch (e) {
      ref.read(errorStreamControllerProvider).add(e);
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
