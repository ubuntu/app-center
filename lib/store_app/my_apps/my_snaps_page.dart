import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/app_change_service.dart';
import 'package:software/store_app/my_apps/local_snap_banner.dart';
import 'package:software/store_app/my_apps/my_apps_page.dart';
import 'package:software/store_app/my_apps/my_snaps_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class MySnapsPage extends StatefulWidget {
  const MySnapsPage({Key? key, required this.online}) : super(key: key);

  final bool online;

  static Widget create(BuildContext context, bool online) =>
      ChangeNotifierProvider(
        create: (context) => MySnapsModel(
          getService<SnapdClient>(),
          getService<AppChangeService>(),
        ),
        child: MySnapsPage(
          online: online,
        ),
      );

  @override
  State<MySnapsPage> createState() => _MySnapsPageState();
}

class _MySnapsPageState extends State<MySnapsPage> {
  @override
  void initState() {
    context.read<MySnapsModel>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mySnapsModel = context.watch<MySnapsModel>();
    return mySnapsModel.localSnaps.isNotEmpty
        ? GridView.builder(
            padding: const EdgeInsets.all(20.0),
            gridDelegate: myAppsGridDelegate,
            shrinkWrap: true,
            itemCount: mySnapsModel.localSnaps.length,
            itemBuilder: (context, index) {
              final snap = mySnapsModel.localSnaps.elementAt(index);
              return LocalSnapBanner.create(
                context,
                snap.name,
                widget.online,
              );
            },
          )
        : const SizedBox();
  }
}
