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

    return AlertDialog(
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.only(left: 20),
      contentPadding: const EdgeInsets.only(
        bottom: 10,
        left: 25,
        right: 25,
      ),
      titlePadding: EdgeInsets.zero,
      title: const _Title(),
      content: const _Content(),
      actions: [
        if (model.selectableChannels.isNotEmpty)
          DropdownButton<String>(
            icon: const Icon(YaruIcons.pan_down),
            borderRadius: BorderRadius.circular(10),
            elevation: 1,
            value: model.channelToBeInstalled,
            items: [
              for (final entry in model.selectableChannels.entries)
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
        Text(model.versionString ?? ''),
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
              if (model.snapIsInstalled) const _RemoveButton(),
              const SizedBox(
                width: 10,
              ),
              if (model.snapIsInstalled) const _RefreshButton(),
              if (!model.snapIsInstalled) const _InstallButton(),
            ],
          )
      ],
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();

    return OutlinedButton(
      onPressed: () => model.removeSnap(),
      child: Text('Remove',
          style: model.appChangeInProgress
              ? TextStyle(color: Theme.of(context).disabledColor)
              : null),
    );
  }
}

class _InstallButton extends StatelessWidget {
  const _InstallButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();
    return ElevatedButton(
      onPressed: model.appChangeInProgress ? null : () => model.installSnap(),
      child: const Text('Install'),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();

    return OutlinedButton(
      onPressed: () => model.refreshSnapApp(),
      child: const Text('Refresh'),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();
    Widget image = const Icon(
      YaruIcons.package_snap,
      size: 65,
    );
    for (final medium in model.media ?? []) {
      if (medium.type == 'icon') {
        image = Image.network(
          medium.url,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  model.title ?? '',
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        if (model.snapIsInstalled)
                          SizedBox(
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.05),
                              child: IconButton(
                                tooltip: 'open',
                                splashRadius: 20,
                                onPressed: () => model.open(),
                                icon: Icon(
                                  YaruIcons.external_link,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      model.summary ?? '',
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
                        model.confinement == SnapConfinement.strict
                            ? YaruIcons.shield
                            : YaruIcons.warning,
                        size: 18,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(model.confinement?.name ?? '',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
              if (model.license != null)
                const SizedBox(height: 50, width: 30, child: VerticalDivider()),
              if (model.license != null)
                Column(
                  children: [
                    const Text('License', style: headerStyle),
                    Text(
                      model.license!.split(' ').first,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  ],
                ),
              const SizedBox(height: 50, width: 30, child: VerticalDivider()),
              Column(
                children: [
                  const Text('Last updated', style: headerStyle),
                  Text(
                    model.installDate.isNotEmpty
                        ? model.installDate
                        : 'Not installed',
                    style: headerStyle.copyWith(fontWeight: FontWeight.normal),
                  ),
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
  const _Content({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();
    final media = model.media != null
        ? model.media!
            .where((snapMedia) => snapMedia.type == 'screenshot')
            .toList()
        : [];
    return SizedBox(
      width: 450,
      child: SingleChildScrollView(
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
                  nextIcon: const Icon(YaruIcons.go_next),
                  previousIcon: const Icon(YaruIcons.go_previous),
                  navigationControls: media.length > 1,
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
            if (model.contact != null && model.publisher != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (model.website != null)
                      Link(url: model.website!, linkText: 'Website'),
                    Link(
                      url: model.contact!,
                      linkText: 'Contact ${model.publisher!.displayName}',
                    ),
                  ],
                ),
              ),
            if (model.description != null)
              YaruExpandable(
                header: const Text(
                  'Description',
                  style: headerStyle,
                ),
                expandIcon: const Icon(YaruIcons.pan_end),
                collapsedChild: Text(
                  model.description!,
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                ),
                child: Text(model.description!),
              ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
