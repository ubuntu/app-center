import 'package:snapd/snapd.dart';
import 'package:software/app/common/app_finding.dart';
import 'package:software/app/common/snap/snap_sort.dart';
import 'package:software/snapx.dart';

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

List<Snap> sortSnaps({
  required SnapSort snapSort,
  required List<Snap> snaps,
}) {
  switch (snapSort) {
    case SnapSort.name:
      snaps.sort((a, b) => a.name.compareTo(b.name));
      break;

    case SnapSort.size:
      snaps.sort(
        (a, b) {
          if (a.installedSize == null || b.installedSize == null) return 0;
          return b.installedSize!.compareTo(a.installedSize!);
        },
      );
      break;

    case SnapSort.installDate:
      snaps.sort(
        (a, b) {
          if (a.installDate == null || b.installDate == null) return 0;
          return a.installDate!.compareTo(b.installDate!);
        },
      );
      break;
  }
  return snaps;
}

List<Snap> sortStoreSnaps({
  required StoreSnapSort storeSnapSort,
  required List<Snap> snaps,
}) {
  switch (storeSnapSort) {
    case StoreSnapSort.name:
      snaps.sort((a, b) => a.name.compareTo(b.name));
      break;

    case StoreSnapSort.downloadSize:
      snaps.sort(
        (a, b) {
          if (a.downloadSize == null || b.downloadSize == null) return 0;
          return b.downloadSize!.compareTo(a.downloadSize!);
        },
      );
      break;

    case StoreSnapSort.releasedAt:
      snaps.sort(
        (a, b) {
          if (a.releasedAt == null || b.releasedAt == null) return 0;
          return a.releasedAt!.compareTo(b.releasedAt!);
        },
      );
      break;
  }
  return snaps;
}

Map<String, AppFinding> sortAppFindings({
  required StoreSnapSort storeSnapSort,
  required Map<String, AppFinding> appFindings,
}) {
  final findings = appFindings.entries.map((e) => e.value).toList();
  if (!findings.any((finding) => finding.snap == null)) {
    switch (storeSnapSort) {
      case StoreSnapSort.name:
        findings.sort((a, b) => a.snap!.name.compareTo(b.snap!.name));
        break;

      case StoreSnapSort.downloadSize:
        findings.sort(
          (a, b) {
            if (a.snap!.downloadSize == null || b.snap!.downloadSize == null) {
              return 0;
            }
            return b.snap!.downloadSize!.compareTo(a.snap!.downloadSize!);
          },
        );
        break;

      case StoreSnapSort.releasedAt:
        findings.sort(
          (a, b) {
            if (a.snap!.releasedAt == null || b.snap!.releasedAt == null) {
              return 0;
            }
            return b.snap!.releasedAt!.compareTo(a.snap!.releasedAt!);
          },
        );
        break;
    }
    appFindings = {for (var e in findings) e.snap!.name: e};
  }
  return appFindings;
}
