import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:software/app/collection/collection_model.dart';
import 'package:software/app/collection/collection_tile.dart';
import 'package:software/app/collection/package_updates_page.dart';
import 'package:software/app/common/border_container.dart';
import 'package:software/app/common/packagekit/package_controls.dart';
import 'package:software/app/common/packagekit/package_model.dart';
import 'package:software/app/common/packagekit/package_page.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PackageCollection extends StatelessWidget {
  const PackageCollection({super.key, this.enabled = true, this.amount = 40});
  final bool enabled;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const PackageUpdatesPage(),
          _InstalledPackagesList(
            enabled: enabled,
            amount: amount,
          )
        ],
      ),
    );
  }
}

class _InstalledPackagesList extends StatelessWidget {
  const _InstalledPackagesList({required this.enabled, required this.amount});

  final bool enabled;
  final int amount;

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
              itemCount: installedPackages.take(amount).length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PackageTile.create(
                      context,
                      installedPackages[index],
                      installedPackages.length == 1
                          ? CollectionTilePosition.only
                          : (index == 0
                              ? CollectionTilePosition.top
                              : (index == installedPackages.length - 1
                                  ? CollectionTilePosition.bottom
                                  : CollectionTilePosition.middle)),
                      enabled,
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
  const _PackageTile({
    required this.id,
    required this.tileShape,
    this.enabled = true,
  });

  final PackageKitPackageId id;
  final CollectionTilePosition tileShape;
  final bool enabled;

  static Widget create(
    BuildContext context,
    PackageKitPackageId id,
    CollectionTilePosition tileShape,
    bool enabled,
  ) {
    return ChangeNotifierProvider(
      key: ValueKey(id),
      create: (_) =>
          PackageModel(packageId: id, service: getService<PackageService>())
            ..isInstalled = true,
      child: _PackageTile(
        enabled: enabled,
        id: id,
        tileShape: tileShape,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CollectionTile(
      enabled: enabled,
      collectionTilePosition: tileShape,
      name: id.name,
      key: ValueKey(id),
      trailing: const PackageControls(),
      onTap: () => PackagePage.push(
        context,
        id: id,
        enableSearch: false,
      ),
    );
  }
}
