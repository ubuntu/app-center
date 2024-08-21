import 'package:app_center/l10n.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru/widgets.dart';

enum ErrorAction {
  retry,
  checkStatus,
}

sealed class ErrorMessage {
  const ErrorMessage();

  factory ErrorMessage.fromObject(Object? e) {
    if (e is! SnapdException) return ErrorMessageUnknown();
    if (e is ConsolidatedSnapdException) return ErrorMessage.fromMap(e.errors);

    switch (e.kind) {
      case 'network-timeout':
        return ErrorMessageNetwork();
    }
    for (final patternMap in _patternMaps) {
      final match = patternMap.pattern.firstMatch(e.message);
      if (match != null) {
        return patternMap.message(match);
      }
    }
    return ErrorMessageUnknown();
  }

  factory ErrorMessage.fromMap(Map<String, Object?> errors) {
    final errorMessages = errors.map(
      (snapName, error) => MapEntry(snapName, ErrorMessage.fromObject(error)),
    );
    return ErrorMessageConsolidated(errorMessages);
  }

  static final _patternMaps =
      <({RegExp pattern, ErrorMessage Function(Match) message})>[
    (
      pattern: RegExp('too many requests'),
      message: (_) => ErrorMessageTooManyRequests(),
    ),
    (
      pattern: RegExp(
        r'cannot refresh "(.*?)": snap "\1" has running apps \((.*?)\)',
      ),
      message: (match) => ErrorMessageRunningApps(match.group(1)!),
    ),
    (
      pattern: RegExp('persistent network error'),
      message: (_) => ErrorMessageNetwork(),
    ),
  ];

  String body(AppLocalizations l10n) => switch (this) {
        ErrorMessageNetwork() => l10n.errorViewNetworkErrorDescription,
        ErrorMessageTooManyRequests() => l10n.errorViewServerErrorDescription,
        ErrorMessageRunningApps(snap: final snap) =>
          l10n.snapdExceptionRunningApps(snap),
        _ => l10n.errorViewUnknownErrorDescription,
      };

  String title(AppLocalizations l10n) => switch (this) {
        ErrorMessageNetwork() => l10n.errorViewNetworkErrorTitle,
        ErrorMessageRunningApps() => l10n.managePageUpdatesFailed(1),
        ErrorMessageConsolidated() => l10n.managePageUpdatesFailed(
            (this as ErrorMessageConsolidated).errors.length,
          ),
        _ => l10n.errorViewUnknownErrorTitle,
      };

  String actionLabel(AppLocalizations l10n) => switch (this) {
        ErrorMessageNetwork() => l10n.errorViewNetworkErrorAction,
        ErrorMessageTooManyRequests() => l10n.errorViewServerErrorAction,
        _ => l10n.errorViewUnknownErrorAction,
      };

  List<ErrorAction> get actions => switch (this) {
        ErrorMessageNetwork() => [ErrorAction.retry],
        ErrorMessageTooManyRequests() => [ErrorAction.checkStatus],
        ErrorMessageRunningApps() => [],
        _ => [ErrorAction.retry, ErrorAction.checkStatus],
      };

  YaruInfoType get type => switch (this) {
        ErrorMessageNetwork() => YaruInfoType.danger,
        ErrorMessageTooManyRequests() => YaruInfoType.danger,
        ErrorMessageRunningApps() ||
        ErrorMessageConsolidated() =>
          YaruInfoType.warning,
        _ => YaruInfoType.danger,
      };
}

class ErrorMessageNetwork extends ErrorMessage {}

class ErrorMessageTooManyRequests extends ErrorMessage {}

class ErrorMessageRunningApps extends ErrorMessage {
  const ErrorMessageRunningApps(this.snap);
  final String snap;
}

class ErrorMessageUnknown extends ErrorMessage {}

class ErrorMessageConsolidated extends ErrorMessage {
  const ErrorMessageConsolidated(this.errors);
  final Map<String, ErrorMessage> errors;

  @override
  String body(AppLocalizations l10n) {
    final currentlyRunning = errors.entries
        .where((entry) => entry.value is ErrorMessageRunningApps)
        .map((entry) => '• ${entry.key}\n')
        .join();
    return l10n.managePageUpdatesFailedBody(currentlyRunning);
  }
}

class ConsolidatedSnapdException extends SnapdException {
  ConsolidatedSnapdException(this.errors, {super.message = ''});
  final Map<String, Object?> errors;
}
