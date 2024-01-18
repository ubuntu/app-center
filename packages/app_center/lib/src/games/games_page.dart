import 'package:app_center/explore.dart';
import 'package:app_center/games.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/snapd.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GamesPage extends ConsumerWidget {
  const GamesPage({super.key});

  static IconData icon(bool selected) => SnapCategoryEnum.games.icon(selected);
  static String label(BuildContext context) =>
      AppLocalizations.of(context).gamesPageLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ResponsiveLayoutScrollView(
      slivers: [
        SliverList.list(children: [
          const SizedBox(height: 56),
          _Title(text: SnapCategoryEnum.games.localize(l10n)),
          const SizedBox(height: kPagePadding),
        ]),
        SliverList.list(children: const [
          SizedBox(height: 56),
          GamesPageFeatured(),
          SizedBox(height: kPagePadding),
        ]),
        SliverList.list(
          children: [
            Row(
              children: [
                const Expanded(
                    flex: 306 - 160,
                    child: CategoryBanner(
                      category: SnapCategoryEnum.gameDev,
                      padding: 24,
                      height: 150,
                      kMaxSize: 60,
                      kIconSize: 24,
                      fontSize: 16,
                    )),
                Container(width: 12),
                const Expanded(
                    flex: 306 - 160,
                    child: CategoryBanner(
                      category: SnapCategoryEnum.gameEmulators,
                      padding: 24,
                      height: 150,
                      kMaxSize: 60,
                      kIconSize: 24,
                      fontSize: 16,
                    ))
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                    flex: 306 - 160,
                    child: CategoryBanner(
                      category: SnapCategoryEnum.gnomeGames,
                      padding: 24,
                      height: 150,
                      kMaxSize: 60,
                      kIconSize: 24,
                      fontSize: 16,
                    )),
                Container(width: 12),
                const Expanded(
                    flex: 306 - 160,
                    child: CategoryBanner(
                      category: SnapCategoryEnum.kdeGames,
                      padding: 24,
                      height: 150,
                      kMaxSize: 60,
                      kIconSize: 24,
                      fontSize: 16,
                    ))
              ],
            )
          ],
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.headlineSmall);
  }
}
