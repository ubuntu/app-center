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
        future: model.findSnapApps(section: 'development'),
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
                          builder: (context) => ChangeNotifierProvider.value(
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
    ]);
  }
}

class AppBanner extends StatelessWidget {
  const AppBanner({
    Key? key,
    required this.snap,
    this.onTap,
  }) : super(key: key);

  final Snap snap;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Align(
          alignment: Alignment.center,
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 18, right: 18),
            subtitle: Text(snap.summary),
            title: Text(snap.title),
            leading: Image.network(snap.media.first.url, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

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
                          (snap) => AppCard(snap: snap),
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

class AppCard extends StatelessWidget {
  const AppCard({Key? key, this.onTap, required this.snap}) : super(key: key);

  final Function()? onTap;
  final Snap snap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).cardColor
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Image.network(
            snap.media.first.url,
          ),
        ),
      ),
    );
  }
}

class AppDialog extends StatelessWidget {
  const AppDialog({Key? key, required this.snap}) : super(key: key);

  final Snap snap;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    return SimpleDialog(
      contentPadding: EdgeInsets.only(left: 40, right: 40, bottom: 30),
      titlePadding: EdgeInsets.zero,
      title: YaruDialogTitle(
        mainAxisAlignment: MainAxisAlignment.center,
        titleWidget: Row(
          children: [
            if (snap.media.isNotEmpty)
              Image.network(
                snap.media.first.url,
                height: 50,
              ),
            SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(snap.title),
                SizedBox(
                  height: 5,
                ),
                Text(
                  snap.summary,
                  style: Theme.of(context).textTheme.caption,
                )
              ],
            ),
            SizedBox(
              width: 15,
            ),
            ElevatedButton(
                onPressed:
                    model.installing ? null : () => model.installSnap(snap),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Install'),
                    if (model.installing)
                      SizedBox(
                        height: 15,
                        child: YaruCircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                  ],
                ))
          ],
        ),
        closeIconData: YaruIcons.window_close,
      ),
      children: [
        YaruCarousel(height: 300, children: [
          for (int i = 1; i < snap.media.length; i++)
            Image.network(snap.media[i].url)
        ]),
        SizedBox(
          height: 20,
        ),
        Text(
          snap.description,
          style: Theme.of(context).textTheme.caption,
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
