import 'package:app_center/snapd.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';

@immutable
class SnapData {
  SnapData({
    required this.name,
    required this.localSnap,
    required this.storeSnap,
    this.activeChangeId,
    String? selectedChannel,
  }) : selectedChannel =
            selectedChannel ?? _defaultSelectedChannel(localSnap, storeSnap);

  final String name;
  final Snap? localSnap;
  final Snap? storeSnap;
  final String? selectedChannel;
  final String? activeChangeId;

  Snap get snap => storeSnap ?? localSnap!;
  SnapChannel? get channelInfo => storeSnap?.channels[selectedChannel];
  bool get isInstalled => localSnap != null;
  bool get hasGallery =>
      storeSnap != null && storeSnap!.screenshotUrls.isNotEmpty;
  Map<String, SnapChannel>? get availableChannels => storeSnap?.channels;

  VoidCallback? callback(
    WidgetRef ref,
    SnapAction action, [
    SnapLauncher? launcher,
  ]) {
    return switch (action) {
      SnapAction.cancel => () => ref.read(snapAbortProvider(name)),
      SnapAction.install =>
        storeSnap != null ? () => ref.read(snapInstallProvider(name)) : null,
      SnapAction.open =>
        launcher?.isLaunchable ?? false ? launcher!.open : null,
      SnapAction.remove => () => ref.read(snapRemoveProvider(name)),
      SnapAction.switchChannel =>
        storeSnap != null ? () => ref.read(snapRefreshProvider(this)) : null,
      SnapAction.update =>
        storeSnap != null ? () => ref.read(snapRefreshProvider(this)) : null,
    };
  }

  static String? _defaultSelectedChannel(Snap? localSnap, Snap? storeSnap) {
    final channels = storeSnap?.channels.keys;
    final localChannel = localSnap?.trackingChannel;
    if (localChannel != null && (channels?.contains(localChannel) ?? false)) {
      return localChannel;
    } else if (channels?.contains('latest/stable') ?? false) {
      return 'latest/stable';
    } else {
      return channels?.firstWhereOrNull((c) => c.contains('stable')) ??
          channels?.firstOrNull;
    }
  }
}
