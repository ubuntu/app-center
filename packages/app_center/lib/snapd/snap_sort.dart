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
}

// TODO: simplify; reconsider default values; separate order direction(?)
extension SnapSort on Iterable<Snap> {
  Iterable<Snap> sortedSnaps(SnapSortOrder? order) => order != null
      ? sorted((a, b) => switch (order) {
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
          })
      : toList();
}
