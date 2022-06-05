import 'dart:async';

import 'package:snapd/snapd.dart';

class SnapChangeService {
  final Map<Snap, SnapdChange> _snapChanges;

  void addChange(Snap snap, SnapdChange change) {
    _snapChanges.putIfAbsent(snap, () => change);
    if (!_snapChangesController.isClosed) {
      _snapChangesController.add(true);
    }
  }

  void removeChange(Snap snap) {
    _snapChanges.remove(snap);
    if (!_snapChangesController.isClosed) {
      _snapChangesController.add(true);
    }
  }

  SnapdChange? getChange(Snap snap) {
    return _snapChanges[snap];
  }

  final _snapChangesController = StreamController<bool>.broadcast();

  Stream<bool> get snapChanges => _snapChangesController.stream;

  SnapChangeService() : _snapChanges = {};
}
