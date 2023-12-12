import 'package:app_center/about.dart';
import 'package:app_center/explore.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/manage.dart';
import 'package:app_center/search.dart';
import 'package:app_center/snapd.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

typedef StorePage = ({
  Widget Function(BuildContext context, bool selected) tileBuilder,
  WidgetBuilder pageBuilder,
});

final pages = <StorePage>[
  (
    tileBuilder: (context, selected) => YaruMasterTile(
          leading: Icon(ExplorePage.icon(true)),
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
            leading: Icon(category.icon(true)),
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
          leading: Icon(ManagePage.icon(true)),
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
          leading: Icon(AboutPage.icon(true)),
          title: Text(AboutPage.label(context)),
        ),
    pageBuilder: (_) => const AboutPage(),
  ),
];
