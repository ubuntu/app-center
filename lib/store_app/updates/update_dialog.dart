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
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../l10n/l10n.dart';
import '../../package_state.dart';
import '../../services/package_service.dart';
import '../common/app_icon.dart';
import '../common/packagekit/package_model.dart';
import '../common/utils.dart';

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({
    super.key,
    required this.id,
    required this.installedId,
  });

  final PackageKitPackageId id;
  final PackageKitPackageId installedId;

  static Widget create({
    required BuildContext context,
    required PackageKitPackageId id,
    required PackageKitPackageId installedId,
    bool noUpdate = true,
  }) {
    return ChangeNotifierProvider(
      create: (context) =>
          PackageModel(service: getService<PackageService>(), packageId: id),
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
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PackageModel>().init(update: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PackageModel>();
    const headerStyle = TextStyle(fontWeight: FontWeight.bold);
    const detailStyle = TextStyle(fontWeight: FontWeight.w400);
    const detailPadding = EdgeInsets.only(top: 8, bottom: 8, right: 16);
    if (model.packageState != PackageState.ready || model.changelog.isEmpty) {
      return const AlertDialog(
        content: Padding(
          padding: EdgeInsets.only(bottom: 40, top: 40),
          child: YaruCircularProgressIndicator(),
        ),
      );
    }
    final children = [
      YaruExpandable(
        isExpanded: true,
        header: Text(
          context.l10n.changelog,
          style: headerStyle,
        ),
        child: MarkdownBody(
          data: model.changelog.length > 4000
              ? '${model.changelog.substring(0, 4000)}\n\n ... ${context.l10n.changelogTooLong} ${model.url}'
              : model.changelog,
          shrinkWrap: true,
          selectable: true,
          onTapLink: (text, href, title) =>
              href != null ? launchUrl(Uri.parse(href)) : null,
        ),
      ),
      YaruExpandable(
        header: Text(
          context.l10n.packageDetails,
          style: headerStyle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            YaruTile(
              padding: detailPadding,
              title: Text(
                context.l10n.version,
                style: detailStyle,
              ),
              trailing: Text(widget.id.version),
            ),
            YaruTile(
              padding: detailPadding,
              title: Text(
                context.l10n.size,
                style: detailStyle,
              ),
              trailing: Text(formatBytes(model.size, 2)),
            ),
            YaruTile(
              padding: detailPadding,
              title: Text(
                context.l10n.architecture,
                style: detailStyle,
              ),
              trailing: Text(widget.id.arch),
            ),
            YaruTile(
              padding: detailPadding,
              title: Text(
                context.l10n.source,
                style: detailStyle,
              ),
              trailing: Text(widget.id.data),
            ),
            YaruTile(
              padding: detailPadding,
              title: Text(
                context.l10n.license,
                style: detailStyle,
              ),
              trailing: Text(model.license),
            ),
            YaruTile(
              padding: detailPadding,
              title: Text(
                context.l10n.website,
                style: detailStyle,
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
              padding: detailPadding,
              title: Text(
                context.l10n.issued,
                style: detailStyle,
              ),
              trailing: Text(model.issued),
            ),
          ],
        ),
      ),
      YaruExpandable(
        header: Text(
          context.l10n.description,
          style: headerStyle,
        ),
        isExpanded: false,
        expandIcon: const Icon(YaruIcons.pan_end),
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Text(
            model.description,
          ),
        ),
      )
    ];
    return SimpleDialog(
      title: YaruTitleBar(
        centerTitle: false,
        title: model.packageState != PackageState.ready
            ? null
            : Row(
                children: [
                  const AppIcon(
                    iconUrl: null,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      widget.id.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding:
          const EdgeInsets.only(left: 20, top: 10, bottom: 20, right: 10),
      children: children
          .map(
            (e) => SizedBox(
              width: 500,
              child: e,
            ),
          )
          .toList(),
    );
  }
}
