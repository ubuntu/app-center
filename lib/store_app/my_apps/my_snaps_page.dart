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
import 'package:shimmer/shimmer.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/snapx.dart';
import 'package:software/store_app/common/app_icon.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/snap/snap_page.dart';
import 'package:software/store_app/my_apps/my_apps_model.dart';
import 'package:software/store_app/updates/no_updates_page.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MySnapsPage extends StatefulWidget {
  const MySnapsPage({Key? key}) : super(key: key);
  @override
  State<MySnapsPage> createState() => _MySnapsPageState();
}

class _MySnapsPageState extends State<MySnapsPage> {
  @override
  void initState() {
    context.read<MyAppsModel>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MyAppsModel>();
    final snaps = model.searchQuery == null
        ? model.localSnaps
        : model.localSnaps
            .where(
              (s) => s.name.startsWith(model.searchQuery!),
            )
            .toList();

    if (model.localSnaps.isEmpty) {
      return model.loadSnapsWithUpdates
          ? const NoUpdatesPage(
              expand: false,
            )
          : const _LoadingGrid();
    }

    return model.busy
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.justAMoment,
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(
                  height: kYaruPagePadding,
                ),
                const YaruCircularProgressIndicator(),
              ],
            ),
          )
        : _MySnapsGrid(snaps: snaps);
  }
}

class _MySnapsGrid extends StatelessWidget {
  // ignore: unused_element
  const _MySnapsGrid({super.key, required this.snaps});

  final List<Snap> snaps;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: kGridPadding,
      gridDelegate: kGridDelegate,
      shrinkWrap: true,
      itemCount: snaps.length,
      itemBuilder: (context, index) {
        final snap = snaps.elementAt(index);
        return YaruBanner(
          title: Text(
            snap.name,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            snap.summary,
            overflow: TextOverflow.ellipsis,
          ),
          icon: Padding(
            padding: kIconPadding,
            child: AppIcon(
              iconUrl: snap.iconUrl,
            ),
          ),
          onTap: () => SnapPage.push(context, snap),
        );
      },
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  // ignore: unused_element
  const _LoadingGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var light = theme.brightness == Brightness.light;
    final shimmerBase = light
        ? const Color.fromARGB(120, 228, 228, 228)
        : theme.colorScheme.onSurface.withOpacity(0.02);
    final shimmerHighLight = light
        ? const Color.fromARGB(200, 247, 247, 247)
        : theme.colorScheme.onSurface.withOpacity(0.25);
    return GridView.builder(
      padding: kGridPadding,
      gridDelegate: kGridDelegate,
      shrinkWrap: true,
      itemCount: 40,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: shimmerBase,
          highlightColor: shimmerHighLight,
          child: const YaruBanner(
            title: Text(
              '',
              overflow: TextOverflow.ellipsis,
            ),
            icon: Padding(
              padding: kIconPadding,
              child: AppIcon(
                iconUrl: null,
              ),
            ),
          ),
        );
      },
    );
  }
}
