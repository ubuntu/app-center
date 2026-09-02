import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/snapd/snapd.dart';
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

  /// Channel info reflecting the currently installed/tracking channel.
  /// Falls back to [channelInfo] when the snap is not installed.
  SnapChannel? get activeChannelInfo {
    if (localSnap != null) {
      return storeSnap?.channels[localSnap!.trackingChannel] ?? channelInfo;
    }
    return channelInfo;
  }

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

  SnapAction? primaryAction([SnapLauncher? snapLauncher]) {
    final SnapAction? primaryAction;
    final shouldQuitToUpdate = localSnap?.refreshInhibit != null;
    final canOpen = snapLauncher?.isLaunchable ?? false;
    if (isInstalled) {
      if (!shouldQuitToUpdate && hasUpdate) {
        primaryAction = SnapAction.update;
      } else if (canOpen) {
        primaryAction = SnapAction.open;
      } else {
        primaryAction = null;
      }
    } else {
      primaryAction = SnapAction.install;
    }

    return primaryAction;
  }

  List<SnapAction> secondaryActions([SnapLauncher? snapLauncher]) {
    final shouldQuitToUpdate = localSnap?.refreshInhibit != null;
    final canOpen = snapLauncher?.isLaunchable ?? false;
    return [
      if (canOpen) SnapAction.open,
      if (!shouldQuitToUpdate && hasUpdate) SnapAction.update,
      if (availableChannels != null &&
          availableChannels!.length > 1 &&
          selectedChannel != null)
        SnapAction.switchChannel,
      if (canRevert) SnapAction.revert,
    ];
  }

  @override
  String? get publisher => snap.publisher?.displayName;

  @override
  String? get version {
    final rawVersion = isInstalled
        ? localSnap!.version
        : (activeChannelInfo?.version ?? snap.version);
    final trackingChannel = localSnap?.trackingChannel;
    if (trackingChannel != null && trackingChannel != 'latest/stable') {
      return '$trackingChannel $rawVersion';
    }
    return rawVersion;
  }

  @override
  DateTime? get published => activeChannelInfo?.releasedAt;

  @override
  String? get license => snap.license;

  @override
  int? get downloadSize => activeChannelInfo?.size;

  @override
  AppConfinement? get confinement => AppConfinement.fromSnap(
    activeChannelInfo?.confinement ?? snap.confinement,
  );

  @override
  Map<AppLink, String>? get links => {
    if (snap.website?.isNotEmpty ?? false) ...{
      AppLink.homepage: snap.website!,
    },
    if ((snap.contact.isNotEmpty) && snap.publisher != null) ...{
      AppLink.contact: snap.contact,
    },
  };
}
