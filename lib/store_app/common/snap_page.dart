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
import 'package:software/store_app/common/app_content.dart';
import 'package:software/store_app/common/app_header.dart';
import 'package:software/store_app/common/snap_connections_settings.dart';
import 'package:software/store_app/common/snap_installation_controls.dart';
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
    return Scaffold(
      appBar: AppBar(
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              icon: const Icon(YaruIcons.pan_down),
              borderRadius: BorderRadius.circular(10),
              elevation: 1,
              value: model.channelToBeInstalled,
              items: [
                for (final entry in model.selectableChannels.entries
                    .map((e) => e.key)
                    .toList())
                  DropdownMenuItem<String>(
                    value: entry,
                    child: Text(
                      '${context.l10n.channel}: $entry',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
              onChanged: model.appChangeInProgress
                  ? null
                  : (v) => model.channelToBeInstalled = v!,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          if (model.appChangeInProgress)
            const SizedBox(
              height: 25,
              child: YaruCircularProgressIndicator(
                strokeWidth: 3,
              ),
            )
          else
            SnapInstallationControls(
              appChangeInProgress: model.appChangeInProgress,
              appIsInstalled: model.snapIsInstalled,
              install: model.installSnap,
              refresh: model.refreshSnapApp,
              remove: model.removeSnap,
              open: model.isSnapEnv ? null : model.open,
            ),
          const SizedBox(
            width: 10,
          ),
        ],
        leading: InkWell(
          onTap: widget.onPop,
          child: const Icon(YaruIcons.go_previous),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(40),
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
          AppContent(
            contact: model.contact ?? '',
            description: model.description ?? '',
            publisherName: model.publisher?.displayName ?? '',
            website: model.website ?? '',
            media: model.screenshotUrls ?? [],
            lastChild: model.strict && model.connections.isNotEmpty
                ? SnapConnectionsSettings(connections: model.connections)
                : null,
          ),
        ],
      ),
    );
  }
}
