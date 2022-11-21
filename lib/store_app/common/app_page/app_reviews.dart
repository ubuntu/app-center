import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/app_data.dart';
import 'package:software/store_app/common/border_container.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AppReviews extends StatelessWidget {
  const AppReviews({
    super.key,
    this.averageRating,
    this.userReviews,
    this.onRatingUpdate,
    this.onReviewSend,
    this.appIsInstalled = false,
    this.review,
    this.onReviewChanged,
    this.onReviewTitleChanged,
    this.onReviewUserChanged,
    this.reviewTitle,
    this.reviewUser,
    this.reviewRating,
  });

  final double? averageRating;
  final double? reviewRating;
  final String? reviewTitle;
  final String? review;
  final String? reviewUser;
  final List<AppReview>? userReviews;
  final void Function(double)? onRatingUpdate;
  final void Function()? onReviewSend;
  final void Function(String)? onReviewChanged;
  final void Function(String)? onReviewTitleChanged;
  final void Function(String)? onReviewUserChanged;
  final bool appIsInstalled;
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
            _ReviewPanel(
              appIsInstalled: appIsInstalled,
              averageRating: averageRating,
              reviewRating: reviewRating,
              review: review,
              reviewTitle: reviewTitle,
              reviewUser: reviewUser,
              onRatingUpdate: onRatingUpdate,
              onReviewSend: onReviewSend,
              onReviewChanged: onReviewChanged,
              onReviewTitleChanged: onReviewTitleChanged,
              onReviewUserChanged: onReviewUserChanged,
            ),
            _ReviewsCarousel(userReviews: userReviews),
          ],
        ),
      ),
    );
  }
}

class _ReviewPanel extends StatelessWidget {
  const _ReviewPanel({
    // ignore: unused_element
    super.key,
    this.averageRating,
    this.onRatingUpdate,
    this.onReviewSend,
    this.onReviewChanged,
    this.onReviewTitleChanged,
    this.onReviewUserChanged,
    this.review,
    this.reviewTitle,
    this.reviewUser,
    this.reviewRating,
    this.appIsInstalled = false,
  });

  final double? averageRating;
  final double? reviewRating;
  final String? review;
  final String? reviewTitle;
  final String? reviewUser;
  final bool appIsInstalled;

  final void Function(double)? onRatingUpdate;
  final void Function()? onReviewSend;
  final void Function(String)? onReviewChanged;
  final void Function(String)? onReviewTitleChanged;
  final void Function(String)? onReviewUserChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: kYaruPagePadding,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingBar.builder(
                  initialRating: reviewRating ?? 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.only(right: 5),
                  itemSize: 35,
                  itemBuilder: (context, _) => const Icon(
                    YaruIcons.star,
                    color: kRatingOrange,
                    size: 2,
                  ),
                  onRatingUpdate: (rating) {
                    if (onRatingUpdate != null) {
                      onRatingUpdate!(rating);
                    }
                  },
                  ignoreGestures: !appIsInstalled,
                ),
                const SizedBox(
                  width: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    appIsInstalled
                        ? context.l10n.clickToRate
                        : context.l10n.notInstalled,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: kYaruPagePadding,
            ),
            if (appIsInstalled)
              ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => _MyReviewDialog(
                    reviewRating: reviewRating,
                    review: review,
                    reviewTitle: reviewTitle,
                    reviewUser: reviewUser,
                    onRatingUpdate: (rating) {
                      if (onRatingUpdate != null) {
                        onRatingUpdate!(rating);
                      }
                    },
                    onReviewSend: onReviewSend,
                    onReviewChanged: onReviewChanged,
                    onReviewTitleChanged: onReviewTitleChanged,
                    onReviewUserChanged: onReviewUserChanged,
                  ),
                ),
                child: Text(context.l10n.yourReview),
              )
          ],
        ),
        const SizedBox(
          height: kYaruPagePadding,
        ),
      ],
    );
  }
}

class _MyReviewDialog extends StatefulWidget {
  const _MyReviewDialog({
    // ignore: unused_element
    super.key,
    this.reviewRating,
    this.onRatingUpdate,
    this.onReviewSend,
    this.onReviewChanged,
    this.onReviewTitleChanged,
    this.onReviewUserChanged,
    this.review,
    this.reviewTitle,
    this.reviewUser,
  });

  final double? reviewRating;
  final String? review;
  final String? reviewTitle;
  final String? reviewUser;

  final void Function(double)? onRatingUpdate;
  final void Function()? onReviewSend;
  final void Function(String)? onReviewChanged;
  final void Function(String)? onReviewTitleChanged;
  final void Function(String)? onReviewUserChanged;

  @override
  State<_MyReviewDialog> createState() => _MyReviewDialogState();
}

class _MyReviewDialogState extends State<_MyReviewDialog> {
  late TextEditingController _reviewController,
      _reviewTitleController,
      _reviewUserController;

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController(text: widget.review);
    _reviewTitleController = TextEditingController(text: widget.reviewTitle);
    _reviewUserController = TextEditingController(text: widget.reviewUser);
  }

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
            initialRating: widget.reviewRating ?? 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.only(right: 10),
            itemSize: 50,
            itemBuilder: (context, _) => const Icon(
              YaruIcons.star,
              color: kRatingOrange,
              size: 2,
            ),
            onRatingUpdate: (rating) {
              if (widget.onRatingUpdate == null) return;
              widget.onRatingUpdate!(rating);
            },
          ),
          const SizedBox(
            height: kYaruPagePadding,
          ),
          TextField(
            controller: _reviewUserController,
            onChanged: widget.onReviewUserChanged,
            decoration: InputDecoration(hintText: context.l10n.yourReviewName),
          ),
          const SizedBox(
            height: kYaruPagePadding,
          ),
          TextField(
            controller: _reviewTitleController,
            onChanged: widget.onReviewTitleChanged,
            decoration: InputDecoration(hintText: context.l10n.yourReviewTitle),
          ),
          const SizedBox(
            height: kYaruPagePadding,
          ),
          SizedBox(
            width: 500,
            child: TextField(
              controller: _reviewController,
              onChanged: widget.onReviewChanged,
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
            if (widget.onReviewSend != null) {
              widget.onReviewSend!();
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

class _ReviewsCarousel extends StatefulWidget {
  const _ReviewsCarousel({
    // ignore: unused_element
    super.key,
    this.userReviews,
  });

  final List<AppReview>? userReviews;

  @override
  State<_ReviewsCarousel> createState() => __ReviewsCarouselState();
}

class __ReviewsCarouselState extends State<_ReviewsCarousel> {
  late YaruCarouselController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YaruCarouselController(viewportFraction: 1);
  }

  @override
  Widget build(BuildContext context) {
    return YaruCarousel(
      height: 200,
      width: 1000,
      placeIndicator: false,
      navigationControls: true,
      controller: _controller,
      children: [
        if (widget.userReviews != null)
          for (final userReview in widget.userReviews!)
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: kYaruPagePadding,
                ),
                _RatingHeader(userReview: userReview),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Text(
                    userReview.review ?? '',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5,
                  ),
                ),
                const SizedBox(
                  height: kYaruPagePadding,
                ),
                OutlinedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: YaruTitleBar(
                        title: _RatingHeader(userReview: userReview),
                      ),
                      titlePadding: EdgeInsets.zero,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(kYaruPagePadding),
                          child: SizedBox(
                            width: 400,
                            child: Text(
                              userReview.review ?? '',
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  child: Text(context.l10n.showMore),
                )
              ],
            )
      ],
    );
  }
}

class _RatingHeader extends StatelessWidget {
  const _RatingHeader({
    Key? key,
    required this.userReview,
  }) : super(key: key);

  final AppReview userReview;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            color: kRatingOrange,
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
            userReview.dateTime ?? DateTime.now(),
          ),
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
    );
  }
}
