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
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/app_change_service.dart';
import 'package:software/store_app/common/app_description.dart';
import 'package:software/store_app/common/app_header.dart';
import 'package:software/store_app/common/app_infos.dart';
import 'package:software/store_app/common/border_container.dart';
import 'package:software/store_app/common/media_tile.dart';
import 'package:software/store_app/common/page_layouts.dart';
import 'package:software/store_app/common/snap_connections_settings.dart';
import 'package:software/store_app/common/snap_controls.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

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
    final windowSize = MediaQuery.of(context).size;
    final windowWidth = windowSize.width;
    final windowHeight = windowSize.height;
    final isWindowNormalSized = windowWidth > 800 && windowWidth < 1400;
    final isWindowWide = windowWidth > 1400;

    final mediaDescriptionAndConnections = [
      if (media.isNotEmpty)
        BorderContainer(
          child: YaruCarousel(
            nextIcon: const Icon(YaruIcons.go_next),
            previousIcon: const Icon(YaruIcons.go_previous),
            navigationControls: media.length > 1,
            viewportFraction: isWindowWide ? 0.5 : 1,
            height: windowHeight / 3,
            children: [for (final url in media) MediaTile(url: url)],
          ),
        ),
      BorderContainer(
        child: AppDescription(description: model.description ?? ''),
      ),
      if (model.snapIsInstalled && model.strict)
        BorderContainer(
          child: SnapConnectionsSettings(connections: model.connections),
        )
    ];

    final headerData = AppHeaderData(
      confinementName: model.confinement != null ? model.confinement!.name : '',
      icon: model.iconUrl == null || model.iconUrl!.isEmpty
          ? BorderContainer(
              borderRadius: 200,
              width: isWindowNormalSized ? 150 : 180,
              child: const Icon(
                YaruIcons.snapcraft,
                size: 80,
              ),
            )
          : YaruSafeImage(
              url: model.iconUrl,
              fallBackIconData: YaruIcons.snapcraft,
              iconSize: 80,
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
      controls: const SnapControls(),
    );

    final normalWindowAppHeader = BorderContainer(
      child: BannerAppHeader(
        headerData: headerData,
      ),
    );

    final wideWindowAppHeader = BorderContainer(
      width: 480,
      child: PageAppHeader(
        headerData: headerData,
      ),
    );

    final narrowWindowAppHeader = BorderContainer(
      height: 700,
      child: PageAppHeader(
        headerData: headerData,
      ),
    );

    final normalWindowLayout = OnePageLayout(
      windowSize: windowSize,
      children: [
        normalWindowAppHeader,
        BorderContainer(
          child: AppInfos(
            strict: model.strict,
            confinementName:
                model.confinement != null ? model.confinement!.name : '',
            license: model.license ?? '',
            installDate: model.installDate,
            installDateIsoNorm: model.installDateIsoNorm,
            version: model.version,
          ),
        ),
        for (final part in mediaDescriptionAndConnections) part
      ],
    );

    final wideWindowLayout = PanedPageLayout(
      leftChild: wideWindowAppHeader,
      rightChildren: mediaDescriptionAndConnections,
      windowSize: windowSize,
    );

    final narrowWindowLayout = OnePageLayout(
      windowSize: windowSize,
      children: [
        narrowWindowAppHeader,
        for (final part in mediaDescriptionAndConnections) part
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(model.title ?? ''),
        leading: InkWell(
          onTap: widget.onPop,
          child: const Icon(YaruIcons.go_previous),
        ),
      ),
      body: isWindowWide
          ? wideWindowLayout
          : isWindowNormalSized
              ? normalWindowLayout
              : narrowWindowLayout,
    );
  }
}
