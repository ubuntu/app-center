import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/common/link.dart';
import 'package:software/pages/common/snap_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

const headerStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);

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
    super.initState();
    context.read<SnapModel>().init();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();

    return model.snap != null
        ? AlertDialog(
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actionsPadding: const EdgeInsets.only(left: 20),
            contentPadding: const EdgeInsets.only(
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
              if (model.channels.isNotEmpty &&
                  model.channelToBeInstalled.isNotEmpty)
                DropdownButton<String>(
                  icon: const Icon(YaruIcons.pan_down),
                  borderRadius: BorderRadius.circular(10),
                  elevation: 1,
                  value: model.channelToBeInstalled,
                  items: [
                    for (final entry in model.channels.entries)
                      DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(
                          entry.key,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                  ],
                  onChanged: model.appChangeInProgress
                      ? null
                      : (v) => model.channelToBeInstalled = v!,
                ),
              if (model.appChangeInProgress)
                const SizedBox(
                  height: 25,
                  child: YaruCircularProgressIndicator(
                    strokeWidth: 3,
                  ),
                ),
              if (!model.appChangeInProgress)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (model.snapIsInstalled) _RemoveButton(snap: model.snap!),
                    const SizedBox(
                      width: 10,
                    ),
                    if (model.snapIsInstalled)
                      _RefreshButton(snap: model.snap!),
                    if (!model.snapIsInstalled)
                      _InstallButton(snap: model.snap!),
                  ],
                )
            ],
          )
        : const AlertDialog(
            content: Padding(
              padding: EdgeInsets.all(20.0),
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
      child: const Text('Install'),
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
      child: const Text('Refresh'),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({Key? key, required this.snap}) : super(key: key);

  final Snap snap;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();
    Widget image = const Icon(
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
      titleWidget: Column(
        children: [
          Row(
            children: [
              image,
              const SizedBox(
                width: 15,
              ),
              SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snap.title,
                      overflow: TextOverflow.visible,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      snap.summary,
                      style: Theme.of(context).textTheme.caption,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Column(
                children: [
                  const Text(
                    'Confinment',
                    style: headerStyle,
                  ),
                  Row(
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
                      Text(snap.confinement.name,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
              if (snap.license != null)
                const SizedBox(height: 50, width: 30, child: VerticalDivider()),
              if (snap.license != null)
                Column(
                  children: [
                    const Text('License', style: headerStyle),
                    Text(
                      snap.license!.split(' ').first,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  ],
                ),
              const SizedBox(height: 50, width: 30, child: VerticalDivider()),
              Column(
                children: [
                  const Text('Version', style: headerStyle),
                  Text(
                    model.versionString,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: model.versionString != snap.version
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).colorScheme.onSurface),
                  )
                ],
              ),
            ],
          )
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
    const width = 350.0;
    final media = snap.media
        .where((snapMedia) => snapMedia.type == 'screenshot')
        .toList();
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          const SizedBox(
            height: 10,
          ),
          if (media.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: YaruCarousel(
                navigationControls: true,
                viewportFraction: 1,
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
          if (media.isNotEmpty) const Divider(),
          if (snap.contact != null && snap.publisher != null)
            SizedBox(
              width: width,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (snap.website != null)
                        Link(url: snap.website!, linkText: 'Website'),
                      Link(
                        url: snap.contact!,
                        linkText: 'Contact ${snap.publisher!.displayName}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SizedBox(
            width: width + 16,
            child: YaruExpandable(
              header: const Text(
                'Description',
                style: headerStyle,
              ),
              expandIcon: const Icon(YaruIcons.pan_end),
              collapsedChild: Text(
                snap.description,
                maxLines: 3,
                overflow: TextOverflow.fade,
              ),
              child: Text(snap.description),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(),
        ],
      ),
    );
  }
}
