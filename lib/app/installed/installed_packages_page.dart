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
import 'package:software/app/common/animated_scroll_view_item.dart';
import 'package:software/app/common/app_icon.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/packagekit/package_page.dart';
import 'package:software/app/installed/installed_model.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class InstalledPackagesPage extends StatefulWidget {
  const InstalledPackagesPage({Key? key}) : super(key: key);

  @override
  State<InstalledPackagesPage> createState() => _InstalledPackagesPageState();
}

class _InstalledPackagesPageState extends State<InstalledPackagesPage> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<InstalledModel>();
    final installedApps = model.searchQuery == null
        ? model.installedPackages
        : model.installedPackages
            .where((element) => element.name.startsWith(model.searchQuery!))
            .toList();

    return model.installedPackages.isNotEmpty
        ? GridView.builder(
            controller: _controller,
            padding: const EdgeInsets.only(
              bottom: 15,
              right: 15,
              left: 15,
            ),
            gridDelegate: kGridDelegate,
            shrinkWrap: false,
            itemCount: installedApps.length,
            itemBuilder: (context, index) {
              final package = installedApps[index];
              return AnimatedScrollViewItem(
                child: YaruBanner.tile(
                  title: Text(package.name),
                  subtitle: Text(package.version),
                  onTap: () => PackagePage.push(context, id: package),
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 10, right: 5),
                    child: AppIcon(
                      iconUrl: null,
                    ),
                  ),
                ),
              );
            },
          )
        : const SizedBox();
  }
}
