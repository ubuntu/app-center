import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';

final manageModelProvider = ChangeNotifierProvider(
  (ref) => ManageModel(
    snapd: getService<SnapdService>(),
    updatesModel: ref.read(updatesModelProvider),
  )..init(),
);

class ManageModel extends ChangeNotifier {
  ManageModel({
    required this.snapd,
    required this.updatesModel,
  }) : _state = const AsyncValue.loading();
  final SnapdService snapd;
  final UpdatesModel updatesModel;

  AsyncValue<void> get state => _state;
  AsyncValue<void> _state;

  List<Snap>? _installedSnaps;
  List<String>? _refreshableSnapNames;

  bool _isRefreshable(Snap snap) => updatesModel.hasUpdate(snap.name);
  Iterable<Snap> get refreshableSnaps =>
      _installedSnaps?.where(_isRefreshable) ?? const Iterable.empty();
  Iterable<Snap> get nonRefreshableSnaps =>
      _installedSnaps?.whereNot(_isRefreshable) ?? const Iterable.empty();

  void _getRefreshableSnapNames() {
    final refreshableSnapNames = updatesModel.refreshableSnapNames.toList();
    if (!listEquals(refreshableSnapNames, _refreshableSnapNames)) {
      _refreshableSnapNames = refreshableSnapNames;
      notifyListeners();
    }
  }

  // TODO: cache local snaps
  Future<void> init() async {
    updatesModel.addListener(_getRefreshableSnapNames);
    _state = await AsyncValue.guard(() async {
      await _getInstalledSnaps();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    updatesModel.removeListener(_getRefreshableSnapNames);
    super.dispose();
  }

  Future<void> _getInstalledSnaps() async {
    _installedSnaps = await snapd.getSnaps().then(
        (snaps) => snaps.sortedBy((snap) => snap.titleOrName.toLowerCase()));
  }
}
