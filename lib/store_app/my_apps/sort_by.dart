import 'package:software/l10n/l10n.dart';

enum SortBy {
  name,
  installDate,
  size,
  confinement,
  updateAvailable;

  String localize(AppLocalizations l10n) {
    switch (this) {
      case SortBy.name:
        return l10n.name;
      case SortBy.confinement:
        return l10n.confinement;
      case SortBy.installDate:
        return l10n.installDate;
      case SortBy.size:
        return l10n.size;
      case SortBy.updateAvailable:
        return l10n.updateAvailable;
    }
  }
}
