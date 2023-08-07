import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/category.dart';
import '/l10n.dart';
import '/layout.dart';
import '/snapd.dart';
import '/store.dart';
import '/widgets.dart';
import 'explore_provider.dart';

class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  static IconData icon(bool selected) =>
      selected ? YaruIcons.compass_filled : YaruIcons.compass;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).explorePageLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredProvider);
    return featured.when(
      data: (data) => ResponsiveLayoutScrollView(
        slivers: [
          SliverList.list(children: const [
            _CategoryBanner(category: SnapCategoryEnum.development),
            SizedBox(height: 16),
            _GridTitle(text: 'Featured Snaps'),
          ]),
          SnapGrid(
            snaps: data.take(6).toList(),
            onTap: (snap) => StoreNavigator.pushDetail(context, snap.name),
          ),
        ],
      ),
      error: (error, stack) => ErrorWidget(error),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _GridTitle extends StatelessWidget {
  const _GridTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.headlineSmall);
  }
}

class _CategoryBanner extends ConsumerWidget {
  const _CategoryBanner({required this.category});

  final SnapCategoryEnum category;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snaps = ref
            .watch(categoryProvider(category))
            .whenOrNull(data: (data) => data)
            ?.take(3) ??
        const Iterable.empty();
    return _Banner(
      snaps: snaps,
      slogan: category.slogan(AppLocalizations.of(context)),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.snaps, required this.slogan});

  final Iterable<Snap> snaps;
  final String slogan;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: kPagePadding),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 5, 148),
            Color.fromARGB(255, 255, 155, 179)
          ],
        ),
      ),
      height: 240,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                slogan,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: Colors.white),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: snaps.map((snap) => _BannerIcon(snap: snap)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerIcon extends StatefulWidget {
  const _BannerIcon({required this.snap});

  final Snap snap;

  @override
  State<_BannerIcon> createState() => _BannerIconState();
}

class _BannerIconState extends State<_BannerIcon> {
  static const _kMaxSize = 88.0;
  static const _kHoverDelay = Duration(milliseconds: 100);
  static const _kIconSize = 48.0;
  static const _kScaleLarge = 1.5;

  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      waitDuration: Duration.zero,
      showDuration: Duration.zero,
      verticalOffset: _kMaxSize / 2,
      message: widget.snap.titleOrName,
      child: InkWell(
        onTap: () => StoreNavigator.pushDetail(context, widget.snap.name),
        onHover: (hover) {
          setState(() => scale = hover ? _kScaleLarge : 1.0);
        },
        child: SizedBox(
          height: _kMaxSize,
          width: _kMaxSize,
          child: Center(
            child: TweenAnimationBuilder(
              curve: Curves.easeIn,
              tween: Tween<double>(begin: 1.0, end: scale),
              duration: _kHoverDelay,
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
                child: SnapIcon(
                  iconUrl: widget.snap.iconUrl,
                  size: _kIconSize * scale,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
