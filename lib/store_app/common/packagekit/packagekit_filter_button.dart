import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/packagekit_filter_x.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PackageKitFilterButton extends StatelessWidget {
  const PackageKitFilterButton({
    super.key,
    required this.onSelected,
    required this.value,
  });

  final PackageKitFilter value;
  final Function(PackageKitFilter)? onSelected;

  @override
  Widget build(BuildContext context) {
    return YaruPopupMenuButton<PackageKitFilter>(
      onSelected: onSelected,
      initialValue: value,
      tooltip: context.l10n.packageKitFilter,
      items: [
        for (final v in PackageKitFilter.values)
          PopupMenuItem(value: v, child: Text(v.localize(context.l10n)))
      ],
      child: Text(value.name),
    );
  }
}
