import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MyAppsPage extends StatefulWidget {
  MyAppsPage({Key? key}) : super(key: key);

  @override
  State<MyAppsPage> createState() => _MyAppsPageState();
}

class _MyAppsPageState extends State<MyAppsPage> {
  bool uninstalling = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SnapApp>>(
        future: getSnapApps(context),
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
                                                  unInstallSnap(setState,
                                                      snapApp, context),
                                              child: Text(
                                                'Uninstall',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .errorColor),
                                              ),
                                            ),
                                            if (uninstalling)
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

  Future<void> unInstallSnap(
      StateSetter setState, SnapApp snapApp, BuildContext context) async {
    {
      final client = context.read<SnapdClient>();
      setState(() {
        uninstalling = true;
      });
      await client.loadAuthorization();
      final id = await client.remove([snapApp.name]);
      while (true) {
        final change = await client.getChange(id);
        if (change.ready) {
          setState(() {
            uninstalling = false;
          });
          break;
        }

        await Future.delayed(
          Duration(milliseconds: 100),
        );
      }
    }
  }

  Future<List<SnapApp>> getSnapApps(BuildContext context) async {
    final client = context.read<SnapdClient>();
    await client.loadAuthorization();
    return await client.apps();
  }
}
