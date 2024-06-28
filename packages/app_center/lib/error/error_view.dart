import 'package:app_center/error/error.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snapd/snapd.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, this.error, this.stackTrace});

  final Object? error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = switch (error) {
      final SnapdException e => e.prettyFormat(l10n),
      _ => l10n.errorViewUnknownError,
    };
    return Padding(
      padding: const EdgeInsets.all(kPagePadding),
      child: Column(
        children: [
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/error.svg'),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.errorViewTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(message),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
