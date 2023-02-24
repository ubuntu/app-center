import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:software/app/common/app_rating.dart';
import 'package:software/app/common/constants.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class RatingChart extends StatelessWidget {
  const RatingChart({super.key, required this.appRating});

  final AppRating appRating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 100,
      width: 350,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appRating.average?.toStringAsFixed(1) ?? '',
                style: const TextStyle(
                  height: 0.85,
                  fontSize: 50,
                  fontWeight: FontWeight.w200,
                ),
              ),
              RatingBar.builder(
                initialRating: appRating.average ?? 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.only(right: 1),
                itemSize: 15,
                itemBuilder: (context, _) => const Icon(
                  YaruIcons.star_filled,
                  color: kStarColor,
                  size: 2,
                ),
                unratedColor:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                onRatingUpdate: (rating) {},
                ignoreGestures: true,
              ),
              Text(
                '${appRating.total} ratings',
                style: theme.textTheme.bodySmall,
              )
            ],
          ),
          const SizedBox(
            width: kYaruPagePadding,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (appRating.star5 != null)
                  Row(
                    children: [
                      const Text(
                        '5',
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: YaruLinearProgressIndicator(
                          value: (appRating.star5! / 100).toDouble(),
                        ),
                      ),
                    ],
                  ),
                if (appRating.star4 != null)
                  Row(
                    children: [
                      const Text('4'),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: YaruLinearProgressIndicator(
                          value: (appRating.star5! / 100).toDouble(),
                        ),
                      ),
                    ],
                  ),
                if (appRating.star3 != null)
                  Row(
                    children: [
                      const Text('3'),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: YaruLinearProgressIndicator(
                          value: (appRating.star3! / 100).toDouble(),
                        ),
                      ),
                    ],
                  ),
                if (appRating.star2 != null)
                  Row(
                    children: [
                      const Text('2'),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: YaruLinearProgressIndicator(
                          value: (appRating.star2! / 100).toDouble(),
                        ),
                      ),
                    ],
                  ),
                if (appRating.star1 != null)
                  Row(
                    children: [
                      const Text('1'),
                      const SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: YaruLinearProgressIndicator(
                          value: (appRating.star1! / 100).toDouble(),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
