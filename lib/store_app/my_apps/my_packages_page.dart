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
import 'package:software/store_app/common/animated_scroll_view_item.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/my_apps/my_apps_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MyPackagesPage extends StatefulWidget {
  const MyPackagesPage({Key? key}) : super(key: key);

  @override
  State<MyPackagesPage> createState() => _MyPackagesPageState();
}

class _MyPackagesPageState extends State<MyPackagesPage> {
  late ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController();
    context.read<MyAppsModel>().init();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MyAppsModel>();
    final installedApps = model.searchQuery == null
        ? model.installedApps
        : model.installedApps
            .where((element) => element.name.startsWith(model.searchQuery!))
            .toList();

    return model.installedApps.isNotEmpty
        ? GridView.builder(
            controller: _controller,
            padding: const EdgeInsets.all(20.0),
            gridDelegate: kGridDelegate,
            shrinkWrap: true,
            itemCount: installedApps.length,
            itemBuilder: (context, index) {
              final package = installedApps[index];
              return AnimatedScrollViewItem(
                child: YaruBanner(
                  name: package.name,
                  summary: package.version,
                  fallbackIconData: YaruIcons.package_deb,
                  onTap: () => model.selectedPackage = package,
                ),
              );
            },
          )
        : const SizedBox();
  }
}
