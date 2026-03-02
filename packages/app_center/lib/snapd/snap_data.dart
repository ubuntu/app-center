import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:appstream/appstream.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snapd/snapd.dart';

part 'snap_data.freezed.dart';

// TODO: Better naming, easily confused with the Snap class.
@freezed
class SnapData extends AppMetadata with _$SnapData {
  factory SnapData({
    required String name,
    required Snap? localSnap,
    required Snap? storeSnap,
    String? selectedChannel,
    String? activeChangeId,
    bool hasUpdate = false,
    bool hasPreviousLocalRevision = false,
  }) {
    return _SnapData(
      name: name,
      localSnap: localSnap,
      storeSnap: storeSnap,
      selectedChannel:
          selectedChannel ?? defaultSelectedChannel(localSnap, storeSnap),
      activeChangeId: activeChangeId,
      hasUpdate: hasUpdate,
      hasPreviousLocalRevision: hasPreviousLocalRevision,
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
    required bool hasUpdate,
    required bool hasPreviousLocalRevision,
    String? activeChangeId,
  }) = _SnapData;

  SnapData._();

  Snap get snap => storeSnap ?? localSnap!;
  SnapChannel? get channelInfo => storeSnap?.channels[selectedChannel];
  bool get isInstalled => localSnap != null;
  bool get hasGallery =>
      storeSnap != null && storeSnap!.screenshotUrls.isNotEmpty;
  Map<String, SnapChannel>? get availableChannels => storeSnap?.channels;

  /// Returns true if the snap can be reverted to a previous version.
  /// Only true when an older local revision exists.
  bool get canRevert => isInstalled && hasPreviousLocalRevision;

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

  @override
  String? get publisher => snap.publisher?.displayName;

  @override
  String? get version =>
      isInstalled ? localSnap!.version : (channelInfo?.version ?? snap.version);

  @override
  DateTime? get published => channelInfo?.releasedAt;

  @override
  String? get license => snap.license;

  @override
  int? get downloadSize => channelInfo?.size;

  @override
  AppConfinement? get confinement =>
      AppConfinement.fromSnap(channelInfo?.confinement ?? snap.confinement);

  @override
  Map<AppstreamUrlType, String>? get links => {
        if (snap.website?.isNotEmpty ?? false) ...{
          AppstreamUrlType.homepage: snap.website!,
        },
        if ((snap.contact.isNotEmpty) && snap.publisher != null) ...{
          AppstreamUrlType.contact: snap.contact,
        },
      };
}
