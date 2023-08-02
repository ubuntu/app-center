import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';

final manageModelProvider = ChangeNotifierProvider(
    (ref) => ManageModel(getService<SnapdService>())..init());

class ManageModel extends ChangeNotifier {
  ManageModel(this.snapd) : _state = const AsyncValue.loading();
  final SnapdService snapd;

  AsyncValue<void> get state => _state;
  AsyncValue<void> _state;

  String? get activeChangeId => _activeChangeId;
  String? _activeChangeId;

  List<Snap>? _installedSnaps;
  List<String>? _refreshableSnapNames;

  bool _isRefreshable(Snap snap) =>
      _refreshableSnapNames?.contains(snap.name) ?? false;
  Iterable<Snap> get refreshableSnaps =>
      _installedSnaps?.where(_isRefreshable) ?? const Iterable.empty();
  Iterable<Snap> get nonRefreshableSnaps =>
      _installedSnaps?.whereNot(_isRefreshable) ?? const Iterable.empty();

  // TODO: separate loading local snaps and updates; cache local snaps
  Future<void> init() async {
    _state = await AsyncValue.guard(() async {
      await _getInstalledSnaps();
      await _getRefreshableSnaps();
      notifyListeners();
    });
  }

  Future<void> _getInstalledSnaps() async {
    _installedSnaps = await snapd.getSnaps().then(
        (snaps) => snaps.sortedBy((snap) => snap.titleOrName.toLowerCase()));
  }

  Future<void> _getRefreshableSnaps() async {
    _refreshableSnapNames = await snapd
        .find(filter: SnapFindFilter.refresh)
        .then((snaps) => snaps.map((snap) => snap.name).toList());
  }

  Future<void> updateAll() async {
    if (_refreshableSnapNames == null) return;
    final changeId = await snapd.refreshMany(_refreshableSnapNames!);
    _activeChangeId = changeId;
    notifyListeners();
    await snapd.waitChange(changeId);
    _activeChangeId = null;
    await _getInstalledSnaps();
    await _getRefreshableSnaps();
    notifyListeners();
  }
}
