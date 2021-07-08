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
                  .map((e) => InkWell(
                        onTap: () => {
                          showDialog(
                              context: context,
                              builder: (_) =>
                                  StatefulBuilder(builder: (context, setState) {
                                    return AlertDialog(
                                      title: Text(e.name),
                                      content: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                4,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            OutlinedButton(
                                                onPressed: () async {
                                                  await client
                                                      .loadAuthorization();
                                                  await client
                                                      .remove([e.name]).then(
                                                          (value) => setState);
                                                },
                                                child: Text('Uninstall'))
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
                            title: Text(e.name)),
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
