import 'package:app_center/apps/apps_utils.dart';
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
import 'package:yaru/yaru.dart';

/// Metadata bar for debs.
class DebInfoBar extends ConsumerWidget {
  const DebInfoBar({required this.debData, super.key});

  final DebData debData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AppInfoBar(
      appInfos: [
        _AppInfoItem.downloadSize(context: context, appData: debData),
        _AppInfoItem.confinement(context: context, appData: debData),
        _AppInfoItem.version(context: context, appData: debData),
        _AppInfoItem.published(context: context, appData: debData),
        _AppInfoItem.license(context: context, appData: debData),
        if (debData.links?.isNotEmpty ?? false)
          _AppInfoItem.links(context: context, appData: debData),
      ],
    );
  }
}

/// Metadata bar for local debs.
class LocalDebInfoBar extends ConsumerWidget {
  const LocalDebInfoBar({required this.localDebData, super.key});

  final LocalDebData localDebData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AppInfoBar(
      appInfos: [
        _AppInfoItem.downloadSize(context: context, appData: localDebData),
        _AppInfoItem.confinement(context: context, appData: localDebData),
        _AppInfoItem.version(context: context, appData: localDebData),
        _AppInfoItem.published(context: context, appData: localDebData),
        _AppInfoItem.license(context: context, appData: localDebData),
        if (localDebData.links?.isNotEmpty ?? false)
          _AppInfoItem.links(context: context, appData: localDebData),
      ],
    );
  }
}

/// Metadata bar for Snaps.
class SnapInfoBar extends ConsumerWidget {
  const SnapInfoBar({required this.snapData, super.key});

  final SnapData snapData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ratingsModel = ref.watch(ratingsModelProvider(snapData.snap.name));
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    final ratingsInfoItem = ratingsModel.when(
      data: (ratingsData) => _AppInfoItem(
        label: Text(
          ratingsData.rating?.ratingsBand.localize(l10n) ?? '',
          style: TextStyle(
            color: ratingsData.rating?.ratingsBand.getColor(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        value: Text(l10n.snapRatingsVotes(ratingsData.rating?.totalVotes ?? 0)),
      ),
      loading: () => _AppInfoItem(
        label: Shimmer.fromColors(
          baseColor: isLightTheme ? kShimmerBaseLight : kShimmerBaseDark,
          highlightColor:
              isLightTheme ? kShimmerHighLightLight : kShimmerHighLightDark,
          child: ShimmerPlaceholder(
            child: Text(
              RatingsBand.insufficientVotes.localize(l10n),
            ),
          ),
        ),
        value: Shimmer.fromColors(
          baseColor: isLightTheme ? kShimmerBaseLight : kShimmerBaseDark,
          highlightColor:
              isLightTheme ? kShimmerHighLightLight : kShimmerHighLightDark,
          child: ShimmerPlaceholder(
            child: Text(l10n.snapRatingsVotes(0)),
          ),
        ),
      ),
      error: (error, stackTrace) => null,
    );

    return _AppInfoBar(
      appInfos: [
        if (ratingsInfoItem != null) ratingsInfoItem,
        _AppInfoItem.downloadSize(context: context, appData: snapData),
        _AppInfoItem.confinement(context: context, appData: snapData),
        _AppInfoItem.version(context: context, appData: snapData),
        _AppInfoItem.published(context: context, appData: snapData),
        _AppInfoItem.license(context: context, appData: snapData),
        if (snapData.links?.isNotEmpty ?? false)
          _AppInfoItem.links(context: context, appData: snapData),
      ],
    );
  }
}

class _AppInfoBar extends StatelessWidget {
  const _AppInfoBar({
    required this.appInfos,
  });

  final List<Widget> appInfos;

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
  }) {
    final l10n = AppLocalizations.of(context);
    return _AppInfoItem(
      label: Text(l10n.snapPageConfinementLabel),
      value: Tooltip(
        constraints: BoxConstraints(maxWidth: 200),
        message: appData.confinement!.localizeTooltip(l10n) ?? '',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (appData.confinement == AppConfinement.strict) ...const [
              Icon(
                YaruIcons.shield,
                size: 12,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(width: 2),
            ],
            Text(appData.confinement!.localize(l10n)),
          ],
        ),
      ),
    );
  }

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
        value: Text(
          appData.license ?? AppLocalizations.of(context).appLicenseUnknown,
        ),
      );

  factory _AppInfoItem.version({
    required BuildContext context,
    required AppMetadata appData,
  }) =>
      _AppInfoItem(
        label: Text(AppLocalizations.of(context).snapPageVersionLabel),
        value: Text(appData.version ?? ''),
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
              : AppLocalizations.of(context).appPublishedUnknown,
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
