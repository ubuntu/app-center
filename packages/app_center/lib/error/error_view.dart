import 'package:app_center/error/error.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/extensions/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, this.error, this.stackTrace, this.onRetry});

  static const statusUrl = 'https://status.snapcraft.io/';

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
          SvgPicture.asset('assets/error.svg'),
          Text(
            message.title(l10n),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: kPagePadding),
          Flexible(child: Text(message.body(l10n))),
          if (message.actions.isNotEmpty) ...[
            Flexible(child: Text(message.actionLabel(l10n))),
            const SizedBox(height: kPagePadding),
          ],
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.actions.contains(ErrorAction.retry))
                OutlinedButton(
                  onPressed: onRetry,
                  child: Text(
                    UbuntuLocalizations.of(context).retryLabel,
                  ),
                ),
              if (message.actions.contains(ErrorAction.checkStatus))
                OutlinedButton(
                  onPressed: () => launchUrlString(statusUrl),
                  child: Text(l10n.errorViewCheckStatusLabel),
                ),
            ].separatedBy(const SizedBox(width: 10)),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}
