import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/explore/app_banner.dart';
import 'package:software/pages/explore/app_dialog.dart';
import 'package:software/pages/explore/app_grid.dart';
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
    return Stack(
      children: [
        YaruPage(children: [
          FutureBuilder<List<Snap>>(
            future: model.findSnapsBySection(section: 'development'),
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
                          (snap) => AppBanner(
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
                        .toList())
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: YaruCircularProgressIndicator(),
                  ),
          ),
          AppGrid(
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
        ]),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () => showDialog(
                context: context,
                builder: (context) => ChangeNotifierProvider.value(
                      value: model,
                      child: SearchAppsDialog(),
                    )),
            child: Icon(YaruIcons.search),
          ),
        ),
      ],
    );
  }
}

class SearchAppsDialog extends StatefulWidget {
  const SearchAppsDialog({Key? key}) : super(key: key);

  @override
  State<SearchAppsDialog> createState() => _SearchAppsDialogState();
}

class _SearchAppsDialogState extends State<SearchAppsDialog> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    return SimpleDialog(
      children: [
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: TextField(
            onEditingComplete: () => model.snapSearch = controller.value.text,
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
            ),
          ),
        ),
        FutureBuilder<List<Snap>>(
          future: model.findSnapsByName(),
          builder: (context, snapshot) => snapshot.hasData
              ? Column(
                  children: snapshot.data!
                      .map((e) => ListTile(
                            onTap: () => showDialog(
                                context: context,
                                builder: (context) =>
                                    ChangeNotifierProvider.value(
                                      value: model,
                                      child: AppDialog(snap: e),
                                    )),
                            title: Text(e.name),
                          ))
                      .toList())
              : YaruCircularProgressIndicator(),
        )
      ],
    );
  }
}
