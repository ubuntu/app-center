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
import 'package:software/store_app/common/app_media.dart';
import 'package:software/store_app/common/border_container.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/one_column_app_header.dart';
import 'package:software/store_app/common/page_layouts.dart';
import 'package:software/store_app/common/snap_connections_settings.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:software/store_app/common/two_column_app_header.dart';
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
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    final rightChildren = [
      BorderContainer(
        padding: const EdgeInsets.only(
          bottom: pagePadding,
          right: pagePadding,
        ),
        child: AppMedia(media: media),
      ),
      BorderContainer(
        padding: const EdgeInsets.only(
          bottom: pagePadding,
          right: pagePadding,
        ),
        child: AppDescription(description: model.description ?? ''),
      ),
      BorderContainer(
        padding: const EdgeInsets.only(
          bottom: pagePadding,
          right: pagePadding,
        ),
        child: SnapConnectionsSettings(connections: model.connections),
      )
    ];

    final oneColumnAppHeader = BorderContainer(
      padding: const EdgeInsets.all(pagePadding),
      // width: 500,
      child: OneColumnAppHeader(
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
    );

    final twoColumnAppHeader = BorderContainer(
      padding: const EdgeInsets.all(pagePadding),
      width: 500,
      child: TwoColumnAppHeader(
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
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(model.title ?? ''),
        leading: InkWell(
          onTap: widget.onPop,
          child: const Icon(YaruIcons.go_previous),
        ),
      ),
      body: screenWidth < 1001
          ? NarrowPageLayout(
              children: [
                oneColumnAppHeader,
                for (final rightChild in rightChildren)
                  Padding(
                    padding: const EdgeInsets.only(left: pagePadding),
                    child: rightChild,
                  )
              ],
            )
          : WidePageLayout(
              leftChild: twoColumnAppHeader,
              rightChildren: rightChildren,
            ),
    );
  }
}
