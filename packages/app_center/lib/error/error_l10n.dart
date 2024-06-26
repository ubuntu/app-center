import 'package:app_center/l10n.dart';
import 'package:snapd/snapd.dart';

typedef PatternMap = ({
  RegExp pattern,
  String Function(AppLocalizations l10n, RegExpMatch match) message,
});

final _patternMaps = <PatternMap>[
  (
    pattern: RegExp('too many requests'),
    message: (l10n, _) => l10n.snapdExceptionTooManyRequests,
  ),
  (
    pattern:
        RegExp(r'cannot refresh "(.*?)": snap "\1" has running apps \((.*?)\)'),
    message: (l10n, match) => l10n.snapdExceptionRunningApps(
          match.group(1).toString(),
        ),
  ),
];

extension SnapdExceptionL10n on SnapdException {
  String prettyFormat(AppLocalizations l10n) {
    switch (kind) {
      case 'network-timeout':
        return l10n.snapdExceptionNetworkTimeout;
    }
    for (final patternMap in _patternMaps) {
      final match = patternMap.pattern.firstMatch(message);
      if (match != null) {
        return patternMap.message(l10n, match);
      }
    }
    return message;
  }
}
