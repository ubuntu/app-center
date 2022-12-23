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
import 'package:software/app/common/app_banner.dart';
import 'package:software/app/common/app_finding.dart';
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/loading_banner_grid.dart';
import 'package:software/app/common/snap/snap_utils.dart';
import 'package:software/app/explore/explore_model.dart';
import 'package:software/l10n/l10n.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    final onlySnaps = model.selectedAppFormats.contains(AppFormat.snap) &&
        !model.selectedAppFormats.contains(AppFormat.packageKit);
    final showSnap = model.selectedAppFormats.contains(AppFormat.snap);
    final showPackageKit =
        model.selectedAppFormats.contains(AppFormat.packageKit);

    return FutureBuilder<Map<String, AppFinding>>(
      future: model.search(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingBannerGrid();
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          var appFindings = snapshot.data!;

          if (onlySnaps) {
            appFindings = sortAppFindings(
              storeSnapSort: model.storeSnapSort,
              appFindings: appFindings,
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            gridDelegate: kGridDelegate,
            shrinkWrap: true,
            itemCount: appFindings.length,
            itemBuilder: (context, index) {
              final appFinding = appFindings.entries.elementAt(index);

              return AppBanner(
                appFinding: appFinding,
                showSnap: showSnap,
                showPackageKit: showPackageKit,
              );
            },
          );
        } else {
          return _NoSearchResultPage(message: context.l10n.noPackageFound);
        }
      },
    );
  }
}

class _NoSearchResultPage extends StatelessWidget {
  const _NoSearchResultPage({
    Key? key,
    required this.message,
  }) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🐣❓',
            style: TextStyle(fontSize: 40),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 400,
            child: Text(
              message,
              style: theme.textTheme.headline4?.copyWith(fontSize: 25),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(
            height: 200,
          ),
        ],
      ),
    );
  }
}
