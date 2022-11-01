import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/app_data.dart';
import 'package:software/store_app/common/border_container.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AppReviews extends StatelessWidget {
  const AppReviews({super.key, this.rating, this.userReviews});

  final double? rating;
  final List<AppReview>? userReviews;

  @override
  Widget build(BuildContext context) {
    return BorderContainer(
      child: YaruExpandable(
        isExpanded: true,
        header: Text(
          context.l10n.reviewsAndRatings,
          style: Theme.of(context).textTheme.headline6,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: kYaruPagePadding,
            ),
            RatingBar.builder(
              initialRating: rating ?? 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.only(right: 10),
              itemSize: 50,
              itemBuilder: (context, _) => Icon(
                YaruIcons.star_filled,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                size: 2,
              ),
              onRatingUpdate: (rating) {},
            ),
            const SizedBox(
              height: kYaruPagePadding,
            ),
            TextField(
              keyboardType: TextInputType.multiline,
              minLines: 10,
              maxLines: 10,
              decoration: InputDecoration(hintText: context.l10n.yourReview),
            ),
            const SizedBox(
              height: kYaruPagePadding,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text(context.l10n.send),
                ),
              ],
            ),
            const SizedBox(
              height: kYaruPagePadding,
            ),
            if (userReviews != null)
              for (final userReview in userReviews!)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        RatingBar.builder(
                          initialRating: userReview.rating ?? 0,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: EdgeInsets.zero,
                          itemSize: 15,
                          itemBuilder: (context, _) => Icon(
                            YaruIcons.star_filled,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                            size: 2,
                          ),
                          onRatingUpdate: (rating) {},
                          ignoreGestures: true,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          DateFormat.yMd(Platform.localeName)
                              .format(userReview.dateTime ?? DateTime.now()),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          userReview.username ?? context.l10n.unknown,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SelectableText(userReview.review ?? ''),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: kYaruPagePadding,
                    ),
                  ],
                )
          ],
        ),
      ),
    );
  }
}
