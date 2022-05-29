import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/pages/common/apps_model.dart';
import 'package:software/pages/common/snap_model.dart';
import 'package:software/pages/explore/app_dialog.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';
import 'package:software/color_scheme.dart';

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
      YaruIcons.chip
    ], tabTitles: const [
      'Snaps',
      'Debs',
      'Firmware'
    ], views: [
      _SnapUpdatesPage.create(context),
      const Center(
        child: Text('Debs'),
      ),
      const Center(
        child: Text('Firmware'),
      )
    ]);
  }
}

class _SnapUpdatesPage extends StatefulWidget {
  const _SnapUpdatesPage({Key? key}) : super(key: key);

  @override
  State<_SnapUpdatesPage> createState() => __SnapUpdatesPageState();

  static Widget create(BuildContext context) {
    final client = getService<SnapdClient>();
    return ChangeNotifierProvider(
      create: (_) => AppsModel(client),
      child: const _SnapUpdatesPage(),
    );
  }
}

class __SnapUpdatesPageState extends State<_SnapUpdatesPage> {
  @override
  void initState() {
    super.initState();
    context.read<AppsModel>().mapSnaps();
  }

  @override
  Widget build(BuildContext context) {
    final appsModel = context.watch<AppsModel>();

    return Center(
      child: appsModel.snapAppToSnapMap.isEmpty
          ? const YaruCircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: appsModel.snapAppToSnapMap.length,
                itemBuilder: (context, index) {
                  final huskSnapName = appsModel.snapAppToSnapMap.entries
                      .elementAt(index)
                      .value
                      .name;
                  return ListTile(
                    onTap: () {
                      showDialog(
                          barrierColor: Theme.of(context).brightness ==
                                  Brightness.light
                              ? Theme.of(context).colorScheme.barrierColorLight
                              : Theme.of(context).colorScheme.barrierColorDark,
                          context: context,
                          builder: (context) {
                            final client = getService<SnapdClient>();

                            return ChangeNotifierProvider(
                                create: (context) => SnapModel(
                                    client: client, huskSnapName: huskSnapName),
                                child: const AppDialog());
                          });
                    },
                    leading: const Icon(YaruIcons.package_snap),
                    title: Text(appsModel.snapAppToSnapMap.entries
                            .elementAt(index)
                            .key
                            .snap ??
                        ''),
                  );
                },
              ),
            ),
    );
  }
}
