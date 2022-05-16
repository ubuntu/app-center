import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/explore/explore_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) {
    final client = context.read<SnapdClient>();
    return ChangeNotifierProvider(
      create: (_) => ExploreModel(client),
      child: const ExplorePage(),
    );
  }

  static Widget createTitle(BuildContext context) => Text('Explore');

  @override
  Widget build(BuildContext context) {
    final model = context.read<ExploreModel>();
    return YaruPage(children: [
      FutureBuilder<List<Snap>>(
        future: model.findSnapApps(),
        builder: (context, snapshot) => snapshot.hasData
            ? YaruCarousel(
                placeIndicator: false,
                autoScrollDuration: Duration(seconds: 3),
                width: 600,
                height: 140,
                autoScroll: true,
                children: snapshot.data!
                    .where((element) => element.media.isNotEmpty)
                    .take(10)
                    .map(
                      (e) => Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: ListTile(
                            contentPadding:
                                EdgeInsets.only(left: 18, right: 18),
                            subtitle: Text(e.summary),
                            title: Text(e.title),
                            leading: Image.network(e.media.first.url,
                                fit: BoxFit.cover),
                          ),
                        ),
                        margin: EdgeInsets.all(10),
                      ),
                    )
                    .toList())
            : YaruCircularProgressIndicator(),
      ),
      SnapGrid(
        sectionName: 'featured',
        headline: 'Editor\'s choice',
        showHeadline: true,
      ),
      // SizedBox(
      //   height: 40,
      // ),
      // SizedBox(
      //   height: 500,
      //   child: YaruTabbedPage(tabIcons: [
      //     YaruIcons.headset,
      //     YaruIcons.camera_video_filed
      //   ], tabTitles: [
      //     'Health',
      //     'Video'
      //   ], views: [
      //     SnapGrid(
      //       sectionName: 'health-and-fitness',
      //     ),
      //     Text('data')
      //   ]),
      // )
    ]);
  }
}

class SnapGrid extends StatelessWidget {
  const SnapGrid(
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
      future: model.findSnapApps(section: sectionName),
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
                          (e) => InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => showAboutDialog(context: context),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Theme.of(context).cardColor
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: Theme.of(context).dividerColor),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Image.network(
                                  e.media.first.url,
                                ),
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
