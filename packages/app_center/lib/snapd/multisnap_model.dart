import 'dart:async';
import 'dart:io';

import 'package:app_center/providers/error_stream_provider.dart';
import 'package:app_center/snapd/logger.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

final multiSnapModelProvider = ChangeNotifierProvider.family
    .autoDispose<MultiSnapModel, SnapCategoryEnum>(
      (ref, category) => MultiSnapModel(
        snapd: getService<SnapdService>(),
        category: category,
        keepAliveWhileInstalling: () => ref.keepAlive().close,
        onInstallError: (error) {
          if (ref.mounted) ref.read(errorStreamControllerProvider).add(error);
        },
      )..init(),
    );

class MultiSnapModel extends ChangeNotifier {
  MultiSnapModel({
    required this.snapd,
    required this.category,
    this._keepAliveWhileInstalling,
    this._onInstallError,
  });
  final SnapdService snapd;
  final SnapCategoryEnum category;
  final VoidCallback Function()? _keepAliveWhileInstalling;
  final ValueChanged<SnapdException>? _onInstallError;

  String? get activeChangeId => _activeChangeId;
  String? _activeChangeId;

  AsyncValue<void> get state => _state;
  AsyncValue<void> _state = const AsyncValue.loading();

  bool get isInstalling => _isInstalling;
  bool _isInstalling = false;

  bool get canInstall =>
      !isInstalling && state.hasValue && categorySnaps.isNotEmpty;

  List<Snap> categorySnaps = [];

  StreamSubscription<List<Snap>?>? _storeSnapSubscription;

  Future<void> init() async {
    final names = category.featuredSnapNames!;
    assert(names.isNotEmpty);
    final loaded = Completer<void>();

    _storeSnapSubscription = snapd
        .getStoreSnaps(names)
        .listen(
          (snaps) {
            // The cache and store each return a snapshot, not additional items.
            categorySnaps = snaps;
          },
          onDone: loaded.complete,
          onError: loaded.completeError,
          cancelOnError: true,
        );

    _state = await AsyncValue.guard(() => loaded.future);
    if (hasListeners) notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _storeSnapSubscription?.cancel();
    _storeSnapSubscription = null;
    super.dispose();
  }

  Future<void> cancel() async {
    if (activeChangeId == null) return;
    await snapd.abortChange(activeChangeId!);
  }

  Future<void> installAll() async {
    if (!canInstall) return;
    final release = _keepAliveWhileInstalling?.call();
    _isInstalling = true;
    notifyListeners();

    final changeIds = <String>{};
    try {
      try {
        await _installAllSnaps(categorySnaps, changeIds);
      } finally {
        // A later request can fail after snapd accepts earlier changes.
        await Future.wait(changeIds.map(_waitForInstall));
      }
    } on Exception catch (e) {
      log.error('Caught exception for snap bundle "$category"', e);
      final error = e is SnapdException ? e : SnapdException(message: '$e');
      if (error.kind != 'auth-cancelled') _onInstallError?.call(error);
    } finally {
      _isInstalling = false;
      if (hasListeners) notifyListeners();
      release?.call();
    }
  }

  Future<void> _waitForInstall(String changeId) async {
    final change = await snapd
        .watchChange(changeId)
        .handleError(
          (Object _) {},
          // A temporary socket disconnect says nothing about the change.
          test: (error) => error is SocketException,
        )
        .firstWhere((c) => c.ready);
    if (change.err case final error?) throw SnapdException(message: error);
  }

  Future<void> _installAllSnaps(List<Snap> snaps, Set<String> changeIds) async {
    final classicSnaps = snaps
        .where((snap) => snap.confinement == SnapConfinement.classic)
        .toList();
    final strictSnaps = snaps
        .where((snap) => snap.confinement == SnapConfinement.strict)
        .toList();
    if (classicSnaps.isNotEmpty) {
      final changeId = await snapd.install(
        classicSnaps.first.name,
        classic: true,
      );
      changeIds.add(changeId);
      final change = await snapd.getChange(changeId);
      if (!['Do', 'Doing', 'Done'].contains(change.status)) return;
      for (final snap in classicSnaps.skip(1)) {
        changeIds.add(await snapd.install(snap.name, classic: true));
      }
    }
    if (strictSnaps.isNotEmpty) {
      changeIds.add(
        await snapd.installMany(strictSnaps.map((snap) => snap.name).toList()),
      );
    }
  }
}
