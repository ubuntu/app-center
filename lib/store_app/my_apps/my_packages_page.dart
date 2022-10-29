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
import 'package:software/store_app/common/app_icon.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/packagekit/package_page.dart';
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
    super.initState();
    _controller = ScrollController();
    context.read<MyAppsModel>().init();
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
        ? model.installedPackages
        : model.installedPackages
            .where((element) => element.name.startsWith(model.searchQuery!))
            .toList();

    return model.installedPackages.isNotEmpty
        ? GridView.builder(
            controller: _controller,
            padding: kGridPadding,
            gridDelegate: kGridDelegate,
            shrinkWrap: true,
            itemCount: installedApps.length,
            itemBuilder: (context, index) {
              final package = installedApps[index];
              return AnimatedScrollViewItem(
                child: YaruBanner(
                  title: Text(package.name),
                  subtitle: Text(package.version),
                  onTap: () => PackagePage.push(context, package),
                  iconPadding: const EdgeInsets.only(left: 10, right: 5),
                  icon: const AppIcon(
                    iconUrl: null,
                    fallBackIconData: YaruIcons.debian,
                  ),
                ),
              );
            },
          )
        : const SizedBox();
  }
}
