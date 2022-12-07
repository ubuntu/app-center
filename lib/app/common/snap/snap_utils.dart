import 'package:snapd/snapd.dart';

bool isSnapUpdateAvailable({required Snap storeSnap, required Snap localSnap}) {
  if (storeSnap.name == 'snapcraft') return false;
  final version = localSnap.version;

  final selectAbleChannels = getSelectableChannels(storeSnap: storeSnap);
  final tracking = getTrackingChannel(
    trackingChannel: localSnap.trackingChannel,
    selectableChannels: selectAbleChannels,
  );
  final trackingVersion = selectAbleChannels[tracking]?.version;

  return trackingVersion != version;
}

Map<String, SnapChannel> getSelectableChannels({required Snap? storeSnap}) {
  Map<String, SnapChannel> selectableChannels = {};
  if (storeSnap != null && storeSnap.tracks.isNotEmpty) {
    for (var track in storeSnap.tracks) {
      for (var risk in ['stable', 'candidate', 'beta', 'edge']) {
        var name = '$track/$risk';
        var channel = storeSnap.channels[name];
        final channelName = '$track/$risk';
        if (channel != null) {
          selectableChannels.putIfAbsent(channelName, () => channel);
        }
      }
    }
  }
  return selectableChannels;
}

String getTrackingChannel({
  required Map<String, SnapChannel> selectableChannels,
  required String? trackingChannel,
}) {
  if (selectableChannels.entries.isNotEmpty) {
    if (trackingChannel != null &&
        selectableChannels.entries
            .where((element) => element.key.contains(trackingChannel))
            .isNotEmpty) {
      return trackingChannel;
    } else {
      return selectableChannels.entries.first.key;
    }
  } else {
    return '';
  }
}
