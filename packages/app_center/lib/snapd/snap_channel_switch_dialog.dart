import 'package:app_center/constants.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru/yaru.dart';

const _kChannelDropdownWidth = 350.0;

class ChannelSwitchDialog extends ConsumerWidget {
  const ChannelSwitchDialog({required this.snapName, super.key});

  final String snapName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(snapModelProvider(snapName));
    final l10n = AppLocalizations.of(context);

    return ResponsiveLayoutBuilder(
      builder: (context) => SimpleDialog(
        contentPadding: const EdgeInsets.all(20),
        titlePadding: EdgeInsets.zero,
        title: YaruDialogTitleBar(
          title: snap.whenOrNull(
            data: (snapData) =>
                Text(l10n.snapActionSwitchChannelTitle(snapData.name)),
          ),
        ),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                snap.whenOrNull(
                  data: (snapData) => [
                    _ChannelDropdown(snapData: snapData),
                    const SizedBox(height: kPagePadding),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _SwitchChannelButton(snapData: snapData),
                      ],
                    ),
                  ],
                ) ??
                [],
          ),
        ],
      ),
    );
  }
}

class _SwitchChannelButton extends ConsumerWidget {
  const _SwitchChannelButton({required this.snapData});

  final SnapData snapData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final hasChangedChannel =
        snapData.selectedChannel != null &&
        snapData.localSnap?.trackingChannel != null &&
        snapData.selectedChannel != snapData.localSnap!.trackingChannel;
    final snapViewModel = ref.watch(snapModelProvider(snapData.name).notifier);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        YaruSplitButton.outlined(
          onPressed: hasChangedChannel && snapData.activeChangeId == null
              ? () {
                  snapViewModel.refresh();
                  Navigator.of(context).pop();
                }
              : null,
          child: Stack(
            alignment: AlignmentGeometry.center,
            children: [
              Visibility(
                maintainSize: true,
                maintainSemantics: true,
                maintainAnimation: true,
                maintainState: true,
                visible: snapData.activeChangeId == null,
                child: Text(l10n.snapActionSwitchChannelLabel),
              ),
              if (snapData.activeChangeId != null)
                const SizedBox.square(
                  dimension: kLoaderHeight,
                  child: YaruCircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.snapPageChannelLabel,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: kSpacingSmall),
        SizedBox(
          width: _kChannelDropdownWidth,
          child: MenuButtonBuilder(
            entries:
                snapData.availableChannels!.entries
                    .map(
                      (channelEntry) => MenuButtonEntry(
                        value: channelEntry.key,
                        child: _ChannelDropdownEntry(
                          channelEntry: channelEntry,
                        ),
                      ),
                    )
                    .fold(
                      <MenuButtonEntry<String>>[],
                      (p, e) => [
                        ...p,
                        e,
                        const MenuButtonEntry(value: '', isDivider: true),
                      ],
                    )
                  ..removeLast(),
            itemBuilder: (context, value, child) => Text(value),
            selected: snapData.selectedChannel,
            onSelected: (value) => ref
                .read(snapModelProvider(snapData.name).notifier)
                .selectChannel(value),
            menuPosition: PopupMenuPosition.under,
            menuStyle: const MenuStyle(
              minimumSize: WidgetStatePropertyAll(
                Size(_kChannelDropdownWidth, 0),
              ),
              maximumSize: WidgetStatePropertyAll(
                Size(_kChannelDropdownWidth, 200),
              ),
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
      l10n.snapPagePublishedLabel: DateFormat.yMd().format(
        channelEntry.value.releasedAt,
      ),
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
            label: channelInfo.entries
                .map((e) => '${e.key} ${e.value}')
                .join(' '),
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
