import 'package:app_center/snapd.dart';
import 'package:app_center/src/store/store_navigator.dart';
import 'package:app_center/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class FeaturedCarousel extends ConsumerStatefulWidget {
  const FeaturedCarousel({
    super.key,
    this.snapAmount = 10,
    this.scrollDelay = const Duration(seconds: 5),
  });

  final Duration scrollDelay;
  final int snapAmount;

  @override
  ConsumerState<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends ConsumerState<FeaturedCarousel> {
  late YaruCarouselController controller;
  late Iterable<Snap> snaps;

  @override
  Widget build(BuildContext context) {
    snaps = ref
            .watch(snapSearchProvider(
                const SnapSearchParameters(category: SnapCategoryEnum.games)))
            .whenOrNull(data: (data) => data)
            ?.take(widget.snapAmount) ??
        [];

    controller = YaruCarouselController(
      autoScroll: true,
      autoScrollDuration: widget.scrollDelay,
    );

    return MouseRegion(
      onEnter: (_) => controller.cancelTimer(),
      onExit: (_) => controller.startTimer(),
      child: YaruCarousel(
        controller: controller,
        height: 350,
        width: double.infinity,
        nextIcon: const Icon(YaruIcons.go_next),
        previousIcon: const Icon(YaruIcons.go_previous),
        navigationControls: true,
        children: snaps
            .map(
              (e) => _CarouselCard(
                snap: e,
                onTap: (snap) => StoreNavigator.pushSnap(
                  context,
                  name: e.name,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CarouselCard extends StatelessWidget {
  const _CarouselCard({required this.snap, required this.onTap});

  final Snap snap;
  final ValueChanged<Snap> onTap;
  final Color _kForegroundColorPrimary = Colors.white;
  final Color _kForegroundColorSecondary = Colors.white70;

  @override
  Widget build(BuildContext context) {
    return YaruBanner(
      padding: EdgeInsets.zero,
      onTap: () => onTap(snap),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          SafeNetworkImage(
            url: snap.screenshotUrls.first,
            fit: BoxFit.cover,
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(1.0),
                  Colors.black.withOpacity(0.2)
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(snap.titleOrName,
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium!
                        .copyWith(color: _kForegroundColorPrimary)),
                Text(
                  snap.summary,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: _kForegroundColorSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
