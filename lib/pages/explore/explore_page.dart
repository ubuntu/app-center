import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/explore/explore_model.dart';
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
    final model = context.watch<ExploreModel>();
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
                    .map((e) => Card(
                          surfaceTintColor:
                              Image.network(e.media.first.url).color,
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
                        ))
                    .toList())
            : YaruCircularProgressIndicator(),
      ),
      SizedBox(
        height: 40,
      ),
      FutureBuilder<List<Snap>>(
          future: model.findSnapApps(),
          builder: (context, snapshot) => snapshot.hasData
              ? GridView(
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
                        (e) => Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.network(
                              e.media.first.url,
                            ),
                          ),
                        ),
                      )
                      .toList())
              : YaruCircularProgressIndicator()),
    ]);
  }
}
