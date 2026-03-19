import 'package:app_center/apps/app_page.dart';
import 'package:app_center/apps/app_title_bar.dart';
import 'package:app_center/constants.dart';
import 'package:app_center/error/error.dart';
import 'package:app_center/extensions/string_extensions.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/local_snap_providers.dart';
import 'package:app_center/manage/quit_to_update_notice.dart';
import 'package:app_center/ratings/ratings.dart';
import 'package:app_center/snapd/snap_report.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/snapd/snapd_cache.dart';
import 'package:app_center/store/store_app.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
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
    final layout = ResponsiveLayout.of(context);

    return AppPage(
      titleBar:
          AppTitleBar.fromSnap(snapData, actions: _IconRow(snapData: snapData)),
      actionBar: Wrap(
        runSpacing: kSpacing,
        spacing: kSpacing,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PrimaryActionButton(
                snapName: snapData.name,
                isPrimary: true,
              ),
            ],
          ),
          if (snapData.availableChannels != null &&
              snapData.selectedChannel != null) ...[
            _ChannelDropdown(snapData: snapData),
            _SwitchChannelButton(snapData: snapData),
          ],
          if (snapData.isInstalled) ...[
            _RatingsActionButtons(snap: snapData.snap),
          ],
          _MoreActionsButton(snapData: snapData),
        ],
      ),
      infoBar: SnapInfoBar(snapData: snapData),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (snapData.hasGallery) ...[
            ScreenshotGallery(
              title: snapData.storeSnap!.titleOrName,
              urls: snapData.storeSnap!.screenshotUrls,
              height: layout.totalWidth / 2,
            ),
            const SizedBox(height: kSectionSpacing),
          ],
          Text(
            snapData.snap.summary,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: kPagePadding),
          MarkdownBody(
            selectable: true,
            data: snapData.snap.description.escapedMarkdown(),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends ConsumerWidget {
  const _PrimaryActionButton({
    required this.snapName,
    required this.isPrimary,
  });

  final String snapName;
  final bool isPrimary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snapModel = ref.watch(snapModelProvider(snapName));
    if (!snapModel.hasValue) {
      return const Center(
        child: SizedBox.square(
          dimension: kLoaderMediumHeight,
          child: YaruCircularProgressIndicator(),
        ),
      );
    }

    final snapData = snapModel.value!;
    final shouldQuitToUpdate = snapData.localSnap?.refreshInhibit != null;
    final snap = snapData.snap;
    final snapViewModel = ref.watch(snapModelProvider(snap.name).notifier);
    final snapLauncher = snapData.localSnap == null
        ? null
        : ref.watch(launchProvider(snapData.localSnap!));
    final hasActiveChange = snapData.activeChangeId != null;

    final primaryAction = snapData.primaryAction(snapLauncher);

    if (hasActiveChange) {
      return ActiveChangeStatus(
        snapName: snap.name,
        activeChangeId: snapData.activeChangeId!,
      );
    }

    if (shouldQuitToUpdate) {
      return const QuitToUpdateNotice();
    }

    return (isPrimary ? YaruSplitButton.new : YaruSplitButton.outlined.call)(
      onPressed: snapData.activeChangeId == null
          ? primaryAction?.callback(
              snapData,
              snapViewModel,
              snapLauncher,
              context,
            )
          : null,
      child: Text(
        primaryAction?.label(l10n) ?? SnapAction.open.label(l10n),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _MoreActionsButton extends ConsumerWidget {
  const _MoreActionsButton({required this.snapData});

  final SnapData snapData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final snapLauncher = snapData.localSnap == null
        ? null
        : ref.watch(launchProvider(snapData.localSnap!));
    final snapViewModel = ref.watch(snapModelProvider(snapData.name).notifier);

    final primaryAction = snapData.primaryAction(snapLauncher);
    final secondaryActions = snapData.secondaryActions(snapLauncher)
      ..remove(primaryAction ?? SnapAction.open);

    return secondaryActions.isNotEmpty
        ? YaruPopupMenuButton(
            semanticLabel: l10n.appMoreActionsSemanticLabel,
            childPadding: EdgeInsets.symmetric(horizontal: 2),
            itemBuilder: (context) => [
              ...secondaryActions.map((action) {
                final color = action == SnapAction.remove
                    ? Theme.of(context).colorScheme.error
                    : null;
                return PopupMenuItem(
                  onTap: action.callback(
                    snapData,
                    snapViewModel,
                    snapLauncher,
                    context,
                  ),
                  child: IntrinsicWidth(
                    child: ListTile(
                      mouseCursor: SystemMouseCursors.click,
                      title: Text(
                        action.label(l10n),
                        style: TextStyle(color: color),
                      ),
                    ),
                  ),
                );
              }),
            ],
            onSelected: (value) => {},
            child: Icon(YaruIcons.view_more),
          )
        : SizedBox.shrink();
  }
}

class _SwitchChannelButton extends ConsumerWidget {
  const _SwitchChannelButton({required this.snapData});

  final SnapData snapData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final hasChangedChannel = snapData.selectedChannel != null &&
        snapData.localSnap?.trackingChannel != null &&
        snapData.selectedChannel != snapData.localSnap!.trackingChannel;
    final snapViewModel = ref.watch(snapModelProvider(snapData.name).notifier);
    final snapLauncher = snapData.localSnap == null
        ? null
        : ref.watch(launchProvider(snapData.localSnap!));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        YaruSplitButton.outlined(
          onPressed: hasChangedChannel && snapData.activeChangeId == null
              ? SnapAction.switchChannel.callback(
                  snapData,
                  snapViewModel,
                  snapLauncher,
                  context,
                )
              : null,
          child: Text(l10n.snapActionSwitchChannelLabel),
        ),
      ],
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
            icon: Icon(
              YaruIcons.share,
              semanticLabel: l10n.snapPageShareSemanticLabel,
            ),
            onPressed: () {
              final navigationKey = ref.watch(materialAppNavigatorKeyProvider);
              final snapStoreUrl = '$snapStoreBaseUrl/${snapData.name}';

              ScaffoldMessenger.of(navigationKey.currentContext!).showSnackBar(
                SnackBar(
                  content: Text(l10n.snapPageShareLinkCopiedMessage),
                ),
              );
              Clipboard.setData(ClipboardData(text: snapStoreUrl));
            },
          ),
        YaruIconButton(
          icon: Icon(
            YaruIcons.flag,
            semanticLabel: l10n.snapPageReportSemanticLabel,
          ),
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
    final channelText =
        '${snapData.selectedChannel} ${snapData.availableChannels![snapData.selectedChannel]!.version}';
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
              channelText,
              semanticsLabel: '${l10n.snapPageChannelLabel} $channelText',
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

    final channelInfo = {
      l10n.snapPageChannelLabel: channelEntry.key,
      l10n.snapPageVersionLabel: channelEntry.value.version,
      l10n.snapPagePublishedLabel:
          DateFormat.yMd().format(channelEntry.value.releasedAt),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              overflow: TextOverflow.ellipsis,
            ),
        child: SizedBox(
          width: _kChannelDropdownWidth - 24,
          child: Semantics(
            button: true,
            label:
                channelInfo.entries.map((e) => '${e.key} ${e.value}').join(' '),
            child: ExcludeSemantics(
              child: Row(
                children: [
                  DefaultTextStyle.merge(
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: channelInfo.keys.map(Text.new).toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: channelInfo.values.nonNulls
                          .map((e) => Text(e, maxLines: 1))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
