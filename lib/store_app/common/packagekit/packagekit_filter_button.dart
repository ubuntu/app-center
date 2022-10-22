import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/packagekit_filter_x.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PackageKitFilterButton extends StatelessWidget {
  const PackageKitFilterButton({
    super.key,
    required this.onTap,
    required this.filters,
  });

  final Set<PackageKitFilter> filters;
  final Function(PackageKitFilter filter) onTap;

  @override
  Widget build(BuildContext context) {
    return YaruPopupMenuButton<Set<PackageKitFilter>>(
      itemBuilder: (context) {
        return [
          for (final filter in PackageKitFilter.values)
            PopupMenuItem(
              padding: EdgeInsets.zero,
              child: YaruMultiSelectItem<PackageKitFilter>(
                values: filters,
                value: filter,
                onTap: () => onTap(filter),
                child: Text(
                  filter.localize(context.l10n),
                ),
              ),
            ),
        ];
      },
      child: Text(context.l10n.packageKitFilter),
    );
  }
}
