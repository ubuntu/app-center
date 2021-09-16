import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';

class MyAppsPage extends StatefulWidget {
  MyAppsPage({Key? key}) : super(key: key);

  @override
  State<MyAppsPage> createState() => _MyAppsPageState();
}

class _MyAppsPageState extends State<MyAppsPage> {
  double _progress = 0;
  String appId = '';
  late SnapdClient client;

  late Future<List<SnapApp>> _apps;

  void startTimer() {
    Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) => setState(
        () {
          if (_progress == 1) {
            timer.cancel();
          } else {
            // client.getChange(appId);
            _progress += 0.2;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    client = context.watch<SnapdClient>();
    Provider.of<SnapdClient>(context, listen: false);
    _apps = getSnapApps(context);

    return FutureBuilder(
        future: _apps,
        builder: (BuildContext context, AsyncSnapshot<List<SnapApp>> snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!
                  .map((snapApp) => InkWell(
                        onTap: () => {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  StatefulBuilder(builder: (context, setState) {
                                    return AlertDialog(
                                      title: Text(snapApp.name),
                                      content: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                6,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextButton(
                                                onPressed: () async {
                                                  await client
                                                      .loadAuthorization()
                                                      .then((value) => client
                                                          .remove(
                                                              [snapApp.name]));
                                                },
                                                child: Text('Uninstall',
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .error))),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, bottom: 10),
                                              child: SizedBox(
                                                width: 90,
                                                child: LinearProgressIndicator(
                                                  value: _progress,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        OutlinedButton(
                                            onPressed: () {
                                              setState(() {
                                                _apps = getSnapApps(context);
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: Text('Close')),
                                      ],
                                    );
                                  }))
                        },
                        child: ListTile(
                            leading: Icon(Icons.settings_applications),
                            title: Text(snapApp.name)),
                      ))
                  .toList(),
            );
          }
          return CircularProgressIndicator();
        });
  }

  Future<List<SnapApp>> getSnapApps(BuildContext context) async {
    final client = context.watch<SnapdClient>();
    Provider.of<SnapdClient>(context, listen: false);

    await client.loadAuthorization();
    return await client.apps();
  }
}
