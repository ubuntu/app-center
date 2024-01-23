import 'package:app_center/explore.dart';
import 'package:app_center/games.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/snapd.dart';
import 'package:app_center/store.dart';
import 'package:app_center/widgets.dart';
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
          const SizedBox(height: kPagePadding),
          _Title(text: SnapCategoryEnum.games.localize(l10n)),
          const SizedBox(height: 0),
        ]),
        SliverList.list(children: const [
          SizedBox(height: kPagePadding),
          GamesPageFeatured(),
          SizedBox(height: kPagePadding),
          Text("Here we'll have featured games!"),
          SizedBox(height: kPagePadding),
        ]),
        const CategorySnapList(category: SnapCategoryEnum.games),
        SliverList.list(
          children: [
            const SizedBox(height: kPagePadding),
            Row(
              children: [
                const Expanded(
                    flex: 306 - 160,
                    child: CategoryBanner(
                      category: SnapCategoryEnum.gameDev,
                      padding: _CategoryBannerProperties.padding,
                      height: _CategoryBannerProperties.height,
                      kMaxSize: _CategoryBannerProperties.kMaxSize,
                      kIconSize: _CategoryBannerProperties.kIconSize,
                      fontSize: _CategoryBannerProperties.fontSize,
                    )),
                Container(width: 12),
                const Expanded(
                    flex: 306 - 160,
                    child: CategoryBanner(
                      category: SnapCategoryEnum.gameEmulators,
                      padding: _CategoryBannerProperties.padding,
                      height: _CategoryBannerProperties.height,
                      kMaxSize: _CategoryBannerProperties.kMaxSize,
                      kIconSize: _CategoryBannerProperties.kIconSize,
                      fontSize: _CategoryBannerProperties.fontSize,
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
                      padding: _CategoryBannerProperties.padding,
                      height: _CategoryBannerProperties.height,
                      kMaxSize: _CategoryBannerProperties.kMaxSize,
                      kIconSize: _CategoryBannerProperties.kIconSize,
                      fontSize: _CategoryBannerProperties.fontSize,
                    )),
                Container(width: 12),
                const Expanded(
                    flex: 306 - 160,
                    child: CategoryBanner(
                      category: SnapCategoryEnum.kdeGames,
                      padding: _CategoryBannerProperties.padding,
                      height: _CategoryBannerProperties.height,
                      kMaxSize: _CategoryBannerProperties.kMaxSize,
                      kIconSize: _CategoryBannerProperties.kIconSize,
                      fontSize: _CategoryBannerProperties.fontSize,
                    ))
              ],
            ),
            const SizedBox(
              height: kPagePadding,
            )
          ],
        ),
        SliverList.list(children: [
          Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 29, 27, 112),
                  Color.fromARGB(255, 49, 1, 82),
                ],
              ),
            ),
            height: 185,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "External references", //TODO: l10n
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton(
                          onPressed: () {
                            StoreNavigator.pushExternalTools(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: Text("Discover Resources"), //TODO: l10n
                        ),
                      ],
                    ),
                  ),
                  // TODO: add smooth transition
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Tooltip(
                          waitDuration: Duration.zero,
                          showDuration: Duration.zero,
                          verticalOffset: 88 / 2,
                          message: tools[0].name,
                          child: InkWell(
                            child: SizedBox(
                              height: 88,
                              width: 88,
                              child: Center(
                                child: TweenAnimationBuilder(
                                  curve: Curves.easeIn,
                                  tween: Tween<double>(begin: 1.0, end: 1.5),
                                  duration: const Duration(milliseconds: 100),
                                  builder: (context, scale, child) => Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 24,
                                          color: Colors.black.withAlpha(0x19),
                                        )
                                      ],
                                    ),
                                    child: AppIcon(
                                      iconUrl:
                                          tools[0].iconUrl,
                                      size: 48 * scale,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(width: 24),
                        Tooltip(
                          waitDuration: Duration.zero,
                          showDuration: Duration.zero,
                          verticalOffset: 88 / 2,
                          message: tools[1].name,
                          child: InkWell(
                            child: SizedBox(
                              height: 88,
                              width: 88,
                              child: Center(
                                child: TweenAnimationBuilder(
                                  curve: Curves.easeIn,
                                  tween: Tween<double>(begin: 1.0, end: 1.5),
                                  duration: const Duration(milliseconds: 100),
                                  builder: (context, scale, child) => Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 24,
                                          color: Colors.black.withAlpha(0x19),
                                        )
                                      ],
                                    ),
                                    child: AppIcon(
                                      iconUrl:
                                          tools[1].iconUrl,
                                      size: 48 * scale,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(width: 24),
                        Tooltip(
                          waitDuration: Duration.zero,
                          showDuration: Duration.zero,
                          verticalOffset: 88 / 2,
                          message: tools[2].name,
                          child: InkWell(
                            child: SizedBox(
                              height: 88,
                              width: 88,
                              child: Center(
                                child: TweenAnimationBuilder(
                                  curve: Curves.easeIn,
                                  tween: Tween<double>(begin: 1.0, end: 1.5),
                                  duration: const Duration(milliseconds: 100),
                                  builder: (context, scale, child) => Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 24,
                                          color: Colors.black.withAlpha(0x19),
                                        )
                                      ],
                                    ),
                                    child: AppIcon(
                                      iconUrl:
                                          tools[2].iconUrl,
                                      size: 48 * scale,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: kPagePadding),
        ]),
        SliverList.list(
          children: [
            Row(
              children: [
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: Container(),
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: OutlinedButton(
                    onPressed: () {
                      StoreNavigator.pushSearch(context,
                          category: SnapCategoryEnum.games.categoryName);
                    },
                    child: const Text('All games'), //TODO: l10n
                  ),
                ),
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: Container(),
                ),
              ],
            ),
            const SizedBox(height: kPagePadding),
          ],
        )
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

class _CategoryBannerProperties {
  static const double padding = 24;
  static const double height = 150;
  static const double kMaxSize = 60;
  static const double kIconSize = 32;
  static const double fontSize = 16;
}
