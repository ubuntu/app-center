import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/link.dart';
import 'package:software/store_app/common/package_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PackageDialog extends StatefulWidget {
  const PackageDialog({Key? key, this.noUpdate = true}) : super(key: key);

  final bool noUpdate;

  static Widget create({
    required BuildContext context,
    required PackageKitPackageId id,
    required PackageKitPackageId installedId,
    bool noUpdate = true,
  }) {
    return ChangeNotifierProvider(
      create: (context) => PackageModel(
        getService<PackageKitClient>(),
        packageId: id,
        installedId: installedId,
      ),
      child: PackageDialog(
        noUpdate: noUpdate,
      ),
    );
  }

  @override
  State<PackageDialog> createState() => _PackageDialogState();
}

class _PackageDialogState extends State<PackageDialog> {
  @override
  void initState() {
    context.read<PackageModel>().init(update: !widget.noUpdate);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PackageModel>();
    final caption = Theme.of(context).textTheme.caption;
    return AlertDialog(
      title: YaruDialogTitle(
        title: model.name,
        closeIconData: YaruIcons.window_close,
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      scrollable: true,
      content: model.processing
          ? Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 145,
                  height: 185,
                  child: LiquidLinearProgressIndicator(
                    value: model.packageIsInstalled ? 1 : 0,
                    backgroundColor: Colors.white.withOpacity(0.5),
                    valueColor: AlwaysStoppedAnimation(
                      Theme.of(context).primaryColor,
                    ),
                    direction: Axis.vertical,
                    borderRadius: 20,
                  ),
                ),
                Icon(
                  YaruIcons.debian,
                  size: 120,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            )
          : SizedBox(
              width: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  YaruSingleInfoRow(
                    infoLabel: context.l10n.version,
                    infoValue: model.version,
                  ),
                  YaruSingleInfoRow(
                    infoLabel: context.l10n.architecture,
                    infoValue: model.arch,
                  ),
                  YaruSingleInfoRow(
                    infoLabel: context.l10n.source,
                    infoValue: model.data,
                  ),
                  YaruSingleInfoRow(
                    infoLabel: context.l10n.license,
                    infoValue: model.license,
                  ),
                  YaruSingleInfoRow(
                    infoLabel: context.l10n.size,
                    infoValue: model.size.toString(),
                  ),
                  YaruRow(
                    trailingWidget: Text(context.l10n.website),
                    actionWidget: Link(
                      url: model.url,
                      linkText: model.url,
                      textStyle: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    enabled: true,
                  ),
                  if (!widget.noUpdate)
                    YaruSingleInfoRow(
                      infoLabel: context.l10n.issued,
                      infoValue: model.issued,
                    ),
                  if (!widget.noUpdate)
                    YaruExpandable(
                      header: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(context.l10n.changelog),
                      ),
                      expandIcon: const Icon(YaruIcons.pan_end),
                      isExpanded: true,
                      child: SizedBox(
                        height: 250,
                        child: Markdown(
                          data: model.changelog,
                          shrinkWrap: true,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(p: caption),
                          padding: const EdgeInsets.only(left: 8, right: 8),
                        ),
                      ),
                    ),
                  YaruExpandable(
                    header: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(context.l10n.description),
                    ),
                    isExpanded: widget.noUpdate,
                    expandIcon: const Icon(YaruIcons.pan_end),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              model.description,
                              style: caption,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      actions: widget.noUpdate == false
          ? null
          : [
              if (model.packageIsInstalled)
                OutlinedButton(
                  onPressed: model.processing ? null : model.remove,
                  child: Text(context.l10n.remove),
                ),
              if (!model.packageIsInstalled)
                ElevatedButton(
                  onPressed: model.processing ? null : model.install,
                  child: Text(context.l10n.install),
                ),
            ],
    );
  }
}
