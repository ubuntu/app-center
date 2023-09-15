import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/about.dart';
import '/explore.dart';
import '/l10n.dart';
import '/manage.dart';
import '/search.dart';
import '/snapd.dart';

typedef StorePage = ({
  Widget Function(BuildContext context, bool selected) tileBuilder,
  WidgetBuilder pageBuilder,
});

final pages = <StorePage>[
  (
    tileBuilder: (context, selected) => YaruMasterTile(
          leading: Icon(ExplorePage.icon(selected)),
          title: Text(ExplorePage.label(context)),
        ),
    pageBuilder: (_) => const ExplorePage(),
  ),
  for (final category in [
    SnapCategoryEnum.featured,
    SnapCategoryEnum.productivity,
    SnapCategoryEnum.development,
    SnapCategoryEnum.games,
  ])
    (
      tileBuilder: (context, selected) => YaruMasterTile(
            leading: Icon(category.getIcon(selected)),
            title: Text(category.localize(AppLocalizations.of(context))),
          ),
      pageBuilder: (_) => SearchPage(category: category.categoryName),
    ),
  (
    tileBuilder: (context, selected) => const Spacer(),
    pageBuilder: (_) => const SizedBox.shrink(),
  ),
  (
    tileBuilder: (context, selected) => const Divider(height: 1),
    pageBuilder: (_) => const SizedBox.shrink(),
  ),
  (
    tileBuilder: (context, selected) => YaruMasterTile(
          leading: Icon(ManagePage.icon(selected)),
          title: Text(ManagePage.label(context)),
          trailing: Consumer(
            builder: (context, ref, child) {
              final availableUpdates =
                  ref.watch(updatesModelProvider).refreshableSnapNames.length;
              return availableUpdates > 0
                  ? Badge(label: Text('$availableUpdates'))
                  : const SizedBox.shrink();
            },
          ),
        ),
    pageBuilder: (_) => const ManagePage(),
  ),
  (
    tileBuilder: (context, selected) => YaruMasterTile(
          leading: Icon(AboutPage.icon(selected)),
          title: Text(AboutPage.label(context)),
        ),
    pageBuilder: (_) => const AboutPage(),
  ),
];
