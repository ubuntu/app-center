import 'dart:async';

import 'package:app_center/snapd.dart';
import 'package:app_center/src/snapd/logger.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

final multiSnapModelProvider =
    ChangeNotifierProvider.family.autoDispose<MultiSnapModel, SnapCategoryEnum>(
  (ref, category) => MultiSnapModel(
    snapd: getService<SnapdService>(),
    category: category,
  )..init(),
);

final multiProgressProvider =
    StreamProvider.family.autoDispose<double, List<String>>((ref, ids) {
  final snapd = getService<SnapdService>();

  final streamController = StreamController<double>.broadcast();
  final subProgresses = <String, double>{for (final id in ids) id: 0.0};
  final subscriptions = <String, StreamSubscription<SnapdChange>>{
    for (final id in ids)
      id: snapd.watchChange(id).listen((change) {
        subProgresses[id] = change.progress;
        streamController.add(subProgresses.values.sum / subProgresses.length);
      })
  };
  ref.onDispose(() {
    for (final subscription in subscriptions.values) {
      subscription.cancel();
    }
    streamController.close();
  });
  return streamController.stream;
});

class MultiSnapModel extends ChangeNotifier {
  MultiSnapModel({
    required this.snapd,
    required this.category,
  }) : _state = const AsyncValue.loading();
  final SnapdService snapd;
  final SnapCategoryEnum category;

  UnmodifiableListView<String> get activeChangeIds =>
      UnmodifiableListView(_activeChangeIds);
  List<String> _activeChangeIds = [];

  AsyncValue<void> get state => _state;
  AsyncValue<void> _state;

  List<Snap> categorySnaps = [];

  StreamSubscription<List<Snap>?>? _storeSnapSubscription;
  final List<StreamSubscription<SnapdChange>> _activeChangeSubscription = [];

  Future<void> init() async {
    assert(category.featuredSnapNames!.isNotEmpty);
    final storeSnapCompleter = Completer();
    _storeSnapSubscription =
        snapd.getStoreSnaps(category.featuredSnapNames!).listen((snaps) {
      categorySnaps = [];
      categorySnaps.addAll(snaps);
      if (!storeSnapCompleter.isCompleted) storeSnapCompleter.complete();
      notifyListeners();
    });

    _state = await AsyncValue.guard(() async {
      if (categorySnaps.length != category.featuredSnapNames!.length) {
        await storeSnapCompleter.future;
      }
      notifyListeners();
    });
  }

  @override
  Future<void> dispose() async {
    await _storeSnapSubscription?.cancel();
    _storeSnapSubscription = null;
    _activeChangeIds = [];
    super.dispose();
  }

  Future<void> _getLocalSnaps(List<String> snapNames) async {
    try {
      for (final snapName in snapNames) {
        await snapd.getSnap(snapName);
      }
    } on SnapdException catch (e) {
      if (e.kind != 'snap-not-found') rethrow;
    }
  }

  Future<void> _activeChangeListener(SnapdChange change) async {
    if (change.ready) {
      log.debug('Change ${change.id} for ${change.snapNames.join(", ")} done');
      _removeActiveChange(change.id);
      await _getLocalSnaps(change.snapNames);
      notifyListeners();
    }
  }

  void _addActiveChange(String id) {
    _activeChangeIds.add(id);
    _activeChangeSubscription
        .add(snapd.watchChange(id).listen(_activeChangeListener));
  }

  void _removeActiveChange(String id) {
    _activeChangeIds.remove(id);
    _activeChangeSubscription
        .remove(snapd.watchChange(id).listen(_activeChangeListener));
  }

  void _handleError(SnapdException e) {
    log.error('Caught exception for snap bundle "$category"', e);
  }

  Future<void> _snapAction(Future<List<String>?> Function() action) async {
    try {
      await action.call();
      notifyListeners();
    } on SnapdException catch (e) {
      _handleError(e);
    }
  }

  Future<void> cancel() async {
    if (_activeChangeIds.isEmpty) return;
    for (final changeId in _activeChangeIds) {
      await snapd.abortChange(changeId);
    }
  }

  Future<void> installAll() {
    assert(categorySnaps.length == category.featuredSnapNames!.length,
        'install() should not be called before the store snaps are available');
    return _snapAction(() => _installAllSnaps(categorySnaps));
  }

  Future<List<String>?> _installAllSnaps(List<Snap> snaps) async {
    final classicSnaps = snaps
        .where((snap) => snap.confinement == SnapConfinement.classic)
        .toList();
    final strictSnaps = snaps
        .where((snap) => snap.confinement == SnapConfinement.strict)
        .toList();
    if (classicSnaps.isNotEmpty) {
      final changeId =
          await snapd.install(classicSnaps.first.name, classic: true);
      final change = await snapd.getChange(changeId);
      _addActiveChange(changeId);
      if (['Do', 'Doing', 'Done'].contains(change.status)) {
        for (var i = 1; i < classicSnaps.length; i++) {
          _addActiveChange(
              await snapd.install(classicSnaps[i].name, classic: true));
        }
        _addActiveChange(await snapd
            .installMany(strictSnaps.map((snap) => snap.name).toList()));
      }
    } else {
      _addActiveChange(await snapd
          .installMany(strictSnaps.map((snap) => snap.name).toList()));
    }
    return _activeChangeIds;
  }
}
