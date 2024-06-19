import 'package:app_center/constants.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/ratings/ratings.dart';
import 'package:app_center/snapd/snap_action.dart';
import 'package:app_center/snapd/snap_data.dart';
import 'package:app_center/snapd/snap_report.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/store/store_app.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:yaru/yaru.dart';

const _kPrimaryButtonMaxWidth = 136.0;
const _kChannelDropdownWidth = 220.0;

typedef SnapInfo = ({String label, Widget value});

class SnapPage extends ConsumerWidget {
  const SnapPage({required this.snapName, super.key});

  final String snapName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(snapModelProvider(snapName));
    final updatesModel = ref.watch(updatesModelProvider);

    return snap.when(
      data: (snapData) => ResponsiveLayoutBuilder(
        builder: (_) {
          return _SnapView(
            snapData: snapData,
            updatesModel: updatesModel,
          );
        },
      ),
      error: (error, stackTrace) => ErrorWidget(error),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _SnapView extends StatelessWidget {
  const _SnapView({required this.snapData, required this.updatesModel});

  final SnapData snapData;
  final UpdatesModel updatesModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final snapInfos = <SnapInfo>[
      (
        label: l10n.snapPageConfinementLabel,
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
        label: l10n.snapPageDownloadSizeLabel,
        value: Text(
          snapData.channelInfo != null
              ? context.formatByteSize(snapData.channelInfo!.size)
              : '',
        ),
      ),
      (
        label: l10n.snapPageLicenseLabel,
        value: Text(snapData.snap.license ?? ''),
      ),
      (
        label: l10n.snapPageVersionLabel,
        value: Text(snapData.channelInfo?.version ?? snapData.snap.version),
      ),
      (
        label: l10n.snapPagePublishedLabel,
        value: Text(
          snapData.channelInfo != null
              ? DateFormat.yMMMd().format(snapData.channelInfo!.releasedAt)
              : '',
        ),
      ),
      (
        label: l10n.snapPageLinksLabel,
        value: Column(
          children: [
            if (snapData.snap.website?.isNotEmpty ?? false)
              '<a href="${snapData.snap.website}">${l10n.snapPageDeveloperWebsiteLabel}</a>',
            if ((snapData.snap.contact?.isNotEmpty ?? false) &&
                snapData.snap.publisher != null)
              '<a href="${snapData.snap.contact}">${l10n.snapPageContactPublisherLabel(snapData.snap.publisher!.displayName)}</a>'
          ]
              .map((link) => Html(
                    data: link,
                    style: {'body': Style(margin: Margins.zero)},
                    onLinkTap: (url, attributes, element) =>
                        launchUrlString(url!),
                  ))
              .toList(),
        ),
      ),
    ];

    final layout = ResponsiveLayout.of(context);

    return Column(
      children: [
        SizedBox(
          width: layout.totalWidth,
          child: Padding(
            padding: const EdgeInsets.only(top: kPagePadding),
            child: _Header(snapData: snapData),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: layout.totalWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppIcon(iconUrl: snapData.snap.iconUrl, size: 96),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTitle.fromSnap(snapData.snap, large: true),
                        ),
                      ],
                    ),
                    const SizedBox(height: kPagePadding),
                    Row(
                      children: [
                        if (snapData.availableChannels != null &&
                            snapData.selectedChannel != null) ...[
                          _ChannelDropdown(snapData: snapData),
                          const SizedBox(width: 16),
                        ],
                        Flexible(
                          child: _SnapActionButtons(snapData: snapData),
                        )
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
                    const SizedBox(height: 48),
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
                          padding: const EdgeInsets.only(bottom: 48),
                          child: ScreenshotGallery(
                            title: snapData.storeSnap!.titleOrName,
                            urls: snapData.storeSnap!.screenshotUrls,
                            height: layout.totalWidth / 2,
                          ),
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 48),
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
                              onTapLink: (text, href, title) =>
                                  launchUrlString(href!),
                              data: snapData.snap.description,
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
    final ratingsModel = ref.watch(ratingsModelProvider(snap));

    final ratings = ratingsModel.state.whenOrNull(
      data: (_) => (
        label: l10n.snapRatingsVotes(ratingsModel.snapRating?.totalVotes ?? 0),
        value: Text(
          ratingsModel.snapRating?.ratingsBand.localize(l10n) ?? '',
          style: TextStyle(
              color: ratingsModel.snapRating?.ratingsBand.getColor(context)),
        ),
      ),
    );

    return AppInfoBar(
      appInfos: [if (ratings != null) ratings, ...snapInfos],
      layout: layout,
    );
  }
}

class _SnapActionButtons extends ConsumerWidget {
  const _SnapActionButtons({required this.snapData});

  final SnapData snapData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localSnap = snapData.localSnap;
    final snapLauncher = snapData.isInstalled && localSnap != null
        ? ref.watch(launchProvider(localSnap))
        : null;
    final updatesModel = ref.watch(updatesModelProvider);
    final snapModel = ref.watch(snapModelProvider(snapData.name).notifier);

    final SnapAction primaryAction;
    if (snapData.isInstalled) {
      primaryAction =
          snapData.selectedChannel == snapData.localSnap!.trackingChannel ||
                  snapData.storeSnap == null
              ? SnapAction.open
              : SnapAction.switchChannel;
    } else {
      primaryAction = SnapAction.install;
    }

    final primaryActionButton = SizedBox(
      width: _kPrimaryButtonMaxWidth,
      child: PushButton.elevated(
        onPressed: snapData.activeChangeId != null
            ? null
            : primaryAction.callback(snapData, snapModel, snapLauncher),
        child: snapData.activeChangeId != null
            ? Consumer(
                builder: (context, ref, child) {
                  final change =
                      ref.watch(activeChangeProvider(snapData.activeChangeId));
                  return Row(
                    children: [
                      SizedBox.square(
                        dimension: kCircularProgressIndicatorHeight,
                        child: YaruCircularProgressIndicator(
                          value: change?.progress,
                          strokeWidth: 2,
                        ),
                      ),
                      if (change != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            change.localize(l10n) ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]
                    ],
                  );
                },
              )
            : Text(primaryAction.label(l10n)),
      ),
    );

    final secondaryActions = [
      if (updatesModel.hasUpdate(snapData.name)) SnapAction.update,
      SnapAction.remove,
    ];
    final secondaryActionsButton = MenuAnchor(
      menuChildren: secondaryActions.map((action) {
        final color = action == SnapAction.remove
            ? Theme.of(context).colorScheme.error
            : null;
        return MenuItemButton(
          onPressed: action.callback(snapData, snapModel, snapLauncher),
          child: IntrinsicWidth(
            child: ListTile(
              mouseCursor: SystemMouseCursors.click,
              leading:
                  action.icon != null ? Icon(action.icon, color: color) : null,
              title: Text(
                action.label(l10n),
                style: TextStyle(color: color),
              ),
            ),
          ),
        );
      }).toList(),
      builder: (context, controller, child) => YaruOptionButton(
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
        child: const Icon(YaruIcons.view_more_horizontal),
      ),
    );

    final cancelButton = OutlinedButton(
      onPressed: SnapAction.cancel.callback(snapData, snapModel),
      child: Text(SnapAction.cancel.label(l10n)),
    );

    return ButtonBar(
      mainAxisSize: MainAxisSize.min,
      overflowButtonSpacing: 8,
      children: [
        primaryActionButton,
        if (snapData.activeChangeId != null)
          cancelButton
        else if (snapData.isInstalled)
          secondaryActionsButton,
        if (snapData.isInstalled) ...[
          const SizedBox(width: 8),
          _RatingsActionButtons(
            snap: snapData.snap,
          ),
        ]
      ].whereNotNull().toList(),
    );
  }
}

class _RatingsActionButtons extends ConsumerWidget {
  const _RatingsActionButtons({required this.snap});

  final Snap snap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsModel = ref.watch(ratingsModelProvider(snap));

    return ratingsModel.state.when(
      data: (_) {
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
                  ratingsModel.castVote(VoteStatus.up);
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Theme.of(context).dividerColor),
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                      left: BorderSide(color: Theme.of(context).dividerColor),
                      right: BorderSide(
                          color: Theme.of(context).dividerColor, width: 0.5),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                  ),
                  child: YaruIconButton(
                    mouseCursor: SystemMouseCursors.click,
                    icon: Icon(
                      ratingsModel.vote == VoteStatus.up
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
                  ratingsModel.castVote(VoteStatus.down);
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Theme.of(context).dividerColor),
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                      left: BorderSide(
                          color: Theme.of(context).dividerColor, width: 0.5),
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
                      ratingsModel.vote == VoteStatus.down
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

class _Header extends ConsumerWidget {
  const _Header({required this.snapData});

  final SnapData snapData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = snapData.storeSnap ?? snapData.localSnap!;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const YaruBackButton(style: YaruBackButtonStyle.rounded),
            const Spacer(),
            if (snap.website != null)
              YaruIconButton(
                icon: const Icon(YaruIcons.share),
                onPressed: () {
                  final navigationKey =
                      ref.watch(materialAppNavigatorKeyProvider);

                  ScaffoldMessenger.of(navigationKey.currentContext!)
                      .showSnackBar(
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
        ),
        const SizedBox(height: kPagePadding),
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
        const SizedBox(width: 16),
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
                  MaterialStatePropertyAll(Size(_kChannelDropdownWidth, 0)),
              maximumSize:
                  MaterialStatePropertyAll(Size(_kChannelDropdownWidth, 200)),
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
                  ].map((e) => Text(e, maxLines: 1)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
