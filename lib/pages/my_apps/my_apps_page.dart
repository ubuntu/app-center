import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/pages/common/apps_model.dart';
import 'package:software/pages/common/snap_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MyAppsPage extends StatefulWidget {
  const MyAppsPage({super.key});

  static Widget create(BuildContext context) {
    final client = getService<SnapdClient>();
    return ChangeNotifierProvider<AppsModel>(
      create: (_) => AppsModel(client),
      child: const MyAppsPage(),
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.myAppsPageTitle);

  @override
  State<MyAppsPage> createState() => _MyAppsPageState();
}

class _MyAppsPageState extends State<MyAppsPage> {
  @override
  void initState() {
    context.read<AppsModel>().loadSnapApps();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appsModel = context.watch<AppsModel>();

    if (appsModel.snapApps.isNotEmpty) {
      return ListView(
        children: appsModel.snapApps
            .map((snapApp) => InkWell(
                  onTap: () => {
                    showDialog(
                      context: context,
                      builder: (context) => snapApp.snap != null
                          ? ChangeNotifierProvider(
                              create: (context) => SnapModel(
                                  client: getService<SnapdClient>(),
                                  huskSnapName: snapApp.snap!),
                              child: MyAppsDialog(
                                snapApp: snapApp,
                              ),
                            )
                          : const AlertDialog(
                              content: Center(
                                child: YaruCircularProgressIndicator(),
                              ),
                            ),
                    ).then((value) => appsModel.loadSnapApps)
                  },
                  child: ListTile(
                      leading: const Icon(YaruIcons.package_snap),
                      title: Text(snapApp.name)),
                ))
            .toList(),
      );
    }
    return const Center(
      child: YaruCircularProgressIndicator(),
    );
  }
}

class MyAppsDialog extends StatelessWidget {
  const MyAppsDialog({Key? key, required this.snapApp}) : super(key: key);

  final SnapApp snapApp;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();
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
            onPressed: model.appChangeInProgress
                ? null
                : () => model.unInstallSnap(snapApp),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Uninstall',
                  style: TextStyle(
                    color: model.appChangeInProgress
                        ? Theme.of(context).disabledColor
                        : Theme.of(context).errorColor,
                  ),
                ),
                if (model.appChangeInProgress)
                  SizedBox(
                      height: 15,
                      child: YaruCircularProgressIndicator(
                        strokeWidth: 2,
                        color: model.appChangeInProgress
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
