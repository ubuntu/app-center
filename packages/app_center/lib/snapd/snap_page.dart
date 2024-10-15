import 'package:app_center/constants.dart';
import 'package:app_center/error/error.dart';
import 'package:app_center/extensions/string_extensions.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/local_snap_providers.dart';
import 'package:app_center/manage/snap_actions_button.dart';
import 'package:app_center/ratings/ratings.dart';
import 'package:app_center/snapd/snap_report.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/snapd/snapd_cache.dart';
import 'package:app_center/store/store_app.dart';
import 'package:app_center/widgets/shimmer_placeholder.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:yaru/yaru.dart';

const _kChannelDropdownWidth = 220.0;

typedef SnapInfo = ({Widget label, Widget value});

class SnapPage extends ConsumerWidget {
  const SnapPage({required this.snapName, super.key});

  final String snapName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(snapModelProvider(snapName));

    final snapDataNotFound =
        snap.hasError && snap.error is SnapDataNotFoundException;
    if (snapDataNotFound) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          ref.invalidate(filteredLocalSnapsProvider);
          Navigator.pop(context);
        }
      });
      return const Center(child: YaruCircularProgressIndicator());
    }

    return snap.when(
      data: (snapData) => ResponsiveLayoutBuilder(
        builder: (_) {
          return _SnapView(snapData: snapData);
        },
      ),
      error: (error, stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(storeSnapProvider(snapName)),
      ),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _SnapView extends StatelessWidget {
  const _SnapView({required this.snapData});

  final SnapData snapData;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final snapInfos = <SnapInfo>[
      (
        label: Text(l10n.snapPageConfinementLabel),
        value: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              snapData.channelInfo?.confinement.localize(l10n) ??
                  snapData.snap.confinement.localize(l10n),
            ),
            if ((snapData.channelInfo?.confinement ??
                    snapData.snap.confinement) ==
                SnapConfinement.strict) ...const [
              SizedBox(width: 2),
              Icon(YaruIcons.shield, size: 12),
            ],
          ],
        ),
      ),
      (
        label: Text(l10n.snapPageDownloadSizeLabel),
        value: Text(
          snapData.channelInfo != null
              ? context.formatByteSize(snapData.channelInfo!.size)
              : '',
        ),
      ),
      (
        label: Text(l10n.snapPageLicenseLabel),
        value: Text(snapData.snap.license ?? ''),
      ),
      (
        label: Text(l10n.snapPageVersionLabel),
        value: Text(snapData.channelInfo?.version ?? snapData.snap.version),
      ),
      (
        label: Text(l10n.snapPagePublishedLabel),
        value: Text(
          snapData.channelInfo != null
              ? DateFormat.yMMMd().format(snapData.channelInfo!.releasedAt)
              : '',
        ),
      ),
      (
        label: Text(l10n.snapPageLinksLabel),
        value: Column(
          children: [
            if (snapData.snap.website?.isNotEmpty ?? false)
              '<a href="${snapData.snap.website}">${l10n.snapPageDeveloperWebsiteLabel}</a>',
            if ((snapData.snap.contact.isNotEmpty) &&
                snapData.snap.publisher != null)
              '<a href="${snapData.snap.contact}">${l10n.snapPageContactPublisherLabel(snapData.snap.publisher!.displayName)}</a>',
          ]
              .map(
                (link) => Html(
                  data: link,
                  style: {'body': Style(margin: Margins.zero)},
                  onLinkTap: (url, attributes, element) =>
                      launchUrlString(url!),
                ),
              )
              .toList(),
        ),
      ),
    ];

    final layout = ResponsiveLayout.of(context);

    return Column(
      children: [
        const SizedBox(height: kPagePadding),
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: layout.totalWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: kPagePadding),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppIcon(iconUrl: snapData.snap.iconUrl, size: 96),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTitle.fromSnap(snapData.snap, large: true),
                        ),
                        _IconRow(snapData: snapData),
                      ],
                    ),
                    const SizedBox(height: kPagePadding),
                    Row(
                      children: [
                        if (snapData.availableChannels != null &&
                            snapData.selectedChannel != null) ...[
                          _ChannelDropdown(snapData: snapData),
                          const SizedBox(width: kSpacing),
                        ],
                        Flexible(
                          child: SnapActionButtons(
                            snapName: snapData.name,
                            isPrimary: true,
                          ),
                        ),
                        if (snapData.isInstalled) ...[
                          const SizedBox(width: kSpacing),
                          _RatingsActionButtons(snap: snapData.snap),
                        ],
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: _SnapInfoBar(
                        snapInfos: snapInfos,
                        snap: snapData.snap,
                        layout: layout,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: kSectionSpacing),
                    if (snapData.hasGallery) ...[
                      AppPageSection(
                        header: Text(
                          l10n.snapPageGalleryLabel,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: kSectionSpacing,
                          ),
                          child: ScreenshotGallery(
                            title: snapData.storeSnap!.titleOrName,
                            urls: snapData.storeSnap!.screenshotUrls,
                            height: layout.totalWidth / 2,
                          ),
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: kSectionSpacing),
                    ],
                    AppPageSection(
                      header: Text(
                        l10n.snapPageDescriptionLabel,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapData.snap.summary,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: kPagePadding),
                            MarkdownBody(
                              selectable: true,
                              data: snapData.snap.description.escapedMarkdown(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: kPagePadding),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SnapInfoBar extends ConsumerWidget {
  const _SnapInfoBar({
    required this.snapInfos,
    required this.snap,
    required this.layout,
  });

  final List<SnapInfo> snapInfos;
  final ResponsiveLayout layout;
  final Snap snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ratingsModel = ref.watch(ratingsModelProvider(snap.name));
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    final ratings = ratingsModel.whenOrNull(
      data: (ratingsData) => (
        label: Text(l10n.snapRatingsVotes(ratingsData.rating?.totalVotes ?? 0)),
        value: Text(
          ratingsData.rating?.ratingsBand.localize(l10n) ?? '',
          style: TextStyle(
            color: ratingsData.rating?.ratingsBand.getColor(context),
          ),
        ),
      ),
      loading: () => (
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
    );
    return AppInfoBar(
      appInfos: [if (ratings != null) ratings, ...snapInfos],
      layout: layout,
    );
  }
}

class _RatingsActionButtons extends ConsumerWidget {
  const _RatingsActionButtons({required this.snap});

  final Snap snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsModel = ref.watch(ratingsModelProvider(snap.name));
    final ratingsNotifier = ref.watch(ratingsModelProvider(snap.name).notifier);

    return ratingsModel.when(
      data: (ratingsData) {
        return IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                ),
                onTap: () {
                  ratingsNotifier.castVote(VoteStatus.up);
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Theme.of(context).dividerColor),
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                      left: BorderSide(color: Theme.of(context).dividerColor),
                      right: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                  ),
                  child: YaruIconButton(
                    mouseCursor: SystemMouseCursors.click,
                    icon: Icon(
                      ratingsData.voteStatus == VoteStatus.up
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
              ),
              InkWell(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
                onTap: () {
                  ratingsNotifier.castVote(VoteStatus.down);
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Theme.of(context).dividerColor),
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                      left: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                      right: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                  child: YaruIconButton(
                    mouseCursor: SystemMouseCursors.click,
                    icon: Icon(
                      ratingsData.voteStatus == VoteStatus.down
                          ? Icons.thumb_down
                          : Icons.thumb_down_outlined,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}

class _IconRow extends ConsumerWidget {
  const _IconRow({required this.snapData});

  final SnapData snapData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = snapData.storeSnap ?? snapData.localSnap!;
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        if (snap.website != null)
          YaruIconButton(
            icon: const Icon(YaruIcons.share),
            onPressed: () {
              final navigationKey = ref.watch(materialAppNavigatorKeyProvider);

              ScaffoldMessenger.of(navigationKey.currentContext!).showSnackBar(
                SnackBar(
                  content: Text(l10n.snapPageShareLinkCopiedMessage),
                ),
              );
              Clipboard.setData(ClipboardData(text: snap.website!));
            },
          ),
        YaruIconButton(
          icon: const Icon(YaruIcons.flag),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return ResponsiveLayoutBuilder(
                  builder: (context) =>
                      SnapReport(name: snapData.snap.titleOrName),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ChannelDropdown extends ConsumerWidget {
  const _ChannelDropdown({required this.snapData});

  final SnapData snapData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.snapPageChannelLabel,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(width: kSpacingSmall),
        SizedBox(
          width: _kChannelDropdownWidth,
          child: MenuButtonBuilder(
            entries: snapData.availableChannels!.entries
                .map(
              (channelEntry) => MenuButtonEntry(
                value: channelEntry.key,
                child: _ChannelDropdownEntry(channelEntry: channelEntry),
              ),
            )
                .fold(
              <MenuButtonEntry<String>>[],
              (p, e) =>
                  [...p, e, const MenuButtonEntry(value: '', isDivider: true)],
            )..removeLast(),
            itemBuilder: (context, value, child) => Text(value),
            selected: snapData.selectedChannel,
            onSelected: (value) => ref
                .read(snapModelProvider(snapData.name).notifier)
                .selectChannel(value),
            menuPosition: PopupMenuPosition.under,
            menuStyle: const MenuStyle(
              minimumSize:
                  WidgetStatePropertyAll(Size(_kChannelDropdownWidth, 0)),
              maximumSize:
                  WidgetStatePropertyAll(Size(_kChannelDropdownWidth, 200)),
              visualDensity: VisualDensity.standard,
            ),
            itemStyle: MenuItemButton.styleFrom(
              maximumSize: const Size.fromHeight(100),
            ),
            child: Text(
              '${snapData.selectedChannel} ${snapData.availableChannels![snapData.selectedChannel]!.version}',
            ),
          ),
        ),
      ],
    );
  }
}

class _ChannelDropdownEntry extends StatelessWidget {
  const _ChannelDropdownEntry({required this.channelEntry});

  final MapEntry<String, SnapChannel> channelEntry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              overflow: TextOverflow.ellipsis,
            ),
        child: SizedBox(
          width: _kChannelDropdownWidth - 24,
          child: Row(
            children: [
              DefaultTextStyle.merge(
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.snapPageChannelLabel),
                    Text(l10n.snapPageVersionLabel),
                    Text(l10n.snapPagePublishedLabel),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    channelEntry.key,
                    channelEntry.value.version,
                    DateFormat.yMd().format(channelEntry.value.releasedAt),
                  ].nonNulls.map((e) => Text(e, maxLines: 1)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
