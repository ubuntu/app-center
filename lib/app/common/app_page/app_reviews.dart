import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:software/app/common/app_data.dart';
import 'package:software/app/common/app_rating.dart';
import 'package:software/app/common/border_container.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/rating_chart.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../expandable_title.dart';

// https://github.com/GNOME/odrs-web/blob/master/odrs/views_api.py
const _kMinReviewLength = 2;
const _kMaxReviewLength = 3000;
const _kMinTitleLength = 2;
const _kMaxTitleLength = 70;

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
    this.reviewTitle,
    this.reviewRating,
    this.onVote,
    this.onFlag,
    required this.initialized,
  });

  final AppRating? appRating;
  final double? reviewRating;
  final String? reviewTitle;
  final String? review;
  final List<AppReview>? userReviews;
  final void Function(double)? onRatingUpdate;
  final void Function()? onReviewSend;
  final void Function(String)? onReviewChanged;
  final void Function(String)? onReviewTitleChanged;
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
          context.l10n.ratingsAndReviews,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            if (widget.appRating != null)
              RatingChart(
                appRating: widget.appRating!,
              ),
            const Padding(
              padding: EdgeInsets.only(top: 30, bottom: 30),
              child: Divider(
                height: 0,
              ),
            ),
            if (widget.appIsInstalled)
              _ReviewPanel(
                appIsInstalled: widget.appIsInstalled,
                averageRating: widget.appRating?.average,
                reviewRating: widget.reviewRating,
                review: widget.review,
                reviewTitle: widget.reviewTitle,
                onRatingUpdate: widget.onRatingUpdate,
                onReviewSend: widget.onReviewSend,
                onReviewChanged: widget.onReviewChanged,
                onReviewTitleChanged: widget.onReviewTitleChanged,
              ),
            if (widget.appIsInstalled)
              const Padding(
                padding: EdgeInsets.only(top: 30, bottom: 30),
                child: Divider(
                  height: 0,
                ),
              ),
            _ReviewsTrailer(
              userReviews: widget.userReviews,
              controller: _controller,
              onVote: widget.onVote,
              onFlag: widget.onFlag,
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
        title: Text(context.l10n.ratingsAndReviews),
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(kYaruPagePadding),
      children: userReviews == null
          ? []
          : userReviews!
              .map(
                (e) => SizedBox(
                  width: 500,
                  child: _Review(userReview: e, onFlag: onFlag, onVote: onVote),
                ),
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
    this.review,
    this.reviewTitle,
    this.reviewRating,
    this.appIsInstalled = false,
  });

  final double? averageRating;
  final double? reviewRating;
  final String? review;
  final String? reviewTitle;
  final bool appIsInstalled;

  final void Function(double)? onRatingUpdate;
  final void Function()? onReviewSend;
  final void Function(String)? onReviewChanged;
  final void Function(String)? onReviewTitleChanged;

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
                  '${context.l10n.rate}:',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(
                  width: 10,
                ),
                RatingBar.builder(
                  initialRating: reviewRating ?? 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.only(right: 5),
                  itemSize: 40,
                  itemBuilder: (context, _) => const MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Icon(
                      YaruIcons.star_filled,
                      color: kStarColor,
                      size: 2,
                    ),
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
                  onRatingUpdate: (rating) {
                    if (onRatingUpdate != null) {
                      onRatingUpdate!(rating);
                    }
                  },
                  onReviewSend: onReviewSend,
                  onReviewChanged: onReviewChanged,
                  onReviewTitleChanged: onReviewTitleChanged,
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
    this.review,
    this.reviewTitle,
  });

  final double? reviewRating;
  final String? review;
  final String? reviewTitle;

  final void Function(double)? onRatingUpdate;
  final void Function()? onReviewSend;
  final void Function(String)? onReviewChanged;
  final void Function(String)? onReviewTitleChanged;

  @override
  State<_MyReviewDialog> createState() => _MyReviewDialogState();
}

class _MyReviewDialogState extends State<_MyReviewDialog> {
  late double? _reviewRating;
  late TextEditingController _reviewController, _reviewTitleController;

  @override
  void initState() {
    super.initState();
    _reviewRating = widget.reviewRating;
    _reviewController = TextEditingController(text: widget.review);
    _reviewTitleController = TextEditingController(text: widget.reviewTitle);
  }

  bool get _isReviewValid =>
      _reviewRating != null &&
      _reviewController.text.length >= _kMinReviewLength &&
      _reviewTitleController.text.length >= _kMinTitleLength;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: YaruDialogTitleBar(
        title: Text(context.l10n.writeAreview),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RatingBar.builder(
                initialRating: _reviewRating ?? 0,
                minRating: 1,
                direction: Axis.horizontal,
                itemCount: 5,
                itemPadding: const EdgeInsets.only(right: 5),
                itemSize: 40,
                itemBuilder: (context, _) => const MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Icon(
                    YaruIcons.star_filled,
                    color: kStarColor,
                    size: 2,
                  ),
                ),
                unratedColor: theme.colorScheme.onSurface.withOpacity(0.2),
                onRatingUpdate: (rating) {
                  setState(() => _reviewRating = rating);
                  widget.onRatingUpdate?.call(rating);
                },
              ),
            ],
          ),
          const SizedBox(
            height: kYaruPagePadding,
          ),
          TextField(
            maxLength: _kMaxTitleLength,
            controller: _reviewTitleController,
            onChanged: widget.onReviewTitleChanged,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              label: Text(
                context.l10n.summary,
                style: theme.textTheme.bodyMedium,
              ),
              hintText: context.l10n.summeryHint,
            ),
          ),
          const SizedBox(
            height: kYaruPagePadding,
          ),
          SizedBox(
            width: 600,
            child: TextField(
              maxLength: _kMaxReviewLength,
              controller: _reviewController,
              onChanged: widget.onReviewChanged,
              keyboardType: TextInputType.multiline,
              minLines: 10,
              maxLines: 10,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                label: Text(
                  context.l10n.yourReview,
                  style: theme.textTheme.bodyMedium,
                ),
                hintText: context.l10n.whatDoYouThink,
                floatingLabelAlignment: FloatingLabelAlignment.start,
                alignLabelWithHint: true,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.whatDataIsSend +
                  context.l10n.privacyPolicy, // https://odrs.gnome.org/privacy
              style: theme.textTheme.bodyMedium,
            ),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.cancel),
                ),
                const SizedBox(width: 10),
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _reviewController,
                    _reviewTitleController,
                  ]),
                  builder: (context, child) {
                    return ElevatedButton(
                      onPressed: _isReviewValid
                          ? () {
                              if (widget.onReviewSend != null) {
                                widget.onReviewSend!();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(context.l10n.reviewSent),
                                  ),
                                );
                              }
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: Text(context.l10n.submit),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
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
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              userReview.username ?? context.l10n.unknown,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).hintColor,
                    overflow: TextOverflow.ellipsis,
                  ),
            ),
          ],
        ),
        const SizedBox(
          height: kYaruPagePadding,
        ),
        _ReviewRatingBar(
          userReview: userReview,
          onFlag: onFlag,
          onVote: onVote,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 20, bottom: 20),
          child: Divider(
            height: 0,
          ),
        ),
      ],
    );
  }
}

class _ReviewRatingBar extends StatelessWidget {
  const _ReviewRatingBar({
    required this.userReview,
    this.onVote,
    this.onFlag,
  });

  final AppReview userReview;
  final Function(AppReview, bool)? onVote;
  final Function(AppReview)? onFlag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 20,
      children: [
        RawChip(
          onPressed: onVote == null ? null : () => onVote!(userReview, false),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.thumb_up_outlined,
                color: theme.hintColor,
                size: 16,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                '${userReview.positiveVote ?? 1} ${context.l10n.helpful}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        RawChip(
          onPressed: onVote == null ? null : () => onVote!(userReview, true),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.thumb_down_outlined,
                color: theme.hintColor,
                size: 16,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                '${userReview.negativeVote ?? 1} ${context.l10n.notHelpful}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
        RawChip(
          onPressed: onFlag == null
              ? null
              : () => showDialog(
                    context: context,
                    builder: (context) => _ReportReviewDialog(
                      onFlag: () => onFlag!(userReview),
                    ),
                  ),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.flag_rounded,
                size: 16,
                color: Theme.of(context).hintColor,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                context.l10n.reportAbuse,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _ReportReviewDialog extends StatelessWidget {
  const _ReportReviewDialog({required this.onFlag});

  final void Function() onFlag;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title:
          YaruDialogTitleBar(title: Text(context.l10n.reportReviewDialogTitle)),
      content: SizedBox(
        width: 400,
        child: Text(context.l10n.reportReviewDialogBody),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            onFlag();
            Navigator.of(context).pop();
          },
          child: Text(context.l10n.report),
        )
      ],
    );
  }
}
