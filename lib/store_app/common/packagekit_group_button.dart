import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/packagekit_group_x.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PackageKitGroupButton extends StatelessWidget {
  const PackageKitGroupButton({
    super.key,
    required this.onSelected,
    required this.value,
  });

  final PackageKitGroup value;
  final Function(PackageKitGroup)? onSelected;

  @override
  Widget build(BuildContext context) {
    return YaruPopupMenuButton<PackageKitGroup>(
      onSelected: onSelected,
      initialValue: value,
      tooltip: context.l10n.packageKitGroup,
      items: [
        for (final group in PackageKitGroup.values)
          PopupMenuItem(value: group, child: Text(group.localize(context.l10n)))
      ],
      child: Text(value.name),
    );
  }
}
