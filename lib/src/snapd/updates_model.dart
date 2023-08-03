import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';

final updatesModelProvider = ChangeNotifierProvider(
  (ref) => UpdatesModel(getService<SnapdService>())..refresh(),
);

class UpdatesModel extends ChangeNotifier {
  UpdatesModel(this.snapd);
  final SnapdService snapd;
  Iterable<String> get refreshableSnapNames =>
      _refreshableSnaps?.map((snap) => snap.name) ?? const Iterable.empty();

  Iterable<Snap>? _refreshableSnaps;

  String? get activeChangeId => _activeChangeId;
  String? _activeChangeId;

  Future<void> refresh() async {
    _refreshableSnaps = await snapd.find(filter: SnapFindFilter.refresh);
    notifyListeners();
  }

  bool hasUpdate(String snapName) => refreshableSnapNames.contains(snapName);

  Future<void> updateAll() async {
    if (_refreshableSnaps == null) return;
    final changeId = await snapd.refreshMany(refreshableSnapNames.toList());
    _activeChangeId = changeId;
    notifyListeners();
    await snapd.waitChange(changeId);
    _activeChangeId = null;
    await refresh();
    notifyListeners();
  }
}
