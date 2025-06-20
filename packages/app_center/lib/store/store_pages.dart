import 'package:app_center/about/about.dart';
import 'package:app_center/explore/explore.dart';
import 'package:app_center/games/games.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/manage/manage.dart';
import 'package:app_center/manage/updates_model.dart';
import 'package:app_center/search/search.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.title,
    this.leading,
    this.trailing,
  });

  final bool? selected = false;
  final Widget? leading;
  final Widget? title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listTileTheme = theme.listTileTheme;
    final scope = YaruMasterTileScope.maybeOf(context);
    final isSelected = selected ?? scope?.selected ?? false;

    final backgroundColor =
        isSelected ? listTileTheme.selectedTileColor : listTileTheme.tileColor;

    return YaruMasterTile(
      title: title,
      decoration: BoxDecoration(
        border: BoxBorder.all(color: Colors.transparent, width: 2),
        borderRadius: const BorderRadius.all(
          Radius.circular(kYaruButtonRadius),
        ),
        color: backgroundColor,
      ),
      focusDecoration: BoxDecoration(
        border: BoxBorder.all(color: theme.primaryColor, width: 2),
        borderRadius: const BorderRadius.all(
          Radius.circular(kYaruButtonRadius),
        ),
        color: backgroundColor ?? theme.cardColor,
      ),
      leading: leading,
      trailing: trailing,
      selected: isSelected,
    );
  }
}

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
    tileBuilder: (context, selected) => _NavigationTile(
          leading: Icon(ExplorePage.icon(selected)),
          title: Text(ExplorePage.label(context)),
        ),
    pageBuilder: (_) => const ExplorePage(),
  ),
  for (final category in displayedCategories)
    (
      tileBuilder: (context, selected) => _NavigationTile(
            leading: Icon(category.icon(selected)),
            title: Text(category.localize(AppLocalizations.of(context))),
          ),
      pageBuilder: (_) => SearchPage(category: category.categoryName),
    ),
  (
    tileBuilder: (context, selected) => _NavigationTile(
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
    tileBuilder: (context, selected) => _NavigationTile(
          leading: Icon(ManagePage.icon(selected)),
          title: Text(ManagePage.label(context)),
          trailing: Consumer(
            builder: (context, ref, child) {
              return ref.watch(updatesModelProvider).when(
                    data: (snapListState) => snapListState.isNotEmpty
                        ? Badge(label: Text('${snapListState.length}'))
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
    tileBuilder: (context, selected) => _NavigationTile(
          leading: Icon(AboutPage.icon(selected)),
          title: Text(AboutPage.label(context)),
        ),
    pageBuilder: (_) => const AboutPage(),
  ),
];
