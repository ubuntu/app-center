import 'package:flutter/material.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/pages/updates/snap_updates_page.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) {
    return const UpdatesPage();
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.updatesPageTitle);

  @override
  Widget build(BuildContext context) {
    return YaruTabbedPage(tabIcons: const [
      YaruIcons.package_snap,
      YaruIcons.package_deb,
    ], tabTitles: const [
      'Snaps',
      'Debs',
    ], views: [
      SnapUpdatesPage.create(context),
      const Center(
        child: Text('Debs'),
      ),
    ]);
  }
}
