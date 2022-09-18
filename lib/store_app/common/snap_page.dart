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
import 'package:software/store_app/common/app_media.dart';
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

    return Scaffold(
      appBar: AppBar(
        actions: const [SnapControls()],
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
              child: YaruSafeImage(
                url: model.iconUrl,
                fallBackIconData: YaruIcons.package_snap,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(model.title ?? ''),
            ),
          ],
        ),
        leading: InkWell(
          onTap: widget.onPop,
          child: const Icon(YaruIcons.go_previous),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        children: [
          if (media.isNotEmpty) AppMedia(media: media),
          const SizedBox(
            height: 40,
          ),
          AppInfos(
            strict: model.strict,
            confinementName:
                model.confinement != null ? model.confinement!.name : '',
            license: model.license ?? '',
            installDate: model.installDate,
            installDateIsoNorm: model.installDateIsoNorm,
            version: model.version,
          ),
          const SizedBox(
            height: 20,
          ),
          AppDescription(description: model.description ?? ''),
          const SizedBox(
            height: 40,
          ),
          SnapConnectionsSettings(connections: model.connections)
        ],
      ),
    );
  }
}
