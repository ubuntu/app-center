import 'package:flutter/material.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/my_apps/my_packages_page.dart';
import 'package:software/store_app/my_apps/my_snaps_page.dart';
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
        YaruIcons.computer
      ],
      tabTitles: [
        context.l10n.snapPackages,
        context.l10n.debianPackages,
        context.l10n.systemUpdates,
      ],
      views: [
        MySnapsPage.create(context),
        MyPackagesPage.create(context),
        const Center(
          child: Icon(
            YaruIcons.computer,
            size: 100,
          ),
        )
      ],
    );
  }
}

const myAppsGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  mainAxisExtent: 110,
  mainAxisSpacing: 15,
  crossAxisSpacing: 15,
  maxCrossAxisExtent: 600,
);
