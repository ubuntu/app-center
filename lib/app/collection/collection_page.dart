import 'dart:math';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/app/collection/collection_model.dart';
import 'package:software/app/collection/collection_toggle.dart';
import 'package:software/app/collection/package_collection.dart';
import 'package:software/app/collection/package_updates_model.dart';
import 'package:software/app/collection/snap_collection.dart';
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/indeterminate_circular_progress_icon.dart';
import 'package:software/app/common/packagekit/packagekit_filter_button.dart';
import 'package:software/app/common/search_field.dart';
import 'package:software/app/common/snap/snap_sort_popup.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:software/services/packagekit/updates_state.dart';
import 'package:software/services/snap_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:ubuntu_session/ubuntu_session.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  static Widget create(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CollectionModel(
            getService<SnapService>(),
            getService<PackageService>(),
          )..init(),
        ),
        ChangeNotifierProvider<PackageUpdatesModel>(
          create: (_) => PackageUpdatesModel(
            getService<PackageService>(),
            getService<UbuntuSession>(),
          ),
        )
      ],
      child: const CollectionPage(),
    );
  }

  static Widget createIcon({
    required BuildContext context,
    required bool selected,
    int? badgeCount,
    bool? processing,
    int? updateCount,
    bool? updateProcessing,
  }) {
    return _CollectionIcon(
      count: (badgeCount ?? 0) + (updateCount ?? 0),
      processing: (processing ?? false) || (updateProcessing ?? false),
    );
  }

  static Widget createTitle(BuildContext context) => Text(context.l10n.manage);

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  late ScrollController _controller;
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(() {
      if (_controller.offset > 50.0) {
        setState(() => _showFab = true);
      } else {
        setState(() => _showFab = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchQuery = context.select((CollectionModel m) => m.searchQuery);
    final setSearchQuery =
        context.select((CollectionModel m) => m.setSearchQuery);
    final appFormat = context.select((CollectionModel m) => m.appFormat);
    final setAppFormat = context.select((CollectionModel m) => m.setAppFormat);
    final enabledAppFormats =
        context.select((CollectionModel m) => m.enabledAppFormats);

    final loadSnaps = context.select((CollectionModel m) => m.loadSnaps);
    final snapsWithUpdate =
        context.select((CollectionModel m) => m.snapsWithUpdate);
    final checkingForSnapUpdates =
        context.select((CollectionModel m) => m.checkingForSnapUpdates);
    final refreshAllSnapsWithUpdates =
        context.select((CollectionModel m) => m.refreshAllSnapsWithUpdates);
    final snapSort = context.select((CollectionModel m) => m.snapSort);
    final setSnapSort = context.select((CollectionModel m) => m.setSnapSort);

    final packageKitFilters =
        context.select((CollectionModel m) => m.packageKitFilters);
    final handleFilter = context.select((CollectionModel m) => m.handleFilter);

    final checkForPackageUpdates =
        context.select((PackageUpdatesModel m) => m.refresh);
    final checkingForPackageUpdates = context.select(
      (PackageUpdatesModel m) =>
          m.updatesState == UpdatesState.checkingForUpdates,
    );
    final updateAllPackages =
        context.select((PackageUpdatesModel m) => m.updateAll);
    final selectedUpdatesLength =
        context.select((PackageUpdatesModel m) => m.selectedUpdatesLength);
    final availablePackageUpdatesLength =
        context.select((PackageUpdatesModel m) => m.updates.length);

    double hPadding;
    double windowWidth = MediaQuery.of(context).size.width;

    if (windowWidth <= 1200) {
      hPadding = kPagePadding;
    } else {
      hPadding = kPagePadding + 0.0004 * pow((windowWidth - 1200) * 0.8, 2);
    }

    final snapChildren = [
      SnapSortPopup(
        value: snapSort,
        onSelected: (value) => setSnapSort(value),
      ),
      OutlinedButton(
        onPressed: checkingForSnapUpdates == true ? null : () => loadSnaps(),
        child: Text(context.l10n.refreshButton),
      ),
      if (checkingForSnapUpdates == true)
        const _ProgressIndicator()
      else if (snapsWithUpdate.isNotEmpty)
        ElevatedButton(
          onPressed: () => refreshAllSnapsWithUpdates(
            doneMessage: context.l10n.done,
          ),
          child: Text(
            '${context.l10n.updateButton} (${snapsWithUpdate.length})',
          ),
        ),
    ];

    final packageKitChildren = [
      PackageKitFilterButton(
        onTap: handleFilter,
        filters: packageKitFilters,
      ),
      OutlinedButton(
        onPressed:
            checkingForPackageUpdates ? null : () => checkForPackageUpdates(),
        child: Text(context.l10n.refreshButton),
      ),
      if (checkingForPackageUpdates)
        const _ProgressIndicator()
      else
        ElevatedButton(
          onPressed: selectedUpdatesLength == 0
              ? null
              : () => updateAllPackages(
                    updatesComplete: context.l10n.updatesComplete,
                    updatesAvailable: context.l10n.updateAvailable,
                  ),
          child: Text(
            '${context.l10n.updateButton} ($selectedUpdatesLength)',
          ),
        ),
    ];

    final floatingActionButton = FloatingActionButton(
      foregroundColor: theme.colorScheme.onInverseSurface,
      backgroundColor: theme.colorScheme.inverseSurface,
      shape: const CircleBorder(),
      onPressed: () => _controller.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
      ),
      child: const Icon(YaruIcons.pan_up),
    );

    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: kPagePadding),
              child: Wrap(
                spacing: 10,
                runSpacing: 20,
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  CollectionToggle(
                    onSelected: (appFormat) => setAppFormat(appFormat),
                    appFormat: appFormat ?? AppFormat.snap,
                    enabledAppFormats: enabledAppFormats,
                    badgedAppFormats: {
                      AppFormat.snap: snapsWithUpdate.length,
                      AppFormat.packageKit: availablePackageUpdatesLength,
                    },
                  ),
                  if (appFormat == AppFormat.snap)
                    ...snapChildren
                  else
                    ...packageKitChildren
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _controller,
                    child: (appFormat == AppFormat.snap)
                        ? const SnapCollection()
                        : PackageCollection(
                            enabled: !checkingForPackageUpdates,
                          ),
                  ),
                  if (_showFab)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(kYaruPagePadding),
                        child: floatingActionButton,
                      ),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: YaruWindowTitleBar(
        leading: const SizedBox(width: kLeadingGap),
        title: SearchField(
          searchQuery: searchQuery ?? '',
          onChanged: setSearchQuery,
          hintText: context.l10n.searchHintInstalled,
        ),
      ),
      body: content,
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 25,
      width: 25,
      child: Center(
        child: YaruCircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }
}

class _CollectionIcon extends StatelessWidget {
  const _CollectionIcon({
    // ignore: unused_element
    super.key,
    required this.count,
    required this.processing,
  });

  final int count;
  final bool processing;

  @override
  Widget build(BuildContext context) {
    const icon = Icon(YaruIcons.app_grid);
    final theme = Theme.of(context);
    if (processing && count > 0) {
      return badges.Badge(
        position: badges.BadgePosition.topEnd(),
        badgeColor: count > 0 ? theme.primaryColor : Colors.transparent,
        badgeContent: count > 0
            ? Text(
                count.toString(),
                style: badgeTextStyle,
              )
            : null,
        child: const IndeterminateCircularProgressIcon(),
      );
    } else if (processing && count == 0) {
      return const IndeterminateCircularProgressIcon();
    } else if (!processing && count > 0) {
      return badges.Badge(
        badgeColor: theme.primaryColor,
        badgeContent: Text(
          count.toString(),
          style: badgeTextStyle,
        ),
        child: icon,
      );
    }
    return icon;
  }
}
