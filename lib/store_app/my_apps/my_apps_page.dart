import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/app_change_service.dart';
import 'package:software/store_app/common/apps_model.dart';
import 'package:software/store_app/my_apps/local_snap_banner.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MyAppsPage extends StatefulWidget {
  const MyAppsPage({Key? key, this.online = true}) : super(key: key);

  final bool online;

  @override
  State<MyAppsPage> createState() => _MyAppsPageState();

  static Widget create(BuildContext context, bool online) {
    return ChangeNotifierProvider(
      create: (_) => AppsModel(
        getService<SnapdClient>(),
        getService<AppChangeService>(),
      ),
      child: MyAppsPage(
        online: online,
      ),
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.myAppsPageTitle);
}

class _MyAppsPageState extends State<MyAppsPage> {
  @override
  void initState() {
    final appsModel = context.read<AppsModel>();
    appsModel.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appsModel = context.watch<AppsModel>();

    return YaruTabbedPage(
      tabIcons: const [YaruIcons.package_snap, YaruIcons.package_deb],
      tabTitles: const ['Snaps', 'Debian packages'],
      views: [
        Center(
          child: appsModel.localSnaps.isEmpty
              ? const YaruCircularProgressIndicator()
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      mainAxisExtent: 110,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      maxCrossAxisExtent: 1000,
                    ),
                    shrinkWrap: true,
                    itemCount: appsModel.localSnaps.length,
                    itemBuilder: (context, index) {
                      final snap = appsModel.localSnaps.elementAt(index);

                      return LocalSnapBanner.create(
                        context,
                        snap.name,
                        widget.online,
                      );
                    },
                  ),
                ),
        ),
        const Center(
          child: Text('Debian'),
        )
      ],
    );
  }
}
