import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/indeterminate_circular_progress_icon.dart';
import 'package:software/app/updates/package_updates_page.dart';
import 'package:software/app/updates/snap_updates_page.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({
    super.key,
    this.onTabTapped,
    this.tabIndex = 0,
  });

  final Function(int)? onTabTapped;
  final int tabIndex;

  static Widget create(
    BuildContext context,
    Function(int)? onTabTapped,
    int tabIndex,
  ) =>
      UpdatesPage(
        tabIndex: tabIndex,
        onTabTapped: onTabTapped,
      );

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
    return DefaultTabController(
      initialIndex: widget.tabIndex,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: TabBar(
            onTap: (value) {
              if (widget.onTabTapped != null) {
                widget.onTabTapped!(value);
              }
            },
            tabs: [
              Tab(
                icon: _TabChild(
                  iconData: YaruIcons.snapcraft,
                  label: context.l10n.snapPackages,
                ),
              ),
              Tab(
                icon: _TabChild(
                  iconData: YaruIcons.debian,
                  label: context.l10n.debianPackages,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SnapUpdatesPage.create(context),
            PackageUpdatesPage.create(context),
          ],
        ),
      ),
    );
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          iconData,
          size: 18,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(label)
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
    if (processing && count > 0) {
      return Badge(
        position: BadgePosition.topEnd(),
        badgeColor:
            count > 0 ? Theme.of(context).primaryColor : Colors.transparent,
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
        badgeColor: Theme.of(context).primaryColor,
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
