import 'package:app_center/snapd.dart';
import 'package:collection/collection.dart';
import 'package:snapd/snapd.dart';

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

  SnapData copyWith({
    String? name,
    Snap? localSnap,
    Snap? storeSnap,
    String? selectedChannel,
    String? activeChangeId,
  }) {
    return SnapData(
      name: name ?? this.name,
      localSnap: localSnap ?? this.localSnap,
      storeSnap: storeSnap ?? this.storeSnap,
      selectedChannel: selectedChannel ?? this.selectedChannel,
      activeChangeId: activeChangeId ?? this.activeChangeId,
    );
  }

  @override
  String toString() {
    return '''
SnapData(
  name: $name,
  localSnap: $localSnap,
  storeSnap: $storeSnap,
  selectedChannel: $selectedChannel,
  activeChangeId: $activeChangeId,
)''';
  }
}
