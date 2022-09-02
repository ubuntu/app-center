import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/package_state.dart';
import 'package:software/services/package_service.dart';
import 'package:software/store_app/common/link.dart';
import 'package:software/store_app/common/package_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PackageDialog extends StatefulWidget {
  const PackageDialog({
    Key? key,
    this.noUpdate = true,
    required this.id,
    required this.installedId,
  }) : super(key: key);

  final bool noUpdate;
  final PackageKitPackageId id;
  final PackageKitPackageId installedId;

  static Widget create({
    required BuildContext context,
    required PackageKitPackageId id,
    required PackageKitPackageId installedId,
    bool noUpdate = true,
  }) {
    return ChangeNotifierProvider(
      create: (context) => PackageModel(getService<PackageService>()),
      child: PackageDialog(
        noUpdate: noUpdate,
        id: id,
        installedId: installedId,
      ),
    );
  }

  @override
  State<PackageDialog> createState() => _PackageDialogState();
}

class _PackageDialogState extends State<PackageDialog> {
  @override
  void initState() {
    context
        .read<PackageModel>()
        .init(update: !widget.noUpdate, packageId: widget.id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PackageModel>();
    final caption = Theme.of(context).textTheme.caption;
    return AlertDialog(
      title: YaruDialogTitle(
        title: widget.id.name,
        closeIconData: YaruIcons.window_close,
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      scrollable: true,
      content: model.packageState != PackageState.ready
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(model.info != null ? model.info!.name : ''),
                  YaruLinearProgressIndicator(
                    value:
                        model.percentage != null ? model.percentage! / 100 : 0,
                  ),
                ],
              ),
            )
          : SizedBox(
              width: 400,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  YaruSingleInfoRow(
                    infoLabel: context.l10n.version,
                    infoValue: widget.id.version,
                  ),
                  YaruSingleInfoRow(
                    infoLabel: context.l10n.architecture,
                    infoValue: widget.id.arch,
                  ),
                  YaruSingleInfoRow(
                    infoLabel: context.l10n.source,
                    infoValue: widget.id.data,
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
                    actionWidget: Expanded(
                      child: Link(
                        url: model.url,
                        linkText: model.url,
                        textStyle: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: Theme.of(context).primaryColor,
                        ),
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
                    if (model.changelog.isEmpty)
                      const YaruCircularProgressIndicator()
                    else
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
              if (model.isInstalled)
                OutlinedButton(
                  onPressed: model.packageState != PackageState.ready
                      ? null
                      : () => model.remove(packageId: widget.id),
                  child: Text(context.l10n.remove),
                ),
              if (!model.isInstalled)
                ElevatedButton(
                  onPressed: model.packageState != PackageState.ready
                      ? null
                      : () => model.install(packageId: widget.id),
                  child: Text(context.l10n.install),
                ),
            ],
    );
  }
}
