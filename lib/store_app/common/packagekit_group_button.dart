import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/packagekit_group_x.dart';
import 'package:software/store_app/common/packagekit_group_utils.dart';
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
          PopupMenuItem(
            value: group,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 5,
                ),
                SizedBox(
                  width: 20,
                  child: Icon(
                    packagekitGroupToIcon[group],
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.8),
                    size: 18,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  group.localize(context.l10n),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          )
      ],
      child: Text(value.name),
    );
  }
}
