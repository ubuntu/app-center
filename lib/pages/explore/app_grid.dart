import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/common/apps_model.dart';
import 'package:software/pages/common/snap_model.dart';
import 'package:software/pages/explore/app_card.dart';
import 'package:software/pages/explore/app_dialog.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AppGrid extends StatelessWidget {
  const AppGrid({
    Key? key,
    required this.name,
    this.headline,
    this.topPadding = 50,
    required this.findByName,
  }) : super(key: key);

  final String name;
  final String? headline;
  final double topPadding;
  final bool findByName;

  @override
  Widget build(BuildContext context) {
    final model = context.read<AppsModel>();
    return FutureBuilder<List<Snap>>(
      future: findByName
          ? model.findSnapsByQuery()
          : model.findSnapsBySection(section: name),
      builder: (context, snapshot) => snapshot.hasData
          ? Padding(
              padding: EdgeInsets.only(top: topPadding, left: 20, right: 20),
              child: Column(
                children: [
                  if (headline != null)
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            headline!,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  GridView(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      crossAxisSpacing: 40,
                      mainAxisSpacing: 40,
                      maxCrossAxisExtent: 100,
                    ),
                    children: snapshot.data!
                        .take(20)
                        .map(
                          (snap) => AppCard(
                            snap: snap,
                            onTap: () {
                              final client = context.read<SnapdClient>();
                              showDialog(
                                barrierColor: Colors.black.withOpacity(0.9),
                                context: context,
                                builder: (context) =>
                                    ChangeNotifierProvider<SnapModel>(
                                  create: (context) => SnapModel(
                                      client: client, huskSnapName: snap.name),
                                  child: AppDialog(),
                                ),
                              );
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: YaruCircularProgressIndicator(),
              ),
            ),
    );
  }
}
