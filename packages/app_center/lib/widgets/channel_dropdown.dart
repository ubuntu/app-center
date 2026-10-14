import 'package:app_center/apps/app_details_labels.dart';
import 'package:app_center/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';

const kChannelDropdownWidth = 350.0;

class ChannelDropdownItem {
  const ChannelDropdownItem({
    required this.name,
    this.version,
    this.releasedAt,
  });

  final String name;
  final String? version;
  final DateTime? releasedAt;
}

class ChannelDropdown extends StatelessWidget {
  const ChannelDropdown({
    required this.channels,
    required this.selected,
    required this.label,
    required this.onSelected,
    this.width = kChannelDropdownWidth,
    super.key,
  });

  final List<ChannelDropdownItem> channels;
  final String? selected;
  final String label;
  final ValueChanged<String> onSelected;
  final double width;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: width,
      child: MenuButtonBuilder<String>(
        entries: [
          for (final (index, channel) in channels.indexed) ...[
            if (index > 0) const MenuButtonEntry(value: '', isDivider: true),
            MenuButtonEntry(
              value: channel.name,
              child: _ChannelDropdownEntry(channel: channel, width: width),
            ),
          ],
        ],
        itemBuilder: (context, value, child) => Text(value),
        selected: selected,
        onSelected: onSelected,
        menuPosition: PopupMenuPosition.under,
        menuStyle: MenuStyle(
          minimumSize: WidgetStatePropertyAll(Size(width, 0)),
          maximumSize: WidgetStatePropertyAll(Size(width, 200)),
          visualDensity: VisualDensity.standard,
        ),
        itemStyle: MenuItemButton.styleFrom(
          maximumSize: const Size.fromHeight(100),
        ),
        child: Text(
          label,
          semanticsLabel: '${l10n.snapPageChannelLabel} $label',
        ),
      ),
    );
  }
}

class _ChannelDropdownEntry extends StatelessWidget {
  const _ChannelDropdownEntry({required this.channel, required this.width});

  final ChannelDropdownItem channel;
  final double width;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final releasedAt = channel.releasedAt;

    final channelInfo = {
      l10n.snapPageChannelLabel: channel.name,
      l10n.snapPageVersionLabel: channel.version ?? kMissingValue,
      l10n.snapPagePublishedLabel: releasedAt != null
          ? DateFormat.yMd().format(releasedAt)
          : kMissingValue,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          overflow: TextOverflow.ellipsis,
        ),
        child: SizedBox(
          width: width - 24,
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
                      children: channelInfo.values
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
