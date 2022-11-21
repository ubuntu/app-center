import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/app_data.dart';
import 'package:software/store_app/common/border_container.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AppReviews extends StatefulWidget {
  const AppReviews({
    super.key,
    this.rating,
    this.userReviews,
    this.onRatingUpdate,
    this.onReviewSend,
    this.appIsInstalled = false,
  });

  final double? rating;
  final List<AppReview>? userReviews;
  final void Function(double)? onRatingUpdate;
  final void Function()? onReviewSend;
  final bool appIsInstalled;

  @override
  State<AppReviews> createState() => _AppReviewsState();
}

class _AppReviewsState extends State<AppReviews> {
  late YaruCarouselController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YaruCarouselController(viewportFraction: 1);
  }

  @override
  Widget build(BuildContext context) {
    return BorderContainer(
      child: YaruExpandable(
        isExpanded: true,
        header: Text(
          context.l10n.reviewsAndRatings,
          style: Theme.of(context).textTheme.headline6,
          overflow: TextOverflow.ellipsis,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.appIsInstalled)
              _MyReview(
                rating: widget.rating,
                onRatingUpdate: widget.onRatingUpdate,
                onReviewSend: widget.onReviewSend,
              ),
            YaruCarousel(
              height: 200,
              width: 1000,
              navigationControls: true,
              controller: _controller,
              children: [
                if (widget.userReviews != null)
                  for (final userReview in widget.userReviews!)
                    Padding(
                      padding: const EdgeInsets.only(left: 0, right: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: kYaruPagePadding,
                          ),
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
                                itemBuilder: (context, _) => const Icon(
                                  YaruIcons.star,
                                  color: Color.fromARGB(255, 247, 160, 31),
                                  size: 2,
                                ),
                                onRatingUpdate: (rating) {},
                                ignoreGestures: true,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                DateFormat.yMd(Platform.localeName).format(
                                    userReview.dateTime ?? DateTime.now()),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                userReview.username ?? context.l10n.unknown,
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(child: Text(userReview.review ?? '')),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MyReview extends StatelessWidget {
  const _MyReview(
      {super.key, this.rating, this.onRatingUpdate, this.onReviewSend});

  final double? rating;

  final void Function(double)? onRatingUpdate;
  final void Function()? onReviewSend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          itemBuilder: (context, _) => const Icon(
            YaruIcons.star,
            color: Color.fromARGB(255, 247, 160, 31),
            size: 2,
          ),
          onRatingUpdate: (rating) => showDialog(
            context: context,
            builder: (context) => _MyReviewDialog(
              rating: rating,
              onRatingUpdate: onRatingUpdate,
              onReviewSend: onReviewSend,
            ),
          ),
        ),
        const SizedBox(
          height: kYaruPagePadding,
        ),
      ],
    );
  }
}

class _MyReviewDialog extends StatelessWidget {
  const _MyReviewDialog(
      {super.key, this.rating, this.onRatingUpdate, this.onReviewSend});

  final double? rating;

  final void Function(double)? onRatingUpdate;
  final void Function()? onReviewSend;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: YaruTitleBar(
        title: Text(context.l10n.yourReview),
        leading: const Icon(YaruIcons.star),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RatingBar.builder(
            initialRating: rating ?? 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.only(right: 10),
            itemSize: 50,
            itemBuilder: (context, _) => const Icon(
              YaruIcons.star,
              color: Color.fromARGB(255, 247, 160, 31),
              size: 2,
            ),
            onRatingUpdate: (rating) => showDialog(
              context: context,
              builder: (context) => _MyReviewDialog(
                rating: rating,
                onRatingUpdate: onRatingUpdate,
                onReviewSend: onReviewSend,
              ),
            ),
          ),
          const SizedBox(
            height: kYaruPagePadding,
          ),
          TextField(
            decoration: InputDecoration(hintText: context.l10n.yourReviewTitle),
          ),
          const SizedBox(
            height: kYaruPagePadding,
          ),
          SizedBox(
            width: 500,
            child: TextField(
              keyboardType: TextInputType.multiline,
              minLines: 10,
              maxLines: 10,
              decoration: InputDecoration(hintText: context.l10n.yourReview),
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (onReviewSend != null) {
              onReviewSend!();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.reviewSent),
                ),
              );
            }
            Navigator.of(context).pop();
          },
          child: Text(context.l10n.send),
        )
      ],
    );
  }
}
