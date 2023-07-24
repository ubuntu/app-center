import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';

final snapModelProvider = ChangeNotifierProvider.family<SnapModel, String>(
    (ref, snapName) => SnapModel(getService<SnapdService>(), snapName)..init());

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
    storeSnapSubscription = snapd.getStoreSnap(snapName).listen((snap) {
      _setStoreSnap(snap);
      _setDefaultSelectedChannel();
      notifyListeners();
    });
    _state = await AsyncValue.guard(() async {
      await _getLocalSnap();
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
