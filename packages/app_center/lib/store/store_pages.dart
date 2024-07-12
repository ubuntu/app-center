import 'package:app_center/about/about.dart';
import 'package:app_center/explore/explore.dart';
import 'package:app_center/games/games.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/manage/manage.dart';
import 'package:app_center/search/search.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

final displayedCategories = [
  SnapCategoryEnum.featured,
  SnapCategoryEnum.productivity,
  SnapCategoryEnum.development,
];

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
  for (final category in displayedCategories)
    (
      tileBuilder: (context, selected) => YaruMasterTile(
            leading: Icon(category.icon(selected)),
            title: Text(category.localize(AppLocalizations.of(context))),
          ),
      pageBuilder: (_) => SearchPage(category: category.categoryName),
    ),
  (
    tileBuilder: (context, selected) => YaruMasterTile(
          leading: Icon(GamesPage.icon(selected)),
          title: Text(GamesPage.label(context)),
        ),
    pageBuilder: (_) => const GamesPage(),
  ),
  (
    tileBuilder: (context, selected) => const Spacer(),
    pageBuilder: (_) => const SizedBox.shrink(),
  ),
  (
    tileBuilder: (context, selected) => const Divider(),
    pageBuilder: (_) => const SizedBox.shrink(),
  ),
  (
    tileBuilder: (context, selected) => YaruMasterTile(
          leading: Icon(ManagePage.icon(selected)),
          title: Text(ManagePage.label(context)),
          trailing: Consumer(
            builder: (context, ref, child) {
              return ref.watch(updatesModelProvider).when(
                    data: (updates) => updates.isNotEmpty
                        ? Badge(label: Text('${updates.length}'))
                        : const SizedBox.shrink(),
                    loading: SizedBox.shrink,
                    error: (_, __) => const SizedBox.shrink(),
                  );
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
