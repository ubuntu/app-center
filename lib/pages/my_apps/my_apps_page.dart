import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/pages/common/apps_model.dart';
import 'package:software/pages/common/snap_model.dart';
import 'package:software/pages/common/snap_tile.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MyAppsPage extends StatefulWidget {
  const MyAppsPage({Key? key}) : super(key: key);

  @override
  State<MyAppsPage> createState() => _MyAppsPageState();

  static Widget create(BuildContext context) {
    final client = getService<SnapdClient>();
    final connectivity = getService<Connectivity>();
    return ChangeNotifierProvider(
      create: (_) => AppsModel(client, connectivity),
      child: const MyAppsPage(),
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.myAppsPageTitle);
}

class _MyAppsPageState extends State<MyAppsPage> {
  @override
  void initState() {
    super.initState();
    final appsModel = context.read<AppsModel>();
    appsModel.mapSnaps();
    appsModel.initConnectivity();
  }

  @override
  Widget build(BuildContext context) {
    final appsModel = context.watch<AppsModel>();

    if (!appsModel.appIsOnline) {
      return const Center(
        child: YaruCircularProgressIndicator(),
      );
    } else {
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
                    return ChangeNotifierProvider(
                      create: (context) => SnapModel(
                        client: getService<SnapdClient>(),
                        huskSnapName: huskSnapName,
                      ),
                      child: SnapTile(
                        appIsOnline: appsModel.appIsOnline,
                        snapApp: appsModel.snapAppToSnapMap.entries
                            .elementAt(index)
                            .key,
                      ),
                    );
                  },
                ),
              ),
      );
    }
  }
}
