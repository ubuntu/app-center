import 'package:app_center/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';

const kChannelDropdownWidth = 350.0;

class ChannelDropdown extends StatelessWidget {
  const ChannelDropdown({
    required this.channels,
    required this.selected,
    required this.label,
    required this.onSelected,
    this.width = kChannelDropdownWidth,
    super.key,
  });

  final List<String> channels;
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
        values: channels,
        itemBuilder: (context, value, child) => Text(value),
        selected: selected,
        onSelected: onSelected,
        menuPosition: PopupMenuPosition.under,
        menuStyle: MenuStyle(
          minimumSize: WidgetStatePropertyAll(Size(width, 0)),
          maximumSize: WidgetStatePropertyAll(Size(width, 200)),
        ),
        child: Text(
          label,
          semanticsLabel: '${l10n.snapPageChannelLabel} $label',
        ),
      ),
    );
  }
}
