import 'package:flutter/material.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/my_apps/my_packages_page.dart';
import 'package:software/store_app/my_apps/my_snaps_page.dart';
import 'package:software/store_app/my_apps/system_updates_page.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MyAppsPage extends StatelessWidget {
  const MyAppsPage({Key? key}) : super(key: key);

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.myAppsPageTitle);

  @override
  Widget build(BuildContext context) {
    return YaruTabbedPage(
      tabIcons: const [
        YaruIcons.package_snap,
        YaruIcons.package_deb,
        YaruIcons.synchronizing
      ],
      tabTitles: [
        context.l10n.snapPackages,
        context.l10n.debianPackages,
        context.l10n.systemUpdates,
      ],
      views: [
        MySnapsPage.create(context),
        MyPackagesPage.create(context),
        SystemUpdatesPage.create(context),
      ],
    );
  }
}
