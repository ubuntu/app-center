import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/app_change_service.dart';
import 'package:software/store_app/common/link.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

const headerStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);

class SnapDialog extends StatefulWidget {
  const SnapDialog({
    Key? key,
  }) : super(key: key);

  static Widget create({
    required BuildContext context,
    required String huskSnapName,
  }) =>
      ChangeNotifierProvider<SnapModel>(
        create: (context) => SnapModel(
          getService<SnapdClient>(),
          getService<AppChangeService>(),
          huskSnapName: huskSnapName,
        ),
        child: const SnapDialog(),
      );

  @override
  State<SnapDialog> createState() => _SnapDialogState();
}

class _SnapDialogState extends State<SnapDialog> {
  @override
  void initState() {
    context.read<SnapModel>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();

    if (model.name != null) {
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
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: YaruExpandable(
                expandIcon: const Icon(YaruIcons.pan_end),
                header: DropdownButton<String>(
                  icon: const Icon(YaruIcons.pan_down),
                  borderRadius: BorderRadius.circular(10),
                  elevation: 1,
                  value: model.channelToBeInstalled,
                  items: [
                    for (final entry in model.selectableChannels.entries)
                      DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(
                          '${context.l10n.channel}: ${entry.key}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                  ],
                  onChanged: model.appChangeInProgress
                      ? null
                      : (v) => model.channelToBeInstalled = v!,
                ),
                child: Column(
                  children: [
                    YaruSingleInfoRow(
                        infoLabel: context.l10n.version,
                        infoValue: model.versionString ?? ''),
                    YaruSingleInfoRow(
                        infoLabel: context.l10n.lastUpdated,
                        infoValue: model.releasedAt),
                  ],
                ),
              ),
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
                if (model.snapIsInstalled)
                  OutlinedButton(
                    onPressed: () => model.removeSnap(),
                    child: Text(
                      context.l10n.remove,
                      style: model.appChangeInProgress
                          ? TextStyle(color: Theme.of(context).disabledColor)
                          : null,
                    ),
                  ),
                const SizedBox(
                  width: 10,
                ),
                if (model.snapIsInstalled)
                  OutlinedButton(
                    onPressed: () => model.refreshSnapApp(),
                    child: Text(context.l10n.refresh),
                  ),
                if (!model.snapIsInstalled)
                  ElevatedButton(
                    onPressed: model.appChangeInProgress
                        ? null
                        : () => model.installSnap(),
                    child: Text(context.l10n.install),
                  ),
              ],
            )
        ],
      );
    } else {
      return const AlertDialog(
        content: SizedBox(
          height: 200,
          child: Center(child: YaruCircularProgressIndicator()),
        ),
      );
    }
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
    if (model.iconUrl != null) {
      image = Image.network(
        model.iconUrl!,
        height: 50,
        filterQuality: FilterQuality.medium,
      );
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
                                tooltip: context.l10n.open,
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
                  Text(
                    context.l10n.confinement,
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
                      Text(
                        model.confinement?.name ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
              if (model.license != null)
                const SizedBox(height: 50, width: 30, child: VerticalDivider()),
              if (model.license != null)
                Column(
                  children: [
                    Text(context.l10n.license, style: headerStyle),
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
                  Text(context.l10n.installDate, style: headerStyle),
                  Text(
                    model.installDate.isNotEmpty
                        ? model.installDate
                        : context.l10n.notInstalled,
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
                          ),
                        ),
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
                      Link(url: model.website!, linkText: context.l10n.website),
                    Link(
                      url: model.contact!,
                      linkText:
                          '${context.l10n.contact} ${model.publisher!.displayName}',
                    ),
                  ],
                ),
              ),
            if (model.description != null)
              YaruExpandable(
                header: Text(
                  context.l10n.description,
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
