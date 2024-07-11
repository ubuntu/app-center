import 'dart:async';

import 'package:app_center/providers/error_stream_provider.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'updates_model.g.dart';

final updateChangeIdProvider = StateProvider<String?>((_) => null);

@Riverpod(keepAlive: true)
bool hasUpdate(HasUpdateRef ref, String snapName) {
  final updatesModel = ref.watch(updatesModelProvider);
  return updatesModel.value?.any((s) => s.name == snapName) ?? false;
}

@Riverpod(keepAlive: true)
class UpdatesModel extends _$UpdatesModel {
  late final _snapd = getService<SnapdService>();

  @override
  Future<Iterable<Snap>> build() {
    try {
      return _snapd.find(filter: SnapFindFilter.refresh);
    } on SnapdException catch (e) {
      ref.read(errorStreamControllerProvider).add(e);
      return Future.value([]);
    }
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
