import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/explore/app_card.dart';
import 'package:software/pages/explore/app_dialog.dart';
import 'package:software/pages/explore/explore_model.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AppGrid extends StatelessWidget {
  const AppGrid(
      {Key? key,
      required this.sectionName,
      required this.showHeadline,
      required this.headline})
      : super(key: key);

  final String sectionName;
  final String headline;
  final bool showHeadline;

  @override
  Widget build(BuildContext context) {
    final model = context.read<ExploreModel>();
    return FutureBuilder<List<Snap>>(
      future: model.findSnapsBySection(section: sectionName),
      builder: (context, snapshot) => snapshot.hasData
          ? Padding(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
              child: Column(
                children: [
                  if (showHeadline)
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            headline,
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
                        .where((element) => element.media.isNotEmpty)
                        .take(20)
                        .map(
                          (snap) => AppCard(
                            snap: snap,
                            onTap: () => showDialog(
                              context: context,
                              builder: (context) =>
                                  ChangeNotifierProvider.value(
                                value: model,
                                child: AppDialog(snap: snap),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            )
          : YaruCircularProgressIndicator(),
    );
  }
}
