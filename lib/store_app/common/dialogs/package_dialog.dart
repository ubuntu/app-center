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
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/package_state.dart';
import 'package:software/services/package_service.dart';
import 'package:software/store_app/common/dialogs/app_content.dart';
import 'package:software/store_app/common/app_header.dart';
import 'package:software/store_app/common/constants.dart';
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
    return SizedBox(
      width: dialogWidth,
      child: AlertDialog(
        title: YaruDialogTitle(
          mainAxisAlignment: MainAxisAlignment.center,
          closeIconData: YaruIcons.window_close,
          titleWidget: model.packageState != PackageState.ready
              ? Text(widget.id.name)
              : AppHeader(
                  icon: InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: model.isInstalled
                        ? () => model.open(widget.id.name)
                        : null,
                    child: const YaruSafeImage(
                      url: '',
                      fallBackIconData: YaruIcons.package_deb,
                    ),
                  ),
                  title: widget.id.name,
                  summary: model.summary,
                  verified: false,
                  publisherName: '',
                  website: model.url,
                  version: widget.id.version,
                  strict: false,
                  confinementName: context.l10n.classic,
                  license: model.license,
                  installDate: '',
                  installDateIsoNorm: '',
                ),
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.only(
          left: 25,
          right: 25,
          bottom: 25,
        ),
        scrollable: false,
        content: model.packageState != PackageState.ready
            ? SizedBox(
                width: dialogWidth,
                height: 200,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(model.info != null ? model.info!.name : ''),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: YaruLinearProgressIndicator(
                        value: model.percentage != null
                            ? model.percentage! / 100
                            : 0,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: SizedBox(
                  width: dialogWidth,
                  child: AppContent(
                    media: const [],
                    contact: '',
                    publisherName: '',
                    website: model.url,
                    description: model.description,
                  ),
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
      ),
    );
  }
}
