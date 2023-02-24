import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:software/app/common/app_rating.dart';
import 'package:software/app/common/rating_chart.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/app/common/app_data.dart';
import 'package:software/app/common/border_container.dart';
import 'package:software/app/common/constants.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';
import '../expandable_title.dart';

class AppReviews extends StatefulWidget {
  const AppReviews({
    super.key,
    this.appRating,
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
    this.onVote,
    this.onFlag,
    required this.initialized,
  });

  final AppRating? appRating;
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
  final Function(AppReview, bool)? onVote;
  final Function(AppReview)? onFlag;

  final bool appIsInstalled;
  final bool initialized;

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BorderContainer(
      initialized: widget.initialized,
      child: YaruExpandable(
        isExpanded: true,
        header: ExpandableContainerTitle(
          context.l10n.reviewsAndRatings,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: kYaruPagePadding,
            ),
            if (widget.appRating != null)
              RatingChart(
                appRating: widget.appRating!,
              ),
            const Divider(
              height: 60,
              thickness: 0.0,
            ),
            if (widget.appIsInstalled)
              _ReviewPanel(
                appIsInstalled: widget.appIsInstalled,
                averageRating: widget.appRating?.average,
                reviewRating: widget.reviewRating,
                review: widget.review,
                reviewTitle: widget.reviewTitle,
                reviewUser: widget.reviewUser,
                onRatingUpdate: widget.onRatingUpdate,
                onReviewSend: widget.onReviewSend,
                onReviewChanged: widget.onReviewChanged,
                onReviewTitleChanged: widget.onReviewTitleChanged,
                onReviewUserChanged: widget.onReviewUserChanged,
              ),
            if (widget.appIsInstalled)
              const Divider(
                height: 60,
                thickness: 0.0,
              ),
            _ReviewsTrailer(
              userReviews: widget.userReviews,
              controller: _controller,
              onVote: widget.onVote,
              onFlag: widget.onFlag,
            ),
            const SizedBox(
              height: kYaruPagePadding,
            ),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => _ReviewDetailsDialog(
                      userReviews: widget.userReviews,
                      onVote: widget.onVote,
                      onFlag: widget.onFlag,
                    ),
                  ),
                  child: Text(context.l10n.showAllReviews),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ReviewDetailsDialog extends StatelessWidget {
  const _ReviewDetailsDialog({
    required this.userReviews,
    this.onVote,
    this.onFlag,
  });

  final List<AppReview>? userReviews;
  final Function(AppReview, bool)? onVote;
  final Function(AppReview)? onFlag;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: YaruDialogTitleBar(
        title: Text(context.l10n.reviewsAndRatings),
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(kYaruPagePadding),
      children: userReviews == null
          ? []
          : userReviews!
              .map(
                (e) => _Review(userReview: e, onFlag: onFlag, onVote: onVote),
              )
              .toList(),
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '${context.l10n.clickToRate}:',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(
                  width: 10,
                ),
                RatingBar.builder(
                  initialRating: reviewRating ?? 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.only(right: 1),
                  itemSize: 20,
                  itemBuilder: (context, _) => const Icon(
                    YaruIcons.star_filled,
                    color: kStarColor,
                    size: 2,
                  ),
                  unratedColor: theme.colorScheme.onSurface.withOpacity(0.2),
                  onRatingUpdate: (rating) {
                    if (onRatingUpdate != null) {
                      onRatingUpdate!(rating);
                    }
                  },
                  ignoreGestures: !appIsInstalled,
                ),
              ],
            ),
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
    final theme = Theme.of(context);
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: YaruDialogTitleBar(
        title: Text(context.l10n.yourReview),
        leading: const Icon(YaruIcons.star_filled),
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
              YaruIcons.star_filled,
              color: kStarColor,
              size: 2,
            ),
            unratedColor: theme.colorScheme.onSurface.withOpacity(0.2),
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

class _ReviewsTrailer extends StatelessWidget {
  const _ReviewsTrailer({
    // ignore: unused_element
    super.key,
    this.userReviews,
    required this.controller,
    this.onVote,
    this.onFlag,
  });

  final List<AppReview>? userReviews;
  final YaruCarouselController controller;
  final Function(AppReview, bool)? onVote;
  final Function(AppReview)? onFlag;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (userReviews != null)
          for (var i = 0;
              i < (userReviews!.length > 3 ? 3 : userReviews!.length);
              i++)
            _Review(
              onFlag: onFlag,
              onVote: onVote,
              userReview: userReviews![i],
            )
      ],
    );
  }
}

class _Review extends StatelessWidget {
  const _Review({
    required this.userReview,
    required this.onFlag,
    required this.onVote,
  });

  final AppReview userReview;
  final Function(AppReview p1)? onFlag;
  final Function(AppReview p1, bool p2)? onVote;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          userReview.title ?? '',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(
          height: 5,
        ),
        RatingBar.builder(
          initialRating: userReview.rating ?? 0,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: EdgeInsets.zero,
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
        const SizedBox(
          width: 10,
        ),
        const SizedBox(
          height: kYaruPagePadding,
        ),
        Text(
          userReview.review ?? '',
          overflow: TextOverflow.ellipsis,
          maxLines: 8,
        ),
        const SizedBox(
          height: kYaruPagePadding,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
        ),
        _RatingHeader(
          userReview: userReview,
          onFlag: onFlag,
          onVote: onVote,
        ),
        const Divider(
          height: 40,
          thickness: 0.0,
        )
      ],
    );
  }
}

class _RatingHeader extends StatelessWidget {
  const _RatingHeader({
    required this.userReview,
    this.onVote,
    this.onFlag,
  });

  final AppReview userReview;
  final Function(AppReview, bool)? onVote;
  final Function(AppReview)? onFlag;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${userReview.positiveVote ?? 1}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Icon(
                    Icons.arrow_upward,
                    color: Theme.of(context).disabledColor,
                    size: 16,
                  )
                ],
              ),
              onPressed:
                  onVote == null ? null : () => onVote!(userReview, false),
            ),
            IconButton(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${userReview.negativeVote ?? 1}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Icon(
                    Icons.arrow_downward,
                    color: Theme.of(context).disabledColor,
                    size: 16,
                  )
                ],
              ),
              onPressed:
                  onVote == null ? null : () => onVote!(userReview, true),
            ),
            const SizedBox(height: 15, child: VerticalDivider()),
            IconButton(
              icon: Icon(
                Icons.flag_rounded,
                size: 16,
                color: Theme.of(context).disabledColor,
              ),
              onPressed: onFlag == null ? null : () => onFlag!(userReview),
            )
          ],
        )
      ],
    );
  }
}
