import 'package:app_center/appstream.dart';
import 'package:app_center/snapd.dart';
import 'package:appstream/appstream.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru/yaru.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({
    required this.title,
    super.key,
    this.publisher,
    this.verifiedPublisher = false,
    this.starredPublisher = false,
    this.snapCategories,
    this.large = false,
  });

  factory AppTitle.fromSnap(Snap snap, {bool large = false}) => AppTitle(
        title: snap.titleOrName,
        publisher: snap.publisher?.displayName,
        verifiedPublisher: snap.verifiedPublisher,
        starredPublisher: snap.starredPublisher,
        snapCategories: snap.categories,
        large: large,
      );

  factory AppTitle.fromDeb(
    AppstreamComponent component, {
    bool large = false,
  }) =>
      AppTitle(
        title: component.getLocalizedName(),
        publisher: component.getLocalizedDeveloperName(),
        large: large,
      );

  factory AppTitle.fromTool(
    String title,
    String publisher, {
    bool large = false,
  }) =>
      AppTitle(
        title: title,
        publisher: publisher,
        large: large,
      );

  final String title;
  final String? publisher;
  final bool verifiedPublisher;
  final bool starredPublisher;
  final List<SnapCategory>? snapCategories;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final titleTextStyle =
        large ? textTheme.headlineSmall! : textTheme.titleMedium!;
    final publisherTextStyle =
        large ? textTheme.bodyMedium! : textTheme.bodyMedium!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: titleTextStyle,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Flexible(
              child: Text(
                publisher ?? l10n.unknownPublisher,
                style: publisherTextStyle.copyWith(
                    color: Theme.of(context).hintColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (verifiedPublisher || starredPublisher)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                child: Icon(
                  verifiedPublisher ? Icons.verified : Icons.stars,
                  size: publisherTextStyle.fontSize,
                  color: verifiedPublisher
                      ? Theme.of(context).colorScheme.success
                      : Theme.of(context).colorScheme.warning,
                ),
              ),
          ],
        ),
        if (large && snapCategories != null) ...[
          const SizedBox(height: 8),
          Row(
            children: snapCategories!
                .whereNot((c) => c.categoryEnum == SnapCategoryEnum.featured)
                .map((c) => Text(c.categoryEnum.localize(l10n)))
                .separatedBy(const Text(', ')),
          )
        ]
      ],
    );
  }
}

extension on Iterable<Widget> {
  List<Widget> separatedBy(Widget separator) => [
        for (var i = 0; i < length; i++) ...[
          elementAt(i),
          if (i < length - 1) separator,
        ]
      ];
}
