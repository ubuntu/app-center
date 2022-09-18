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
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/app_change_service.dart';
import 'package:software/store_app/common/app_header.dart';
import 'package:software/store_app/common/app_media.dart';
import 'package:software/store_app/common/snap_channel_expandable.dart';
import 'package:software/store_app/common/snap_controls.dart';
import 'package:software/store_app/common/snap_installation_controls.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

double getHPadding(double width) {
  var padding = 550.0;
  for (int i in [1800, 1700, 1600, 1500, 1400, 1300, 1200, 1100, 1000, 900]) {
    if (width > i) {
      return padding;
    }
    padding -= 50;
  }
  return padding;
}

class SnapPage extends StatefulWidget {
  const SnapPage({super.key, required this.onPop});

  final VoidCallback onPop;

  static Widget create({
    required BuildContext context,
    required String huskSnapName,
    required final VoidCallback onPop,
  }) =>
      ChangeNotifierProvider<SnapModel>(
        create: (_) => SnapModel(
          doneString: context.l10n.done,
          getService<SnapdClient>(),
          getService<AppChangeService>(),
          huskSnapName: huskSnapName,
        ),
        child: SnapPage(onPop: onPop),
      );

  @override
  State<SnapPage> createState() => _SnapPageState();
}

class _SnapPageState extends State<SnapPage> {
  @override
  void initState() {
    context.read<SnapModel>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();
    final media = model.screenshotUrls ?? [];
    final hPadding = getHPadding(MediaQuery.of(context).size.width);

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: widget.onPop,
          child: const Icon(YaruIcons.go_previous),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          top: 50,
          bottom: 50,
          left: hPadding,
          right: hPadding,
        ),
        children: [
          AppHeader(
            confinementName:
                model.confinement != null ? model.confinement!.name : '',
            icon: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: model.installDate.isNotEmpty ? model.open : null,
              child: YaruSafeImage(
                url: model.iconUrl,
                fallBackIconData: YaruIcons.package_snap,
              ),
            ),
            installDate: model.installDate,
            installDateIsoNorm: model.installDateIsoNorm,
            license: model.license ?? '',
            strict: model.strict,
            verified: model.verified,
            publisherName: model.publisher?.displayName ?? '',
            website: model.storeUrl ?? '',
            summary: model.summary ?? '',
            title: model.title ?? '',
            version: model.version,
          ),
          SnapChannelExpandable(
            onChanged: model.appChangeInProgress
                ? null
                : (v) => model.channelToBeInstalled = v!,
            channelToBeInstalled: model.channelToBeInstalled,
            onInit: () => model.init(),
            releasedAt: model.releasedAt,
            releaseAtIsoNorm: model.releaseAtIsoNorm,
            selectableChannelsIsEmpty: model.selectableChannels.isEmpty,
            selectedChannelVersion: model.selectedChannelVersion ?? '',
            selectableChannels:
                model.selectableChannels.entries.map((e) => e.key).toList(),
          ),
          const SizedBox(
            height: 40,
          ),
          if (media.isNotEmpty) AppMedia(media: media),
          const SizedBox(
            height: 50,
          ),
          Text(
            context.l10n.description,
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(
            height: 20,
          ),
          Markdown(
            data: model.description ?? '',
            shrinkWrap: true,
            selectable: true,
            onTapLink: (text, href, title) =>
                href != null ? launchUrl(Uri.parse(href)) : null,
            padding: EdgeInsets.zero,
            styleSheet: MarkdownStyleSheet(
              p: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
