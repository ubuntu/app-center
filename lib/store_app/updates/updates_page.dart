import 'package:flutter/material.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/updates/package_updates_page.dart';
import 'package:software/store_app/updates/snap_updates_page.dart';
import 'package:yaru_icons/yaru_icons.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key});

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: TabBar(
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
