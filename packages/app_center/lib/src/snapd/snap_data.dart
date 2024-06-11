import 'package:app_center/snapd.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snapd/snapd.dart';

part 'snap_data.freezed.dart';

// TODO: Better naming, easily confused with the Snap class.
@freezed
class SnapData with _$SnapData {
  factory SnapData({
    required String name,
    required Snap? localSnap,
    required Snap? storeSnap,
    String? selectedChannel,
    String? activeChangeId,
  }) {
    return _SnapData(
      name: name,
      localSnap: localSnap,
      storeSnap: storeSnap,
      selectedChannel:
          selectedChannel ?? defaultSelectedChannel(localSnap, storeSnap),
      activeChangeId: activeChangeId,
    );
  }

  // This constructor is just used to force the creation of the fields, so that
  // we can set the default value of selectedChannel in the default constructor.
  // https://github.com/rrousselGit/freezed/issues/64#issuecomment-1555921659
  factory SnapData.definition({
    required String name,
    required Snap? localSnap,
    required Snap? storeSnap,
    required String? selectedChannel,
    String? activeChangeId,
  }) = _SnapData;

  SnapData._();

  Snap get snap => storeSnap ?? localSnap!;
  SnapChannel? get channelInfo => storeSnap?.channels[selectedChannel];
  bool get isInstalled => localSnap != null;
  bool get hasGallery =>
      storeSnap != null && storeSnap!.screenshotUrls.isNotEmpty;
  Map<String, SnapChannel>? get availableChannels => storeSnap?.channels;

  static String? defaultSelectedChannel(Snap? localSnap, Snap? storeSnap) {
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
