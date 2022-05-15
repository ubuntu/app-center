import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return YaruPage(children: [
      FutureBuilder<List<Snap>>(
        future: findSnapApps(),
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
          future: findSnapApps(),
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

  Future<List<Snap>> findSnapApps() async {
    final client = context.read<SnapdClient>();
    final snaps = await client.find();
    return snaps;
  }
}
