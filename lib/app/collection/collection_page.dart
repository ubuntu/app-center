import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/app/collection/collection_model.dart';
import 'package:software/app/collection/package_updates_model.dart';
import 'package:software/app/collection/package_updates_page.dart';
import 'package:software/app/collection/simple_snap_controls.dart';
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/app_format_popup.dart';
import 'package:software/app/common/app_icon.dart';
import 'package:software/app/common/border_container.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/indeterminate_circular_progress_icon.dart';
import 'package:software/app/common/packagekit/package_controls.dart';
import 'package:software/app/common/packagekit/package_model.dart';
import 'package:software/app/common/packagekit/package_page.dart';
import 'package:software/app/common/packagekit/packagekit_filter_button.dart';
import 'package:software/app/common/search_field.dart';
import 'package:software/app/common/snap/snap_page.dart';
import 'package:software/app/common/snap/snap_sort_popup.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:software/services/packagekit/updates_state.dart';
import 'package:software/services/snap_service.dart';
import 'package:software/snapx.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:ubuntu_session/ubuntu_session.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class CollectionPage extends StatelessWidget {
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

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.collection);

  @override
  Widget build(BuildContext context) {
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

    final content = Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 20,
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppFormatPopup(
                  onSelected: (appFormat) => setAppFormat(appFormat),
                  appFormat: appFormat ?? AppFormat.snap,
                  enabledAppFormats: enabledAppFormats,
                ),
                if (appFormat == AppFormat.snap)
                  ...snapChildren
                else
                  ...packageKitChildren
              ],
            ),
          ),
          if (appFormat == AppFormat.snap)
            const Expanded(
              child: _SnapList(),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: const [PackageUpdatesPage(), _PackagesList()],
                  ),
                ),
              ),
            )
        ],
      ),
    );

    return Scaffold(
      appBar: YaruWindowTitleBar(
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

class _SnapList extends StatelessWidget {
  const _SnapList();

  @override
  Widget build(BuildContext context) {
    final installedSnaps =
        context.select((CollectionModel m) => m.installedSnaps);
    final snapUpdates =
        context.select((CollectionModel m) => m.snapsWithUpdate);

    final checkingForSnapUpdates =
        context.select((CollectionModel m) => m.checkingForSnapUpdates);

    if (checkingForSnapUpdates == false &&
        installedSnaps != null &&
        installedSnaps.isEmpty) {
      return Center(
        child: Text(context.l10n.noSnapsInstalled),
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            if (snapUpdates.isNotEmpty)
              BorderContainer(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(
                  left: kYaruPagePadding,
                  right: kYaruPagePadding,
                  bottom: kYaruPagePadding,
                ),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapUpdates.length,
                  itemBuilder: (context, i) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SnapTile(
                          tileShape: snapUpdates.length == 1
                              ? _RoundedListPosition.only
                              : (i == 0
                                  ? _RoundedListPosition.top
                                  : (i == snapUpdates.length - 1
                                      ? _RoundedListPosition.bottom
                                      : _RoundedListPosition.middle)),
                          snap: snapUpdates[i],
                          hasUpdate: true,
                          enabled: checkingForSnapUpdates,
                        ),
                        if ((i == 0 && snapUpdates.length > 1) ||
                            (i != snapUpdates.length - 1))
                          const Divider(
                            thickness: 0.0,
                            height: 0,
                          )
                      ],
                    );
                  },
                ),
              ),
            if (installedSnaps == null)
              const Center(
                child: YaruCircularProgressIndicator(),
              )
            else if (installedSnaps.isNotEmpty)
              BorderContainer(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(
                  left: kYaruPagePadding,
                  right: kYaruPagePadding,
                  bottom: kYaruPagePadding,
                ),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: installedSnaps.length,
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SnapTile(
                          tileShape: installedSnaps.length == 1
                              ? _RoundedListPosition.only
                              : (i == 0
                                  ? _RoundedListPosition.top
                                  : (i == installedSnaps.length - 1
                                      ? _RoundedListPosition.bottom
                                      : _RoundedListPosition.middle)),
                          snap: installedSnaps[i],
                          enabled: checkingForSnapUpdates,
                        ),
                        if ((i == 0 && installedSnaps.length > 1) ||
                            (i != installedSnaps.length - 1))
                          const Divider(
                            thickness: 0.0,
                            height: 0,
                          )
                      ],
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}

class _SnapTile extends StatelessWidget {
  const _SnapTile({
    required this.snap,
    required this.enabled,
    this.hasUpdate = false,
    this.tileShape = _RoundedListPosition.middle,
  });

  final Snap snap;
  final bool hasUpdate;
  final bool? enabled;
  final _RoundedListPosition tileShape;

  @override
  Widget build(BuildContext context) {
    final shape = tileShape == _RoundedListPosition.middle
        ? null
        : (tileShape == _RoundedListPosition.top
            ? _topChildShape
            : (tileShape == _RoundedListPosition.bottom
                ? _bottomChildShape
                : _onlyChildShape));
    return ListTile(
      shape: shape,
      key: ValueKey(snap),
      enabled: enabled == false,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: kYaruPagePadding,
        vertical: 10,
      ),
      onTap: () => SnapPage.push(context: context, snap: snap),
      leading: AppIcon(
        iconUrl: snap.iconUrl,
        size: 25,
      ),
      title: Text(
        snap.name,
      ),
      trailing: SimpleSnapControls.create(
        context: context,
        snap: snap,
        hasUpdate: hasUpdate,
        enabled: enabled == false,
      ),
    );
  }
}

class _PackagesList extends StatelessWidget {
  const _PackagesList();

  @override
  Widget build(BuildContext context) {
    final installedPackages =
        context.select((CollectionModel m) => m.installedPackages ?? []);

    return installedPackages.isNotEmpty
        ? BorderContainer(
            padding: EdgeInsets.zero,
            margin: const EdgeInsets.only(
              left: kYaruPagePadding,
              right: kYaruPagePadding,
              bottom: kYaruPagePadding,
            ),
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: installedPackages.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PackageTile.create(
                      context,
                      installedPackages[index],
                      installedPackages.length == 1
                          ? _RoundedListPosition.only
                          : (index == 0
                              ? _RoundedListPosition.top
                              : (index == installedPackages.length - 1
                                  ? _RoundedListPosition.bottom
                                  : _RoundedListPosition.middle)),
                    ),
                    if ((index == 0 && installedPackages.length > 1) ||
                        (index != installedPackages.length - 1))
                      const Divider(
                        thickness: 0.0,
                        height: 0,
                      )
                  ],
                );
              },
            ),
          )
        : const SizedBox();
  }
}

class _PackageTile extends StatelessWidget {
  const _PackageTile({required this.id, required this.tileShape});

  final PackageKitPackageId id;
  final _RoundedListPosition tileShape;

  static Widget create(
    BuildContext context,
    PackageKitPackageId id,
    _RoundedListPosition tileShape,
  ) {
    return ChangeNotifierProvider(
      key: ValueKey(id),
      create: (_) =>
          PackageModel(packageId: id, service: getService<PackageService>())
            ..isInstalled = true,
      child: _PackageTile(
        id: id,
        tileShape: tileShape,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shape = tileShape == _RoundedListPosition.middle
        ? null
        : (tileShape == _RoundedListPosition.top
            ? _topChildShape
            : (tileShape == _RoundedListPosition.bottom
                ? _bottomChildShape
                : _onlyChildShape));

    return ListTile(
      shape: shape,
      key: ValueKey(id),
      contentPadding: const EdgeInsets.only(
        left: kYaruPagePadding,
        top: 10,
        bottom: 10,
        right: 10,
      ),
      onTap: () => PackagePage.push(context, id: id),
      leading: const AppIcon(
        iconUrl: null,
        size: 25,
      ),
      title: Text(
        id.name,
      ),
      trailing: const PackageControls(),
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

enum _RoundedListPosition {
  top,
  middle,
  bottom,
  only;
}

const _topChildShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(10),
    topRight: Radius.circular(10),
  ),
);

const _bottomChildShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    bottomLeft: Radius.circular(10),
    bottomRight: Radius.circular(10),
  ),
);

const _onlyChildShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    bottomLeft: Radius.circular(10),
    bottomRight: Radius.circular(10),
    topLeft: Radius.circular(10),
    topRight: Radius.circular(10),
  ),
);
