import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';

final snapModelProvider =
    ChangeNotifierProvider.family.autoDispose<SnapModel, String>(
  (ref, snapName) => SnapModel(
    snapd: getService<SnapdService>(),
    updatesModel: ref.read(updatesProvider),
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
    required this.updatesModel,
    required this.snapName,
  })  : _state = const AsyncValue.loading(),
        _hasUpdate = updatesModel.refreshableSnapNames.contains(snapName);
  final SnapdService snapd;
  final UpdatesModel updatesModel;
  final String snapName;

  String? get activeChangeId => _activeChangeId;
  String? _activeChangeId;

  AsyncValue<void> get state => _state;
  AsyncValue<void> _state;

  Snap? localSnap;
  Snap? storeSnap;

  bool get hasUpdate => _hasUpdate;
  bool _hasUpdate;

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

  Future<void> init() async {
    final storeSnapCompleter = Completer();
    _storeSnapSubscription = snapd.getStoreSnap(snapName).listen((snap) {
      _setStoreSnap(snap);
      if (!storeSnapCompleter.isCompleted) storeSnapCompleter.complete();
      _setDefaultSelectedChannel();
      notifyListeners();
    });

    updatesModel.addListener(_updatesModelListener);

    _state = await AsyncValue.guard(() async {
      await _getLocalSnap();
      if (storeSnap == null && localSnap == null) {
        await storeSnapCompleter.future;
      }
      _setDefaultSelectedChannel();
      notifyListeners();
    });
  }

  void _updatesModelListener() {
    final hasUpdate = updatesModel.refreshableSnapNames.contains(snapName);
    if (hasUpdate != _hasUpdate) {
      _hasUpdate = hasUpdate;
      notifyListeners();
    }
  }

  @override
  Future<void> dispose() async {
    await _storeSnapSubscription?.cancel();
    _storeSnapSubscription = null;

    updatesModel.removeListener(_updatesModelListener);
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
    _activeChangeId = changeId;
    notifyListeners();
    await snapd.waitChange(changeId);
    _activeChangeId = null;
    await _getLocalSnap();
    notifyListeners();
  }

  Future<void> cancel() async {
    if (activeChangeId == null) return;
    await snapd.abortChange(activeChangeId!);
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
