import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/pages/common/apps_model.dart';
import 'package:software/pages/explore/app_dialog.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) {
    final client = context.read<SnapdClient>();
    return ChangeNotifierProvider(
      create: (_) => AppsModel(client),
      child: UpdatesPage(),
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.updatesPageTitle);

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  @override
  void initState() {
    context.read<AppsModel>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppsModel>();
    return YaruTabbedPage(tabIcons: [
      YaruIcons.package_snap,
      YaruIcons.package_deb,
      YaruIcons.chip
    ], tabTitles: [
      'Snaps',
      'Debs',
      'Firmware'
    ], views: [
      Center(
        child: model.snapAppToSnapMap.isEmpty
            ? YaruCircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: model.snapAppToSnapMap.length,
                  itemBuilder: (context, index) => ListTile(
                    onTap: () {
                      model.currentSnapChannel = model.snapAppToSnapMap.entries
                          .elementAt(index)
                          .value
                          .channel;
                      showDialog(
                          context: context,
                          builder: (context) => ChangeNotifierProvider.value(
                                value: model,
                                child: AppDialog(
                                    snap: model.snapAppToSnapMap.entries
                                        .elementAt(index)
                                        .value),
                              ));
                    },
                    leading: Icon(YaruIcons.package_snap),
                    title: Text(model.snapAppToSnapMap.entries
                            .elementAt(index)
                            .key
                            .snap ??
                        ''),
                  ),
                ),
              ),
      ),
      Center(
        child: Text('Debs'),
      ),
      Center(
        child: Text('Firmware'),
      )
    ]);
  }
}
