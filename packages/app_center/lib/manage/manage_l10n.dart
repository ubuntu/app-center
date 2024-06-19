import 'package:app_center/l10n.dart';

extension ManagePageUpdateSinceDateTimeAgo on Duration {
  /// Formats the time since last updates as inDays, weeks, months or years.
  String managePageUpdateSinceDateTimeAgo(AppLocalizations localizations) {
    if (inDays < 7) {
      return localizations.managePageUpdatedDaysAgo(inDays);
    }

    final weeks = inDays ~/ 7;
    if (weeks < 5) {
      return localizations.managePageUpdatedWeeksAgo(weeks);
    }

    final months = inDays ~/ 30.42;
    if (months < 12) {
      return localizations.managePageUpdatedMonthsAgo(months);
    }

    final years = inDays ~/ 365;
    return localizations.managePageUpdatedYearsAgo(years);
  }
}
