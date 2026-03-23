import 'package:app_center/snapd/snapd.dart';
import 'package:collection/collection.dart';
import 'package:snapd/snapd.dart';

enum SnapSortOrder {
  alphabeticalAsc,
  alphabeticalDesc,
  downloadSizeAsc,
  downloadSizeDesc,
  installedDateAsc,
  installedDateDesc,
  installedSizeAsc,
  installedSizeDesc,
  publishedDateAsc,
  publishedDateDesc,
}

// TODO: simplify; reconsider default values; separate order direction(?)
extension SnapSort on Iterable<Snap> {
  DateTime? _latestReleaseDate(Snap snap) {
    if (snap.channels.isEmpty) return null;
    return snap.channels.values
        .map((channel) => channel.releasedAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  Iterable<Snap> sortedSnaps(SnapSortOrder? order) => order != null
      ? sorted(
          (a, b) => switch (order) {
            SnapSortOrder.alphabeticalAsc => a.titleOrName
                .toLowerCase()
                .compareTo(b.titleOrName.toLowerCase()),
            SnapSortOrder.alphabeticalDesc => b.titleOrName
                .toLowerCase()
                .compareTo(a.titleOrName.toLowerCase()),
            SnapSortOrder.downloadSizeAsc =>
              (a.downloadSize ?? 0).compareTo(b.downloadSize ?? 0),
            SnapSortOrder.downloadSizeDesc =>
              (b.downloadSize ?? 0).compareTo(a.downloadSize ?? 0),
            SnapSortOrder.installedSizeAsc =>
              (a.installedSize ?? 0).compareTo(b.installedSize ?? 0),
            SnapSortOrder.installedSizeDesc =>
              (b.installedSize ?? 0).compareTo(a.installedSize ?? 0),
            SnapSortOrder.installedDateAsc => (a.installDate ?? DateTime(1970))
                .compareTo(b.installDate ?? DateTime(1970)),
            SnapSortOrder.installedDateDesc => (b.installDate ?? DateTime(1970))
                .compareTo(a.installDate ?? DateTime(1970)),
            SnapSortOrder.publishedDateAsc =>
              (_latestReleaseDate(a) ?? DateTime(1970))
                  .compareTo(_latestReleaseDate(b) ?? DateTime(1970)),
            SnapSortOrder.publishedDateDesc =>
              (_latestReleaseDate(b) ?? DateTime(1970))
                  .compareTo(_latestReleaseDate(a) ?? DateTime(1970)),
          },
        )
      : toList();
}
