import 'package:flutter/material.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/my_apps/sort_by.dart';
import 'package:yaru_icons/yaru_icons.dart';

class SortByDropdown extends StatelessWidget {
  const SortByDropdown({Key? key, required this.value, required this.onChanged})
      : super(key: key);
  final SortBy value;
  final Function(SortBy?)? onChanged;
  @override
  Widget build(BuildContext context) {
    return DropdownButton<SortBy>(
      icon: const Icon(YaruIcons.pan_down),
      value: value,
      items: [
        for (final sortBy in SortBy.values)
          DropdownMenuItem(
            value: sortBy,
            child: Text('Sort by: ${sortBy.localize(context.l10n)}'),
          ),
      ],
      onChanged: onChanged,
      borderRadius: BorderRadius.circular(10),
    );
  }
}
