import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/common/apps_model.dart';
import 'package:software/pages/common/link.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({Key? key, required this.snap}) : super(key: key);

  final Snap snap;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppsModel>();

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
          builder: (context, snapshot) => snapshot.hasData &&
                  snapshot.data!.channels.isNotEmpty &&
                  snapshot.data!.channels.entries.isNotEmpty &&
                  model.currentSnapChannel.isNotEmpty
              ? DropdownButton<String>(
                  borderRadius: BorderRadius.circular(10),
                  elevation: 1,
                  value: model.currentSnapChannel,
                  items: [
                    for (final channel in snapshot.data!.channels.entries)
                      DropdownMenuItem<String>(
                        child: Text(channel.key),
                        value: !channel.key.contains('latest/') &&
                                !channel.key.contains('insiders/')
                            ? 'latest/${channel.key}'
                            : channel.key,
                      ),
                  ],
                  onChanged: (v) {
                    model.currentSnapChannel = v!;
                  },
                )
              : SizedBox(),
        ),
        FutureBuilder<bool>(
          future: model.snapIsIstalled(snap),
          builder: (context, snapshot) => snapshot.hasData && snapshot.data!
              ? ChangeNotifierProvider.value(
                  value: model,
                  child: _RemoveButton(snap: snap),
                )
              : SizedBox(),
        ),
        FutureBuilder<bool>(
          future: model.snapIsIstalled(snap),
          builder: (context, snapshot) => snapshot.hasData && snapshot.data!
              ? ChangeNotifierProvider.value(
                  value: model,
                  child: _RefreshButton(snap: snap),
                )
              : SizedBox(),
        ),
        FutureBuilder<bool>(
          future: model.snapIsIstalled(snap),
          builder: (context, snapshot) => snapshot.hasData && !snapshot.data!
              ? ChangeNotifierProvider.value(
                  value: model,
                  child: _InstallButton(snap: snap),
                )
              : SizedBox(),
        ),
      ],
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({Key? key, required this.snap}) : super(key: key);

  final Snap snap;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppsModel>();

    return OutlinedButton(
      onPressed: model.appChangeInProgress
          ? null
          : () => model.unInstallSnap(SnapApp(snap.name, snap.name)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Remove',
            style: TextStyle(color: Theme.of(context).errorColor),
          ),
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
    );
  }
}

class _InstallButton extends StatelessWidget {
  const _InstallButton({Key? key, required this.snap}) : super(key: key);

  final Snap snap;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppsModel>();

    return ElevatedButton(
      onPressed: model.appChangeInProgress
          ? null
          : () => model.installSnap(snap, model.currentSnapChannel),
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
    );
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({Key? key, required this.snap}) : super(key: key);

  final Snap snap;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppsModel>();

    return OutlinedButton(
      onPressed: model.appChangeInProgress
          ? null
          : () => model.refreshSnapApp(snap, model.currentSnapChannel),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Refresh'),
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
          filterQuality: FilterQuality.medium,
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
    final width = 350.0;
    final media = snap.media
        .where((snapMedia) => snapMedia.type == 'screenshot')
        .toList();
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (media.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: YaruCarousel(
                height: 300,
                children: [
                  for (final image in media)
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) => SimpleDialog(
                                children: [
                                  InkWell(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Image.network(
                                      image.url,
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.medium,
                                    ),
                                  )
                                ],
                              )),
                      child: Image.network(
                        image.url,
                        fit: BoxFit.fitHeight,
                        filterQuality: FilterQuality.medium,
                      ),
                    )
                ],
              ),
            ),
          if (snap.license != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(
                width: width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('License:'),
                    Text(
                      snap.license!.split(' ').first,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Confinement:'),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        snap.confinement == SnapConfinement.strict
                            ? YaruIcons.shield
                            : YaruIcons.warning,
                        size: 18,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(snap.confinement.name),
                    ],
                  )
                ],
              ),
            ),
          ),
          if (snap.contact != null && snap.publisher != null)
            SizedBox(
              width: width,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Contact:'),
                      Link(
                        url: snap.contact!,
                        linkText: snap.publisher!.displayName,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (snap.website != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(
                width: width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Website:'),
                    Link(url: snap.website!, linkText: 'Link'),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: SizedBox(
              width: width,
              child: Text(
                snap.description,
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.left,
              ),
            ),
          )
        ],
      ),
    );
  }
}
