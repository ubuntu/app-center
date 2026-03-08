import 'package:app_center/error/error.dart';
import 'package:app_center/extensions/iterable_extensions.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Displays an `ErrorMessage` to the user.
///
/// Renders either an actionable or non-actionable error. Under an actionable
/// error an area displaying either retry or status check (or both).
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.error,
    this.stackTrace,
    this.onRetry,
  });

  final Object? error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = ErrorMessage.fromObject(error);

    return Padding(
      padding: const EdgeInsets.all(kPagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Spacer(),
          SvgPicture.asset(
            'assets/error.svg',
            key: const Key('error-asset'),
          ),
          Text(
            message.title(l10n),
            key: const Key('error-title'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: kPagePadding),
          Flexible(
            child: Text(
              message.body(l10n),
              key: const Key('error-action-body'),
            ),
          ),
          if (message.actions.isNotEmpty)
            ActionableErrorActions(
              actions: message.actions,
              label: message.actionLabel(l10n),
              onRetry: onRetry,
            ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

/// Displays the [actions] a user can take for a `ErrorMessage`.
@visibleForTesting
class ActionableErrorActions extends StatelessWidget {
  const ActionableErrorActions({
    required this.actions,
    required this.label,
    super.key,
    this.onRetry,
    @visibleForTesting Future<bool> Function(String)? onCheckStatus,
  }) : _launchCheckStatus = onCheckStatus ?? launchUrlString;

  static const statusUrl = 'https://status.snapcraft.io/';

  /// The [label] from the error message.
  final String label;

  /// The [actions] that can be taken for the error.
  final List<ErrorAction> actions;

  final VoidCallback? onRetry;
  final Future<bool> Function(String) _launchCheckStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      key: const Key('actionable-error-actions'),
      children: [
        Flexible(
          child: Text(
            label,
            key: const Key('error-action-label'),
          ),
        ),
        const SizedBox(height: kPagePadding),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (actions.contains(ErrorAction.retry))
              OutlinedButton(
                onPressed: onRetry,
                key: const Key('error-action-retry'),
                child: Text(
                  UbuntuLocalizations.of(context).retryLabel,
                ),
              ),
            if (actions.contains(ErrorAction.checkStatus))
              OutlinedButton(
                onPressed: () => _launchCheckStatus(statusUrl),
                key: const Key('error-action-check-status'),
                child: Text(l10n.errorViewCheckStatusLabel),
              ),
          ].separatedBy(const SizedBox(width: 10)),
        ),
      ],
    );
  }
}
