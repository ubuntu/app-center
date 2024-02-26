import 'dart:async';

import 'package:app_center/snapd.dart';
import 'package:app_center/src/snapd/logger.dart';
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

class MultiSnapModel extends ChangeNotifier {
  MultiSnapModel({
    required this.snapd,
    required this.category,
  }) : _state = const AsyncValue.loading();
  final SnapdService snapd;
  final SnapCategoryEnum category;

  String? get activeChangeId => _activeChangeId;
  String? _activeChangeId;

  AsyncValue<void> get state => _state;
  AsyncValue<void> _state;

  List<Snap> categorySnaps = [];

  StreamSubscription<List<Snap>?>? _storeSnapSubscription;
  StreamSubscription<SnapdChange>? _activeChangeSubscription;

  Stream<SnapdException> get errorStream => _errorStreamController.stream;
  final StreamController<SnapdException> _errorStreamController =
      StreamController.broadcast();

  Future<void> init() async {
    assert(category.featuredSnapNames!.isNotEmpty);
    final storeSnapCompleter = Completer();
    _storeSnapSubscription =
        snapd.getStoreSnaps(category.featuredSnapNames!).listen((snaps) {
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
    await _errorStreamController.close();
    _setActiveChange(null);
    super.dispose();
  }

  void _handleError(SnapdException e) {
    _errorStreamController.add(e);
    log.error('Caught exception for snap bundle "$category"', e);
  }

  Future<void> _activeChangeListener(SnapdChange change) async {
    if (change.ready) {
      log.debug('Change $_activeChangeId for $category done');
      _setActiveChange(null);
      notifyListeners();
    }
  }

  void _setActiveChange(String? id) {
    _activeChangeId = id;
    if (id == null) {
      _activeChangeSubscription?.cancel();
      _activeChangeSubscription = null;
    } else {
      _activeChangeSubscription =
          snapd.watchChange(id).listen(_activeChangeListener);
    }
  }

  Future<void> _snapAction(Future<String> Function() action) async {
    try {
      final changeId = await action.call();
      _setActiveChange(changeId);
      notifyListeners();
    } on SnapdException catch (e) {
      _handleError(e);
    }
  }

  Future<void> cancel() async {
    if (activeChangeId == null) return;
    await snapd.abortChange(activeChangeId!);
  }

  Future<void> installAll() {
    assert(categorySnaps.length == category.featuredSnapNames!.length,
        'install() should not be called before the store snaps are available');
    return _snapAction(() => _installAllSnaps(categorySnaps));
  }

  Future<String> _installAllSnaps(List<Snap> snaps) async {
    final classicSnaps = snaps
        .where((snap) => snap.confinement == SnapConfinement.classic)
        .toList();
    final strictSnaps = snaps
        .where((snap) => snap.confinement == SnapConfinement.strict)
        .toList();
    final changeIds = List<String>.empty(growable: true);
    if (classicSnaps.isNotEmpty) {
      final changeId =
          await snapd.install(classicSnaps.first.name, classic: true);
      final change = await snapd.getChange(changeId);
      changeIds.add(changeId);
      if (['Do', 'Doing', 'Done'].contains(change.status)) {
        for (var i = 1; i < classicSnaps.length; i++) {
          changeIds
              .add(await snapd.install(classicSnaps[i].name, classic: true));
        }
        changeIds.add(await snapd
            .installMany(strictSnaps.map((snap) => snap.name).toList()));
      }
    } else {
      changeIds.add(await snapd
          .installMany(strictSnaps.map((snap) => snap.name).toList()));
    }
    return changeIds.last;
  }
}
