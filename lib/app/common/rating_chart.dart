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
                  _RatingBar(
                    starXAmount: appRating.star5!,
                    total: appRating.total!,
                    label: '5',
                    color: const Color.fromARGB(255, 54, 177, 52),
                  ),
                if (appRating.star4 != null)
                  _RatingBar(
                    starXAmount: appRating.star4!,
                    total: appRating.total!,
                    label: '4',
                    color: const Color(0xFFb1cf00),
                  ),
                if (appRating.star3 != null)
                  _RatingBar(
                    starXAmount: appRating.star3!,
                    total: appRating.total!,
                    label: '3',
                    color: const Color(0xFFd49e00),
                  ),
                if (appRating.star2 != null)
                  _RatingBar(
                    starXAmount: appRating.star2!,
                    total: appRating.total!,
                    label: '2',
                    color: const Color(0xFFe56500),
                  ),
                if (appRating.star1 != null)
                  _RatingBar(
                    starXAmount: appRating.star1!,
                    total: appRating.total!,
                    label: '1',
                    color: const Color(0xFFe21033),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({
    required this.starXAmount,
    required this.total,
    required this.label,
    required this.color,
  });

  final int starXAmount;
  final int total;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          child: YaruLinearProgressIndicator(
            color: color,
            value: (starXAmount / total).toDouble(),
          ),
        ),
        const SizedBox(
          width: 2,
        ),
        SizedBox(
          width: 33,
          child: Text(
            starXAmount.toString(),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
