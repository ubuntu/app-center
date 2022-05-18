import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/common_widgets/link.dart';
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
      title: _Title(
        snap: snap,
      ),
      content: _Content(
        snap: snap,
      ),
      actions: [
        FutureBuilder<Snap>(
          future: model.findSnapByName(snap.name),
          builder: (context, snapshot) =>
              snapshot.hasData && snapshot.data!.channels.isNotEmpty
                  ? DropdownButton<String>(
                      borderRadius: BorderRadius.circular(10),
                      elevation: 1,
                      value: snapshot.data!.channels.entries.first.key,
                      items: [
                        for (final channel in snapshot.data!.channels.entries)
                          DropdownMenuItem<String>(
                            child: Text(channel.key),
                            value: channel.key,
                          ),
                      ],
                      onChanged: (v) {})
                  : SizedBox(),
        ),
        ElevatedButton(
          onPressed:
              model.appChangeInProgress ? null : () => model.installSnap(snap),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Install'),
              if (model.appChangeInProgress)
                SizedBox(
                  height: 15,
                  child: YaruCircularProgressIndicator(
                    strokeWidth: 2,
                    color: model.appChangeInProgress
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

class _Title extends StatelessWidget {
  const _Title({Key? key, required this.snap}) : super(key: key);

  final Snap snap;

  @override
  Widget build(BuildContext context) {
    Widget image = Icon(
      YaruIcons.package_snap,
      size: 65,
    );
    for (var i = 0; i < snap.media.length; i++) {
      if (snap.media[i].type == 'icon') {
        image = Image.network(
          snap.media[i].url,
          height: 50,
        );
        break;
      }
    }

    return YaruDialogTitle(
      mainAxisAlignment: MainAxisAlignment.center,
      titleWidget: Row(
        children: [
          image,
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
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({Key? key, required this.snap}) : super(key: key);

  final Snap snap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (snap.media.isNotEmpty)
            YaruCarousel(
              height: 300,
              children: [
                for (int i = 1; i < snap.media.length; i++)
                  if (snap.media[i].type == 'screenshot')
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) => SimpleDialog(
                                children: [
                                  Image.network(
                                    snap.media[i].url,
                                    fit: BoxFit.contain,
                                  )
                                ],
                              )),
                      child: Image.network(
                        snap.media[i].url,
                        fit: BoxFit.fitHeight,
                      ),
                    )
              ],
            ),
          SizedBox(
            width: 350,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('License: ${snap.license!}'),
                    SizedBox(height: 20, child: VerticalDivider()),
                    if (snap.storeUrl != null)
                      Link(
                        url: snap.contact!,
                        linkText: 'Contact  ' + snap.publisher!.displayName,
                      ),
                  ],
                ),
              ),
            ),
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
    );
  }
}
