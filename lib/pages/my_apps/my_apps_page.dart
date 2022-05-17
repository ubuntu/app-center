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
                            builder: (context) => ChangeNotifierProvider.value(
                              value: model,
                              child: MyAppsDialog(
                                snapApp: snapApp,
                              ),
                            ),
                          )
                        },
                        child: ListTile(
                            leading: Icon(YaruIcons.package_snap),
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

class MyAppsDialog extends StatelessWidget {
  const MyAppsDialog({Key? key, required this.snapApp}) : super(key: key);

  final SnapApp snapApp;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MyAppsModel>();
    return SimpleDialog(
      titlePadding: EdgeInsets.zero,
      title: YaruDialogTitle(
        title: snapApp.name,
        closeIconData: YaruIcons.window_close,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed:
                model.uninstalling ? null : () => model.unInstallSnap(snapApp),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Uninstall',
                  style: TextStyle(
                    color: model.uninstalling
                        ? Theme.of(context).disabledColor
                        : Theme.of(context).errorColor,
                  ),
                ),
                if (model.uninstalling)
                  SizedBox(
                      height: 15,
                      child: YaruCircularProgressIndicator(
                        strokeWidth: 2,
                        color: model.uninstalling
                            ? Theme.of(context).disabledColor
                            : Theme.of(context).errorColor,
                      ))
              ],
            ),
          ),
        )
      ],
    );
  }
}
