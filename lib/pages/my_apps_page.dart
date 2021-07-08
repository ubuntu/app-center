import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';

class MyAppsPage extends StatelessWidget {
  const MyAppsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final client = context.watch<SnapdClient>();

    Provider.of<SnapdClient>(context, listen: false);

    return FutureBuilder(
        future: getSnapApps(context),
        builder: (BuildContext context, AsyncSnapshot<List<SnapApp>> snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!
                  .map((snapApp) => InkWell(
                        onTap: () => {
                          showDialog(
                              context: context,
                              builder: (_) =>
                                  StatefulBuilder(builder: (context, setState) {
                                    double changeValue = 0;

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
                                                  String appId = await client
                                                      .loadAuthorization()
                                                      .then((value) => client
                                                          .remove(
                                                              [snapApp.name]));
                                                  client
                                                      .getChange(appId)
                                                      .asStream()
                                                      .cast()
                                                      .listen((event) {
                                                    setState(() {
                                                      changeValue = event;
                                                    });
                                                  });
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
                                                  value: changeValue,
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
                                                Navigator.of(context).pop();
                                              });
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
    await client.loadAuthorization();
    return await client.apps();
  }
}
