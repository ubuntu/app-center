import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/pages/common/apps_model.dart';
import 'package:software/pages/common/snap_model.dart';
import 'package:software/pages/explore/app_dialog.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:xdg_icons/xdg_icons.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MyAppsPage extends StatefulWidget {
  const MyAppsPage({super.key});

  static Widget create(BuildContext context) {
    final client = getService<SnapdClient>();
    final connectivity = getService<Connectivity>();
    return ChangeNotifierProvider<AppsModel>(
      create: (_) => AppsModel(client, connectivity),
      child: const MyAppsPage(),
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.myAppsPageTitle);

  @override
  State<MyAppsPage> createState() => _MyAppsPageState();
}

class _MyAppsPageState extends State<MyAppsPage> {
  bool appIsOnline = false;
  @override
  void initState() {
    super.initState();
    final appsModel = context.read<AppsModel>();
    appsModel.loadSnapApps();
    appsModel.init();
  }

  @override
  Widget build(BuildContext context) {
    final appsModel = context.watch<AppsModel>();

    if (appsModel.snapApps.isNotEmpty) {
      return ListView(
        shrinkWrap: true,
        children: appsModel.snapApps.map((snapApp) {
          File? file;
          if (snapApp.desktopFile != null) {
            file = File(snapApp.desktopFile!);
          }
          return InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  if (snapApp.snap != null) {
                    if (appsModel.appIsOnline) {
                      return ChangeNotifierProvider(
                          create: (context) => SnapModel(
                              client: getService<SnapdClient>(),
                              huskSnapName: snapApp.snap!),
                          child: const AppDialog());
                    }

                    return ChangeNotifierProvider(
                      create: (context) => SnapModel(
                          client: getService<SnapdClient>(),
                          huskSnapName: snapApp.snap!),
                      child: OfflineDialog(
                        snapApp: snapApp,
                      ),
                    );
                  } else {
                    return const AlertDialog(
                      content: Center(
                        child: YaruCircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ).then((value) => appsModel.loadSnapApps);
            },
            child: ListTile(
              minVerticalPadding: 20,
              leading: SizedBox(
                width: 50,
                child: file != null
                    ? FutureBuilder<Widget>(
                        future: getIcon(file),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return snapshot.data!;
                          }
                          return fallBackIcon;
                        },
                      )
                    : fallBackIcon,
              ),
              title: Text(snapApp.name),
            ),
          );
        }).toList(),
      );
    }
    return const Center(
      child: YaruCircularProgressIndicator(),
    );
  }

  Future<Widget> getIcon(File file) async {
    final iconLine = (await file
            .openRead()
            .map(utf8.decode)
            .transform(const LineSplitter())
            .where((line) => line.contains('Icon='))
            .first)
        .replaceAll('Icon=', '');
    if (iconLine.endsWith('.png') || iconLine.endsWith('.jpg')) {
      return Image.file(
        File(iconLine),
        filterQuality: FilterQuality.medium,
        width: 50,
      );
    }
    if (iconLine.endsWith('.svg')) {
      try {
        return SvgPicture.file(
          File(iconLine),
          width: 50,
        );
      } finally {
        // ignore: control_flow_in_finally
        return fallBackIcon;
      }
    }
    if (!iconLine.contains('/')) {
      return XdgIconTheme(
        data: const XdgIconThemeData(theme: 'Yaru'),
        child: XdgIcon(name: iconLine, size: 48),
      );
    }
    return fallBackIcon;
  }
}

const fallBackIcon = XdgIconTheme(
    data: XdgIconThemeData(theme: 'Yaru'),
    child: XdgIcon(name: 'application-x-executable', size: 50));

class OfflineDialog extends StatelessWidget {
  const OfflineDialog({Key? key, required this.snapApp}) : super(key: key);

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
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
          child: TextButton(
            onPressed:
                model.appChangeInProgress ? null : () => model.removeSnap(),
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
                    ),
                  )
              ],
            ),
          ),
        ),
        // if (model.snapIsInstalled)
        Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
            ),
            child: ElevatedButton(
                onPressed: () => model.open(), child: const Text('Open')))
      ],
    );
  }
}
