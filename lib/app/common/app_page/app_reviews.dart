import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:software/app/common/app_data.dart';
import 'package:software/app/common/app_page/review_sort_by.dart';
import 'package:software/app/common/app_rating.dart';
import 'package:software/app/common/border_container.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/rating_chart.dart';
import 'package:software/app/common/review_model.dart';
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
    this.ownReview,
    this.userReviews,
    this.appIsInstalled = false,
    this.onVote,
    this.onFlag,
    required this.initialized,
  });

  final AppRating? appRating;
  final AppReview? ownReview;
  final List<AppReview>? userReviews;
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
              padding: EdgeInsets.only(top: 30, bottom: 20),
              child: Divider(
                height: 0,
              ),
            ),
            if (widget.appIsInstalled && widget.ownReview == null)
              const _ReviewPanel(),
            _ReviewsTrailer(
              ownReview: widget.ownReview,
              userReviews: widget.userReviews,
              controller: _controller,
              onVote: widget.onVote,
              onFlag: widget.onFlag,
            ),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return _ReviewDetailsDialog(
                          ownReview: widget.ownReview,
                          userReviews: widget.userReviews,
                          onVote: widget.onVote,
                          onFlag: widget.onFlag,
                        );
                      },
                    );
                  },
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

class _ReviewDetailsDialog extends StatefulWidget {
  const _ReviewDetailsDialog({
    required this.ownReview,
    required this.userReviews,
    this.onVote,
    this.onFlag,
  });

  final AppReview? ownReview;
  final List<AppReview>? userReviews;
  final Function(AppReview, bool)? onVote;
  final Function(AppReview)? onFlag;

  @override
  State<_ReviewDetailsDialog> createState() => _ReviewDetailsDialogState();
}

class _ReviewDetailsDialogState extends State<_ReviewDetailsDialog> {
  ReviewSortBy _reviewSortBy = ReviewSortBy.mostRecent;
  late List<AppReview>? _userReviews;

  @override
  void initState() {
    super.initState();
    _userReviews = widget.userReviews;
  }

  @override
  Widget build(BuildContext context) {
    if (_userReviews?.isNotEmpty == true) {
      _userReviews!.sort(sortUserReviews);
    }
    return AlertDialog(
      title: YaruDialogTitleBar(
        title: Text(context.l10n.ratingsAndReviews),
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.all(kYaruPagePadding),
      scrollable: true,
      content: StatefulBuilder(
        builder: (context, stateSetter) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: kYaruPagePadding),
                child: Row(
                  children: [
                    YaruPopupMenuButton<ReviewSortBy>(
                      initialValue: _reviewSortBy,
                      onSelected: (value) {
                        stateSetter(
                          () {
                            setState(
                              () {
                                _reviewSortBy = value;
                              },
                            );
                          },
                        );
                      },
                      itemBuilder: (v) {
                        return ReviewSortBy.values
                            .map(
                              (e) => PopupMenuItem<ReviewSortBy>(
                                value: e,
                                child: Text(e.localize(context.l10n)),
                              ),
                            )
                            .toList();
                      },
                      child: Text(_reviewSortBy.localize(context.l10n)),
                    ),
                  ],
                ),
              ),
              ...[widget.ownReview, ...?_userReviews]
                  .whereNotNull()
                  .map(
                    (e) => SizedBox(
                      width: 500,
                      child: _Review(
                        userReview: e,
                        onFlag: widget.onFlag,
                        onVote: widget.onVote,
                      ),
                    ),
                  )
                  .toList()
            ],
          );
        },
      ),
    );
  }

  int sortUserReviews(a, b) {
    switch (_reviewSortBy) {
      case ReviewSortBy.mostRecent:
        return a.dateTime != null && b.dateTime != null
            ? b.dateTime!.compareTo(a.dateTime!)
            : 0;
      case ReviewSortBy.mostUseful:
        return a.positiveVote != null && b.positiveVote != null
            ? b.positiveVote!.compareTo(a.positiveVote!)
            : 0;
      case ReviewSortBy.highestRating:
        return a.rating != null && b.rating != null
            ? b.rating!.compareTo(a.rating!)
            : 0;
      case ReviewSortBy.lowestRating:
        return a.rating != null && b.rating != null
            ? a.rating!.compareTo(b.rating!)
            : 0;
    }
  }
}

class _ReviewPanel extends StatelessWidget {
  const _ReviewPanel({
    // ignore: unused_element
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: () => showReviewDialog(context),
          child: Text(context.l10n.yourReview),
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

Future<void> showReviewDialog(BuildContext context) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final model = context.read<ReviewModel>();

  final review = await showDialog<AppReview?>(
    context: context,
    builder: (context) => const _ReviewDialog(),
  );

  if (review != null && context.mounted) {
    final result = await model.submit(review);
    messenger.showSnackBar(
      SnackBar(
        content: Text(result.localize(l10n)),
      ),
    );
  }
}

class _ReviewDialog extends StatefulWidget {
  // ignore: unused_element
  const _ReviewDialog({super.key});

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  double? _reviewRating;
  final _reviewController = TextEditingController();
  final _reviewTitleController = TextEditingController();

  bool get _isReviewValid =>
      _reviewRating != null &&
      _reviewController.text.length >= _kMinReviewLength &&
      _reviewTitleController.text.length >= _kMinTitleLength;

  AppReview _getReview() {
    return AppReview(
      rating: _reviewRating,
      review: _reviewController.text,
      title: _reviewTitleController.text,
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _reviewTitleController.dispose();
    super.dispose();
  }

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
          TextField(
            maxLength: _kMaxReviewLength,
            controller: _reviewController,
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
        ],
      ),
      actions: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                context.l10n.whatDataIsSend +
                    context
                        .l10n.privacyPolicy, // https://odrs.gnome.org/privacy
                style: theme.textTheme.bodyMedium,
              ),
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
                          ? () => Navigator.of(context).pop(_getReview())
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
    this.ownReview,
    this.userReviews,
    required this.controller,
    this.onVote,
    this.onFlag,
  });

  final AppReview? ownReview;
  final List<AppReview>? userReviews;
  final YaruCarouselController controller;
  final Function(AppReview, bool)? onVote;
  final Function(AppReview)? onFlag;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [ownReview, ...?userReviews]
          .whereNotNull()
          .take(3)
          .map(
            (userReview) => _Review(
              onFlag: onFlag,
              onVote: onVote,
              userReview: userReview,
            ),
          )
          .toList(),
    );
  }
}

class _Review extends StatelessWidget {
  const _Review({
    required this.userReview,
    this.onFlag,
    this.onVote,
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
        if (userReview.own != true)
          Padding(
            padding: const EdgeInsets.only(top: kYaruPagePadding),
            child: _ReviewRatingBar(
              userReview: userReview,
              onFlag: onFlag,
              onVote: onVote,
            ),
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

extension on ReviewResult {
  String localize(AppLocalizations l10n) {
    return switch (this) {
      ReviewResult.ok => l10n.reviewSent,
      ReviewResult.abuse => l10n.reviewAbuse,
      ReviewResult.taboo => l10n.reviewTaboo,
      ReviewResult.error => l10n.reviewError,
    };
  }
}
