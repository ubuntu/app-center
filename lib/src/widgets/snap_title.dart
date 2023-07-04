import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru/yaru.dart';

import '/snapx.dart';

class SnapTitle extends StatelessWidget {
  const SnapTitle({
    super.key,
    required this.snap,
    this.large = false,
  });

  const SnapTitle.large({super.key, required this.snap}) : large = true;

  final Snap snap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final titleTextStyle =
        large ? textTheme.headlineLarge! : textTheme.bodyMedium!;
    final publisherTextStyle =
        large ? textTheme.headlineSmall! : textTheme.bodyMedium!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(snap.title ?? snap.name, style: titleTextStyle),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              snap.publisher?.displayName ?? l10n.unknownPublisher,
              style: publisherTextStyle.copyWith(
                  color: Theme.of(context).hintColor),
              maxLines: 1,
            ),
            if (snap.verifiedPublisher || snap.starredPublisher)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                child: Icon(
                  snap.verifiedPublisher ? Icons.verified : Icons.stars,
                  size: publisherTextStyle.fontSize,
                  color: snap.verifiedPublisher
                      ? Theme.of(context).colorScheme.success
                      : Theme.of(context).colorScheme.warning,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
