import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snapd/snapd.dart';

part 'manage_snaps_data.freezed.dart';

@freezed
class ManageSnapsData with _$ManageSnapsData {
  factory ManageSnapsData({
    required List<Snap> installedSnaps,
    required List<String> refreshableSnapNames,
  }) = _ManageSnapsData;

  ManageSnapsData._();

  bool _isRefreshable(Snap snap) => refreshableSnapNames.contains(snap.name);
  Iterable<Snap> get refreshableSnaps => installedSnaps.where(_isRefreshable);
  Iterable<Snap> get nonRefreshableSnaps =>
      installedSnaps.whereNot(_isRefreshable);
}
