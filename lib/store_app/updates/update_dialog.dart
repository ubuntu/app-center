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
    const headerStyle = TextStyle(fontWeight: FontWeight.bold);
    if (model.packageState != PackageState.ready || model.changelog.isEmpty) {
      return const AlertDialog(
        content: Padding(
          padding: EdgeInsets.only(bottom: 40, top: 40),
          child: YaruCircularProgressIndicator(),
        ),
      );
    }
    return AlertDialog(
      title: YaruTitleBar(
        title: model.packageState != PackageState.ready
            ? null
            : Row(
                children: [
                  const Icon(YaruIcons.debian),
                  Text(widget.id.name),
                ],
              ),
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      scrollable: true,
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            YaruExpandable(
              header: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  context.l10n.changelog,
                  style: headerStyle,
                ),
              ),
              expandIcon: const Icon(YaruIcons.pan_end),
              isExpanded: true,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 150,
                  minHeight: 150,
                ),
                // height: 250,
                child: Markdown(
                  data: model.changelog.length > 4000
                      ? '${model.changelog.substring(0, 4000)}\n\n ... ${context.l10n.changelogTooLong} ${model.url}'
                      : model.changelog,
                  shrinkWrap: true,
                  selectable: true,
                  onTapLink: (text, href, title) =>
                      href != null ? launchUrl(Uri.parse(href)) : null,
                  padding: const EdgeInsets.only(left: 8, right: 8),
                ),
              ),
            ),
            YaruTile(
              title: Text(
                context.l10n.version,
                style: headerStyle,
              ),
              trailing: Text(widget.id.version),
            ),
            YaruTile(
              title: Text(
                context.l10n.size,
                style: headerStyle,
              ),
              trailing: Text(model.size),
            ),
            YaruTile(
              title: Text(
                context.l10n.architecture,
                style: headerStyle,
              ),
              trailing: Text(widget.id.arch),
            ),
            YaruTile(
              title: Text(
                context.l10n.source,
                style: headerStyle,
              ),
              trailing: Text(widget.id.data),
            ),
            YaruTile(
              title: Text(
                context.l10n.license,
                style: headerStyle,
              ),
              trailing: Text(model.license),
            ),
            YaruTile(
              title: Text(
                context.l10n.website,
                style: headerStyle,
              ),
              trailing: IconButton(
                splashRadius: 20,
                tooltip: model.url,
                onPressed: () => launchUrl(Uri.parse(model.url)),
                icon: Icon(
                  YaruIcons.external_link,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
              ),
              enabled: true,
            ),
            YaruTile(
              title: Text(
                context.l10n.issued,
                style: headerStyle,
              ),
              trailing: Text(model.issued),
            ),
            YaruExpandable(
              header: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  context.l10n.description,
                  style: headerStyle,
                ),
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
