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
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/snap/snap_grid.dart';
import 'package:software/app/common/updates_splash_screen.dart';
import 'package:software/app/updates/no_updates_page.dart';
import 'package:software/app/updates/snap_updates_model.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/snap_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';

class SnapUpdatesPage extends StatelessWidget {
  const SnapUpdatesPage({Key? key}) : super(key: key);

  static Widget create(
    BuildContext context,
  ) {
    return ChangeNotifierProvider(
      create: (context) => SnapUpdatesModel(
        getService<SnapService>(),
      )..init(
          onRefreshError: (e) => ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e))),
        ),
      child: const SnapUpdatesPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapUpdatesModel>();
    final snaps = model.snapsWithUpdates ?? [];

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(kPagePadding),
          child: _SnapUpdatesHeader(),
        ),
        Expanded(
          child: Center(
            child: model.checkingForUpdates
                ? const UpdatesSplashScreen(icon: YaruIcons.snapcraft)
                : snaps.isEmpty
                    ? const NoUpdatesPage()
                    : SnapGrid(
                        snaps: snaps,
                      ),
          ),
        )
      ],
    );
  }
}

class _SnapUpdatesHeader extends StatelessWidget {
  const _SnapUpdatesHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapUpdatesModel>();
    final snaps = model.snapsWithUpdates ?? [];
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 10,
        children: [
          OutlinedButton(
            onPressed: model.checkingForUpdates ? null : model.checkForUpdates,
            child: Text(
              context.l10n.refreshButton,
            ),
          ),
          if (snaps.isNotEmpty)
            ElevatedButton(
              onPressed: model.checkingForUpdates
                  ? null
                  : () => model.refreshAll(
                        doneMessage: context.l10n.done,
                      ),
              child: Text(context.l10n.updateButton),
            ),
        ],
      ),
    );
  }
}
