import 'dart:math';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/indeterminate_circular_progress_icon.dart';
import 'package:software/app/updates/package_updates_page.dart';
import 'package:software/app/updates/snap_updates_page.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({
    super.key,
    this.onTabTapped,
    this.tabIndex = 0,
    required this.windowWidth,
  });

  final Function(int)? onTabTapped;
  final int tabIndex;
  final double windowWidth;

  static Widget createTitle(BuildContext context) => Text(context.l10n.updates);

  static Widget createIcon({
    required BuildContext context,
    required bool selected,
    int? badgeCount,
    bool? processing,
  }) {
    return _UpdatesIcon(
      count: badgeCount ?? 0,
      processing: processing ?? false,
    );
  }

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final packageService = getService<PackageService>();
    final padding = 0.0004 * pow((widget.windowWidth * 0.85), 2);

    if (!packageService.isAvailable) {
      return Scaffold(
        appBar: YaruWindowTitleBar(
          title: Text(context.l10n.updates),
        ),
        body: SnapUpdatesPage.create(context),
      );
    } else {
      return DefaultTabController(
        initialIndex: widget.tabIndex,
        length: 2,
        child: Scaffold(
          appBar: YaruWindowTitleBar(
            titleSpacing: 0,
            title: Container(
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kYaruButtonRadius),
              ),
              child: TabBar(
                padding: EdgeInsets.symmetric(horizontal: padding / 2),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(kYaruButtonRadius),
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                ),
                labelColor: theme.colorScheme.onSurface,
                splashBorderRadius: BorderRadius.circular(kYaruButtonRadius),
                onTap: (value) {
                  if (widget.onTabTapped != null) {
                    widget.onTabTapped!(value);
                  }
                },
                tabs: [
                  Tab(
                    child: _TabChild(
                      iconData: YaruIcons.debian,
                      label: context.l10n.debianPackages,
                    ),
                  ),
                  Tab(
                    child: _TabChild(
                      iconData: YaruIcons.snapcraft,
                      label: context.l10n.snapPackages,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              PackageUpdatesPage.create(context),
              SnapUpdatesPage.create(context),
            ],
          ),
        ),
      );
    }
  }
}

class _TabChild extends StatelessWidget {
  const _TabChild({
    Key? key,
    required this.iconData,
    required this.label,
  }) : super(key: key);

  final IconData iconData;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabTextStyle = theme.textTheme.labelLarge;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          iconData,
          size: 18,
        ),
        const SizedBox(
          width: 10,
        ),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: tabTextStyle,
          ),
        )
      ],
    );
  }
}

class _UpdatesIcon extends StatelessWidget {
  const _UpdatesIcon({
    // ignore: unused_element
    super.key,
    required this.count,
    required this.processing,
  });

  final int count;
  final bool processing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (processing && count > 0) {
      return Badge(
        position: BadgePosition.topEnd(),
        badgeColor: count > 0 ? theme.primaryColor : Colors.transparent,
        badgeContent: count > 0
            ? Text(
                count.toString(),
                style: badgeTextStyle,
              )
            : null,
        child: const IndeterminateCircularProgressIcon(),
      );
    } else if (processing && count == 0) {
      return const IndeterminateCircularProgressIcon();
    } else if (!processing && count > 0) {
      return Badge(
        badgeColor: theme.primaryColor,
        badgeContent: Text(
          count.toString(),
          style: badgeTextStyle,
        ),
        child: const Icon(YaruIcons.sync),
      );
    }
    return const Icon(YaruIcons.sync);
  }
}
