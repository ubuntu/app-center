import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/appstream/appstream_utils.dart';
import 'package:app_center/constants.dart';
import 'package:app_center/deb/deb_model.dart';
import 'package:app_center/deb/local_deb_model.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/ratings/ratings_l10n.dart';
import 'package:app_center/ratings/ratings_model.dart';
import 'package:app_center/snapd/snap_data.dart';
import 'package:app_center/widgets/hyperlink_text.dart';
import 'package:app_center/widgets/shimmer_placeholder.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru/yaru.dart';

typedef AppInfo = ({Widget label, Widget value});

class AppInfoBar extends StatelessWidget {
  const AppInfoBar({
    required this.appInfos,
    required this.layout,
    super.key,
  });

  factory AppInfoBar.fromSnap({
    required BuildContext context,
    required SnapData snapData,
    required ResponsiveLayout layout,
  }) =>
      AppInfoBar(
        appInfos: [
          _SnapRatingsItem(snap: snapData.snap),
          _AppInfoItem.confinement(context: context, appData: snapData),
          _AppInfoItem.downloadSize(context: context, appData: snapData),
          _AppInfoItem.license(context: context, appData: snapData),
          _AppInfoItem.version(context: context, appData: snapData),
          _AppInfoItem.published(context: context, appData: snapData),
          _AppInfoItem.links(context: context, appData: snapData),
        ],
        layout: layout,
      );

  factory AppInfoBar.fromDeb({
    required BuildContext context,
    required DebData debData,
    required ResponsiveLayout layout,
  }) =>
      AppInfoBar(
        appInfos: [
          _AppInfoItem.version(context: context, appData: debData),
          _AppInfoItem.links(context: context, appData: debData),
        ],
        layout: layout,
      );

  factory AppInfoBar.fromLocalDeb({
    required BuildContext context,
    required LocalDebData localDebData,
    required ResponsiveLayout layout,
  }) =>
      AppInfoBar(
        appInfos: [
          _AppInfoItem.downloadSize(context: context, appData: localDebData),
          _AppInfoItem.license(context: context, appData: localDebData),
          _AppInfoItem.links(context: context, appData: localDebData),
        ],
        layout: layout,
      );

  final List<Widget> appInfos;
  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: kPagePadding,
      runSpacing: 32,
      children: appInfos,
    );
  }
}

class _AppInfoItem extends StatelessWidget {
  const _AppInfoItem({required this.label, required this.value});

  factory _AppInfoItem.confinement({
    required BuildContext context,
    required AppMetadata appData,
  }) =>
      _AppInfoItem(
        label: Text(AppLocalizations.of(context).snapPageConfinementLabel),
        value: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(appData.confinement!.localize(AppLocalizations.of(context))),
            if (appData.confinement == AppConfinement.strict) ...const [
              SizedBox(width: 2),
              Icon(YaruIcons.shield, size: 12),
            ],
          ],
        ),
      );

  factory _AppInfoItem.downloadSize({
    required BuildContext context,
    required AppMetadata appData,
  }) =>
      _AppInfoItem(
        label: Text(AppLocalizations.of(context).snapPageDownloadSizeLabel),
        value: Text(
          appData.downloadSize != null
              ? context.formatByteSize(appData.downloadSize!)
              : '',
        ),
      );

  factory _AppInfoItem.license({
    required BuildContext context,
    required AppMetadata appData,
  }) =>
      _AppInfoItem(
        label: Text(AppLocalizations.of(context).snapPageLicenseLabel),
        value: Text(appData.license ?? ''),
      );

  factory _AppInfoItem.version({
    required BuildContext context,
    required AppMetadata appData,
  }) =>
      _AppInfoItem(
        label: Text(AppLocalizations.of(context).snapPageVersionLabel),
        value: Text(appData.version!),
      );

  factory _AppInfoItem.published({
    required BuildContext context,
    required AppMetadata appData,
  }) =>
      _AppInfoItem(
        label: Text(AppLocalizations.of(context).snapPagePublishedLabel),
        value: Text(
          appData.published != null
              ? DateFormat.yMMMd().format(appData.published!)
              : '',
        ),
      );

  factory _AppInfoItem.links({
    required BuildContext context,
    required AppMetadata appData,
  }) {
    final l10n = AppLocalizations.of(context);
    return _AppInfoItem(
      label: Text(l10n.snapPageLinksLabel),
      value: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...appData.links!.entries.map(
            (entry) => HyperlinkText(
              text: entry.key.localize(l10n, appData),
              link: entry.value,
            ),
          ),
        ],
      ),
    );
  }

  final Widget label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveLayout.of(context);

    return SizedBox(
      width: (layout.totalWidth -
              (layout.snapInfoColumnCount - 1) * kPagePadding) /
          layout.snapInfoColumnCount,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label,
          SelectionArea(
            focusNode: FocusNode(canRequestFocus: false),
            child: DefaultTextStyle.merge(
              style: const TextStyle(fontWeight: FontWeight.w500),
              child: value,
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapRatingsItem extends ConsumerWidget {
  const _SnapRatingsItem({
    required this.snap,
  });

  final Snap snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ratingsModel = ref.watch(ratingsModelProvider(snap.name));
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    return ratingsModel.when(
      data: (ratingsData) => _AppInfoItem(
        label: Text(l10n.snapRatingsVotes(ratingsData.rating?.totalVotes ?? 0)),
        value: Text(
          ratingsData.rating?.ratingsBand.localize(l10n) ?? '',
          style: TextStyle(
            color: ratingsData.rating?.ratingsBand.getColor(context),
          ),
        ),
      ),
      loading: () => _AppInfoItem(
        label: Shimmer.fromColors(
          baseColor: isLightTheme ? kShimmerBaseLight : kShimmerBaseDark,
          highlightColor:
              isLightTheme ? kShimmerHighLightLight : kShimmerHighLightDark,
          child: ShimmerPlaceholder(
            child: Text(l10n.snapRatingsVotes(0)),
          ),
        ),
        value: Shimmer.fromColors(
          baseColor: isLightTheme ? kShimmerBaseLight : kShimmerBaseDark,
          highlightColor:
              isLightTheme ? kShimmerHighLightLight : kShimmerHighLightDark,
          child: ShimmerPlaceholder(
            child: Text(
              RatingsBand.insufficientVotes.localize(l10n),
            ),
          ),
        ),
      ),
      error: (error, stackTrace) => SizedBox.shrink(),
    );
  }
}
