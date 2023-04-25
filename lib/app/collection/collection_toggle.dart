import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/app_page/app_format_toggle_buttons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class CollectionToggle extends StatelessWidget {
  const CollectionToggle({
    super.key,
    required this.onSelected,
    required this.appFormat,
    required this.enabledAppFormats,
    this.badgedAppFormats,
  });

  final void Function(AppFormat appFormat) onSelected;
  final AppFormat appFormat;
  final Set<AppFormat> enabledAppFormats;
  final Map<AppFormat, int>? badgedAppFormats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!enabledAppFormats.contains(AppFormat.packageKit)) {
      return YaruBorderContainer(
        color: theme.colorScheme.outline,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        borderRadius:
            const BorderRadius.all(Radius.circular(kYaruButtonRadius)),
        child: const SizedBox(
          height: 39,
          child: AppFormatLabel(
            appFormat: AppFormat.snap,
            isSelected: true,
          ),
        ),
      );
    }

    var appFormatToggleButtons = AppFormatToggleButtons(
      onPressed: (index) => onSelected(
        index == 0 ? AppFormat.snap : AppFormat.packageKit,
      ),
      isSelected: [
        appFormat == AppFormat.snap,
        appFormat == AppFormat.packageKit
      ],
    );

    if (badgedAppFormats == null) {
      return appFormatToggleButtons;
    }

    Widget toggle() {
      if (badgedAppFormats![AppFormat.snap] != null &&
          badgedAppFormats![AppFormat.snap]! > 0) {
        return badges.Badge(
          position: badges.BadgePosition.topStart(start: -3, top: -3),
          badgeColor: theme.primaryColor,
          showBadge: appFormat == AppFormat.packageKit,
          child: appFormatToggleButtons,
        );
      } else {
        if (badgedAppFormats![AppFormat.packageKit] != null &&
            badgedAppFormats![AppFormat.packageKit]! > 0) {
          return badges.Badge(
            animationType: badges.BadgeAnimationType.fade,
            position: badges.BadgePosition.topEnd(top: -3, end: -3),
            badgeColor: theme.primaryColor,
            showBadge: appFormat == AppFormat.snap,
            child: appFormatToggleButtons,
          );
        } else {
          return appFormatToggleButtons;
        }
      }
    }

    return toggle();
  }
}
