import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/common/link.dart';
import 'package:software/pages/common/snap_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AppDialog extends StatefulWidget {
  const AppDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<AppDialog> createState() => _AppDialogState();
}

class _AppDialogState extends State<AppDialog> {
  @override
  void initState() {
    context.read<SnapModel>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();

    return model.snap != null
        ? AlertDialog(
            contentPadding: EdgeInsets.only(bottom: 20),
            titlePadding: EdgeInsets.zero,
            title: _Title(
              snap: model.snap!,
            ),
            content: _Content(
              snap: model.snap!,
            ),
            actions: [
              // DropdownButton<String>(
              //           borderRadius: BorderRadius.circular(10),
              //           elevation: 1,
              //           value: model.channel,
              //           items: [
              //             for (final channel in model.channels.entries)
              //               DropdownMenuItem<String>(
              //                 child: Text('${channel.key} ${channel.value.version}'),
              //                 value: !channel.key.contains('latest/') &&
              //                         !channel.key.contains('insiders/')
              //                     ? 'latest/${channel.key}'
              //                     : channel.key,
              //               ),
              //           ],
              //           onChanged: (v) {
              //             // model.currentSnapChannel = v!;
              //           },
              //         ),
              if (model.snapIsInstalled) _RemoveButton(snap: model.snap!),
              if (model.snapIsInstalled) _RefreshButton(snap: model.snap!),
              if (!model.snapIsInstalled) _InstallButton(snap: model.snap!),
              if (model.appChangeInProgress)
                SizedBox(
                  height: 25,
                  child: YaruCircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                )
            ],
          )
        : AlertDialog(
            content: Center(
              child: YaruCircularProgressIndicator(),
            ),
          );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({Key? key, required this.snap}) : super(key: key);

  final Snap snap;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();

    return OutlinedButton(
      onPressed: model.appChangeInProgress
          ? null
          : () => model.unInstallSnap(SnapApp(snap.name, snap.name)),
      child: Text(
        'Remove',
        style: TextStyle(
            color: model.appChangeInProgress
                ? Theme.of(context).disabledColor
                : Theme.of(context).errorColor),
      ),
    );
  }
}

class _InstallButton extends StatelessWidget {
  const _InstallButton({Key? key, required this.snap}) : super(key: key);

  final Snap snap;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();

    return ElevatedButton(
      onPressed: model.appChangeInProgress
          ? null
          : () => model.installSnap(snap, model.channel),
      child: Text('Install'),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({Key? key, required this.snap}) : super(key: key);

  final Snap snap;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();

    return OutlinedButton(
      onPressed: model.appChangeInProgress
          ? null
          : () => model.refreshSnapApp(snap, model.channel),
      child: Text('Refresh'),
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
                  Text('Version:'),
                  Text(snap.tracks.isNotEmpty
                      ? snap.channels[snap.tracks.first]?.version ?? ''
                      : ''),
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
