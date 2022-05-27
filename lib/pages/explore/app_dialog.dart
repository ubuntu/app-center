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
            actionsAlignment: MainAxisAlignment.end,
            contentPadding: EdgeInsets.only(
              bottom: 10,
            ),
            titlePadding: EdgeInsets.zero,
            title: _Title(
              snap: model.snap!,
            ),
            content: _Content(
              snap: model.snap!,
            ),
            actions: [
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
          : () => model.refreshSnapApp(snap, model.channelToBeInstalled),
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
      mainAxisAlignment: MainAxisAlignment.start,
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
              ),
              if (snap.license != null)
                Text(
                  snap.license!.split(' ').first,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.caption,
                ),
            ],
          ),
        ],
      ),
      closeIconData: YaruIcons.window_close,
    );
  }
}

class _Content extends StatefulWidget {
  const _Content({Key? key, required this.snap}) : super(key: key);

  final Snap snap;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  bool infoExpanded = false;
  @override
  Widget build(BuildContext context) {
    final width = 350.0;
    final media = widget.snap.media
        .where((snapMedia) => snapMedia.type == 'screenshot')
        .toList();
    final model = context.watch<SnapModel>();
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(),
          SizedBox(
            height: 10,
          ),
          if (media.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: YaruCarousel(
                height: 250,
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
          if (media.isNotEmpty) Divider(),
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
                        widget.snap.confinement == SnapConfinement.strict
                            ? YaruIcons.shield
                            : YaruIcons.warning,
                        size: 18,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(widget.snap.confinement.name),
                    ],
                  )
                ],
              ),
            ),
          ),
          if (widget.snap.contact != null && widget.snap.publisher != null)
            SizedBox(
              width: width,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.snap.website != null)
                        Link(url: widget.snap.website!, linkText: 'Website'),
                      Link(
                        url: widget.snap.contact!,
                        linkText:
                            'Contact ' + widget.snap.publisher!.displayName,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SizedBox(
            width: width,
            child: InkWell(
              onTap: () => setState(() {
                infoExpanded = !infoExpanded;
              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Description'),
                    Icon(infoExpanded ? YaruIcons.pan_up : YaruIcons.pan_down)
                  ],
                ),
              ),
            ),
          ),
          if (infoExpanded)
            SizedBox(
              width: width,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  widget.snap.description,
                  style: Theme.of(context).textTheme.caption,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          if (model.channels.isNotEmpty &&
              model.channelToBeInstalled.isNotEmpty)
            SizedBox(
              width: width,
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      icon: Icon(YaruIcons.pan_down),
                      borderRadius: BorderRadius.circular(10),
                      elevation: 1,
                      value: model.channelToBeInstalled,
                      isExpanded: true,
                      items: [
                        for (final entry in model.channels.entries)
                          DropdownMenuItem<String>(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${entry.key}: ',
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    '${entry.value.version}',
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  )
                                ],
                              ),
                              value: entry.key),
                      ],
                      onChanged: model.appChangeInProgress
                          ? null
                          : (v) => model.channelToBeInstalled = v!,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 10,
          ),
          Divider(),
        ],
      ),
    );
  }
}
