import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/app/collection/collection_model.dart';
import 'package:software/app/collection/simple_snap_controls.dart';
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/app_format_popup.dart';
import 'package:software/app/common/app_icon.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/indeterminate_circular_progress_icon.dart';
import 'package:software/app/common/search_field.dart';
import 'package:software/app/common/snap/snap_page.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/snap_service.dart';
import 'package:software/snapx.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  static Widget create(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CollectionModel(
        getService<SnapService>(),
        // getService<PackageService>(),
      )..init(),
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
    final model = context.watch<CollectionModel>();

    final searchQuery = context.select((CollectionModel m) => m.searchQuery);
    final setSearchQuery =
        context.select((CollectionModel m) => m.setSearchQuery);

    final content = Center(
      child: SizedBox(
        width: 700,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Wrap(
                spacing: 10,
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppFormatPopup(
                    onSelected: (v) {},
                    appFormat: AppFormat.snap,
                    enabledAppFormats: const {
                      AppFormat.snap,
                    },
                  ),
                  OutlinedButton(
                    onPressed: model.checkingForSnapUpdates == true ||
                            model.serviceBusy == true
                        ? null
                        : () => model.checkForSnapUpdates(),
                    child: Text(context.l10n.refreshButton),
                  ),
                  if (model.checkingForSnapUpdates == true)
                    const SizedBox(
                      height: 25,
                      width: 25,
                      child: Center(
                        child: YaruCircularProgressIndicator(strokeWidth: 3),
                      ),
                    )
                  else if (model.snapUpdatesAvailable)
                    ElevatedButton(
                      onPressed: model.serviceBusy == true
                          ? null
                          : () => model.refreshAllSnapsWithUpdates(
                                doneMessage: context.l10n.done,
                              ),
                      child: const Text('Udate all'),
                    )
                ],
              ),
            ),
            Expanded(
              child: YaruBorderContainer(
                margin: const EdgeInsets.only(
                  left: kYaruPagePadding,
                  right: kYaruPagePadding,
                  bottom: kYaruPagePadding,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final e in searchQuery == null || searchQuery.isEmpty
                        ? model.installedSnaps.entries
                        : model.installedSnaps.entries.where(
                            (element) => element.key.name.contains(searchQuery),
                          ))
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            enabled: model.checkingForSnapUpdates == false,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: kYaruPagePadding,
                              vertical: 10,
                            ),
                            onTap: () =>
                                SnapPage.push(context: context, snap: e.key),
                            leading: AppIcon(
                              iconUrl: e.key.iconUrl,
                              size: 25,
                            ),
                            title: Text(
                              e.key.name,
                            ),
                            trailing: SimpleSnapControls.create(
                              context: context,
                              snap: e.key,
                              hasUpdate: e.value,
                              enabled: model.checkingForSnapUpdates == false,
                            ),
                          ),
                          const Divider(
                            thickness: 0.0,
                            height: 0,
                          )
                        ],
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
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
        child: const Icon(YaruIcons.unordered_list),
      );
    }
    return const Icon(YaruIcons.unordered_list);
  }
}
