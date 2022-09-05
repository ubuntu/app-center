/*
 * Copyright (C) 2022 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/package_state.dart';
import 'package:software/services/package_service.dart';
import 'package:software/store_app/common/package_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({
    Key? key,
    required this.id,
    required this.installedId,
  }) : super(key: key);

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
      child: UpdateDialog(
        id: id,
        installedId: installedId,
      ),
    );
  }

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  @override
  void initState() {
    context.read<PackageModel>().init(update: true, packageId: widget.id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PackageModel>();
    final caption = Theme.of(context).textTheme.bodySmall;
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
                    actionWidget: YaruRoundIconButton(
                      size: 20,
                      tooltip: model.url,
                      onTap: () => launchUrl(Uri.parse(model.url)),
                      child: Icon(
                        YaruIcons.external_link,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                    enabled: true,
                  ),
                  YaruSingleInfoRow(
                    infoLabel: context.l10n.issued,
                    infoValue: model.issued,
                  ),
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
                          onTapLink: (text, href, title) =>
                              href != null ? launchUrl(Uri.parse(href)) : null,
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          styleSheet: MarkdownStyleSheet(p: caption),
                        ),
                      ),
                    ),
                  YaruExpandable(
                    header: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(context.l10n.description),
                    ),
                    isExpanded: false,
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
    );
  }
}
