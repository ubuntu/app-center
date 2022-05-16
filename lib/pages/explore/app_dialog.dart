import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/explore/explore_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({Key? key, required this.snap}) : super(key: key);

  final Snap snap;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    return AlertDialog(
      contentPadding: EdgeInsets.only(bottom: 20),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  snap.title,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: 300,
                  child: Text(
                    snap.summary,
                    style: Theme.of(context).textTheme.caption,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 10,
                  ),
                )
              ],
            ),
          ],
        ),
        closeIconData: YaruIcons.window_close,
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            YaruCarousel(height: 300, children: [
              for (int i = 1; i < snap.media.length; i++)
                if (snap.media[i].url.endsWith('png') ||
                    snap.media[i].url.endsWith('jpg') ||
                    snap.media[i].url.endsWith('jpeg'))
                  Image.network(snap.media[i].url)
            ]),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 350,
              child: Text(
                snap.description,
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.left,
              ),
            )
          ],
        ),
      ),
      actions: [
        SizedBox(
          height: 35,
          child: DropdownButton<String>(
              borderRadius: BorderRadius.circular(10),
              elevation: 1,
              value: 'snap: stable',
              items: [
                DropdownMenuItem(
                  child: Text('snap: stable'),
                  value: 'snap: stable',
                ),
                DropdownMenuItem(
                  child: Text('snap: edge'),
                  value: 'snap: edge',
                ),
                DropdownMenuItem(
                  child: Text('deb'),
                  value: 'deb',
                ),
              ],
              onChanged: (v) {}),
        ),
        ElevatedButton(
          onPressed: model.installing ? null : () => model.installSnap(snap),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Install'),
              if (model.installing)
                SizedBox(
                  height: 15,
                  child: YaruCircularProgressIndicator(
                    strokeWidth: 2,
                    color: model.installing
                        ? Theme.of(context).disabledColor
                        : Colors.white,
                  ),
                )
            ],
          ),
        )
      ],
    );
  }
}
