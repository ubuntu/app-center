import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';

final snapModelProvider = ChangeNotifierProvider.family<SnapModel, String>(
    (ref, snapName) => SnapModel(getService<SnapdService>(), snapName)..init());

final progressProvider =
    StreamProvider.family.autoDispose<double, List<String>>((ref, ids) {
  final snapd = getService<SnapdService>();

  final streamController = StreamController<double>.broadcast();
  final subProgresses = <String, double>{for (final id in ids) id: 0.0};
  final subscriptions = <String, StreamSubscription>{
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

class SnapModel extends ChangeNotifier {
  SnapModel(this.snapd, this.snapName) : _state = const AsyncValue.loading();
  final SnapdService snapd;
  final String snapName;

  final List<String> activeChanges = [];

  AsyncValue<void> get state => _state;
  AsyncValue<void> _state;

  Snap? localSnap;
  Snap? storeSnap;

  String? get selectedChannel => _selectedChannel;
  String? _selectedChannel;
  set selectedChannel(String? channel) {
    if (channel == _selectedChannel) return;
    _selectedChannel = channel;
    notifyListeners();
  }

  Map<String, SnapChannel>? get availableChannels => storeSnap?.channels;

  StreamSubscription? storeSnapSubscription;

  Future<void> init() async {
    final storeSnapCompleter = Completer();
    storeSnapSubscription = snapd.getStoreSnap(snapName).listen((snap) {
      _setStoreSnap(snap);
      if (!storeSnapCompleter.isCompleted) storeSnapCompleter.complete();
      _setDefaultSelectedChannel();
      notifyListeners();
    });
    _state = await AsyncValue.guard(() async {
      await _getLocalSnap();
      if (storeSnap == null && localSnap == null) {
        await storeSnapCompleter.future;
      }
      _setDefaultSelectedChannel();
      notifyListeners();
    });
  }

  @override
  Future<void> dispose() async {
    await storeSnapSubscription?.cancel();
    storeSnapSubscription = null;
    super.dispose();
  }

  void _setStoreSnap(Snap? newStoreSnap) {
    if (newStoreSnap == storeSnap) return;
    storeSnap = newStoreSnap;
  }

  Future<void> _getLocalSnap() async {
    try {
      localSnap = await snapd.getSnap(snapName);
    } on SnapdException catch (e) {
      if (e.kind != 'snap-not-found') rethrow;
      localSnap = null;
    }
  }

  void _setDefaultSelectedChannel() {
    final channels = storeSnap?.channels.keys;
    final localChannel = localSnap?.trackingChannel;
    if (localChannel != null && (channels?.contains(localChannel) ?? false)) {
      _selectedChannel = localChannel;
    } else if (channels?.contains('latest/stable') ?? false) {
      _selectedChannel = 'latest/stable';
    } else {
      _selectedChannel =
          channels?.firstWhereOrNull((c) => c.contains('stable')) ??
              channels?.firstOrNull;
    }
  }

  Future<void> _snapAction(Future<String> Function() action) async {
    final changeId = await action.call();
    activeChanges.add(changeId);
    notifyListeners();
    await snapd.waitChange(changeId);
    activeChanges.removeWhere((id) => id == changeId);
    await _getLocalSnap();
    notifyListeners();
  }

  Future<void> install() =>
      _snapAction(() => snapd.install(snapName, channel: selectedChannel));

  Future<void> refresh() =>
      _snapAction(() => snapd.refresh(snapName, channel: selectedChannel));

  Future<void> remove() => _snapAction(() => snapd.remove(snapName));
}

extension SnapdChangeX on SnapdChange {
  double get progress {
    var done = 0.0;
    var total = 0.0;
    for (final task in tasks) {
      done += task.progress.done;
      total += task.progress.total;
    }

    return done / total;
  }
}
