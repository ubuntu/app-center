import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/my_apps/my_apps_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MyAppsPage extends StatelessWidget {
  const MyAppsPage({super.key});

  static Widget create(BuildContext context) {
    final client = Provider.of<SnapdClient>(context, listen: false);
    return ChangeNotifierProvider<MyAppsModel>(
      create: (_) => MyAppsModel(client),
      child: const MyAppsPage(),
    );
  }

  static Widget createTitle(BuildContext context) => Text('My Apps');

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MyAppsModel>();
    return FutureBuilder<List<SnapApp>>(
        future: model.snapApps,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!
                  .map((snapApp) => InkWell(
                        onTap: () => {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  StatefulBuilder(builder: (context, setState) {
                                    return YaruAlertDialog(
                                      closeIconData: YaruIcons.window_close,
                                      title: snapApp.name,
                                      child: SizedBox(
                                        height: 100,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TextButton(
                                              onPressed: () async =>
                                                  model.unInstallSnap(snapApp),
                                              child: Text(
                                                'Uninstall',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .errorColor),
                                              ),
                                            ),
                                            if (model.uninstalling)
                                              YaruCircularProgressIndicator()
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        OutlinedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Close'),
                                        ),
                                      ],
                                    );
                                  }))
                        },
                        child: ListTile(
                            leading: Icon(YaruIcons.package),
                            title: Text(snapApp.name)),
                      ))
                  .toList(),
            );
          }
          return Center(
            child: YaruCircularProgressIndicator(),
          );
        });
  }
}
