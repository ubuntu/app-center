import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_logger/ubuntu_logger.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';

@internal
final log = Logger('snap');

final snapModelProvider =
    ChangeNotifierProvider.family.autoDispose<SnapModel, String>(
  (ref, snapName) => SnapModel(
    snapd: getService<SnapdService>(),
    snapName: snapName,
  )..init(),
);

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

final changeProvider =
    StreamProvider.family.autoDispose<SnapdChange, String?>((ref, id) {
  if (id == null) return const Stream.empty();
  return getService<SnapdService>().watchChange(id);
});

class SnapModel extends ChangeNotifier {
  SnapModel({
    required this.snapd,
    required this.snapName,
  }) : _state = const AsyncValue.loading();
  final SnapdService snapd;
  final String snapName;

  String? get activeChangeId => _activeChangeId;
  String? _activeChangeId;

  AsyncValue<void> get state => _state;
  AsyncValue<void> _state;

  Snap? localSnap;
  Snap? storeSnap;

  Snap get snap => storeSnap ?? localSnap!;
  SnapChannel? get channelInfo =>
      selectedChannel != null ? storeSnap?.channels[selectedChannel] : null;
  bool get isInstalled => localSnap != null;
  bool get hasGallery =>
      storeSnap != null && storeSnap!.screenshotUrls.isNotEmpty;

  String? get selectedChannel => _selectedChannel;
  String? _selectedChannel;
  set selectedChannel(String? channel) {
    if (channel == _selectedChannel) return;
    _selectedChannel = channel;
    notifyListeners();
  }

  Map<String, SnapChannel>? get availableChannels => storeSnap?.channels;

  StreamSubscription? _storeSnapSubscription;

  Stream<SnapdException> get errorStream => _errorStreamController.stream;
  final StreamController<SnapdException> _errorStreamController =
      StreamController.broadcast();

  Future<void> init() async {
    final storeSnapCompleter = Completer();
    _storeSnapSubscription = snapd.getStoreSnap(snapName).listen((snap) {
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
    await _storeSnapSubscription?.cancel();
    _storeSnapSubscription = null;
    await _errorStreamController.close();
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

  void _handleError(SnapdException e) {
    _errorStreamController.add(e);
    log.error('Caught exception for snap "${snap.name}"', e);
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
    try {
      final changeId = await action.call();
      _activeChangeId = changeId;
      notifyListeners();
      await snapd.waitChange(changeId);
    } on SnapdException catch (e) {
      _handleError(e);
    }
    _activeChangeId = null;
    await _getLocalSnap();
    notifyListeners();
  }

  Future<void> cancel() async {
    if (activeChangeId == null) return;
    await snapd.abortChange(activeChangeId!);
  }

  Future<void> install() {
    assert(storeSnap?.channels[selectedChannel] != null,
        'install() should not be called before the store snap is available');
    return _snapAction(() => snapd.install(
          snapName,
          channel: selectedChannel,
          classic: storeSnap!.channels[selectedChannel]!.confinement ==
              SnapConfinement.classic,
        ));
  }

  Future<void> refresh() {
    assert(storeSnap?.channels[selectedChannel] != null,
        'remove() should not be called before the store snap is available');
    return _snapAction(() => snapd.refresh(
          snapName,
          channel: selectedChannel,
          classic: storeSnap!.channels[selectedChannel]!.confinement ==
              SnapConfinement.classic,
        ));
  }

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
