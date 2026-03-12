import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/manage_app_data.dart';
import 'package:app_center/manage/manage_deb_actions.dart';
import 'package:app_center/manage/manage_l10n.dart';
import 'package:app_center/manage/manage_snap_actions.dart';
import 'package:app_center/store/store.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ManageTilePosition { first, middle, last, single }

ManageTilePosition determineTilePosition({
  required int index,
  required int length,
}) {
  if (length == 1) {
    return ManageTilePosition.single;
  }

  if (index == length - 1) {
    return ManageTilePosition.last;
  }

  if (index == 0) {
    return ManageTilePosition.first;
  } else {
    return ManageTilePosition.middle;
  }
}

class ManageAppTile extends ConsumerWidget {
  const ManageAppTile({
    required this.app,
    this.position = ManageTilePosition.middle,
    this.showOnlyUpdate = false,
    this.hasFixedSize = false,
    super.key,
  });

  final ManageAppData app;
  final ManageTilePosition position;
  final bool showOnlyUpdate;
  final bool hasFixedSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ManageTileLayout(
      id: app.id,
      name: app.name,
      iconUrl: app.iconUrl,
      installDate: app.installDate,
      installedSize: app.installedSize,
      position: position,
      hasFixedSize: hasFixedSize,
      showSizeAndDate: !showOnlyUpdate,
      onTap: () => _navigateToDetails(context, app),
      subtitle: Row(
        children: [
          switch (app) {
            final ManageSnapData snap => _SnapSourceDisplay(snap: snap),
            final ManageDebData deb => _DebSourceDisplay(deb: deb),
          },
        ],
      ),
      trailing: Align(
        alignment: Alignment.centerRight,
        child: IntrinsicWidth(
          child: switch (app) {
            final ManageSnapData snap => ManageSnapActions(
                snapName: snap.id,
                showOnlyUpdate: showOnlyUpdate,
              ),
            final ManageDebData deb => ManageDebActions(
                debId: deb.id,
                showOnlyUpdate: showOnlyUpdate,
              ),
          },
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context, ManageAppData app) {
    switch (app) {
      case final ManageSnapData snap:
        StoreNavigator.pushSnap(context, name: snap.id);
      case final ManageDebData deb:
        StoreNavigator.pushDeb(context, id: deb.id);
    }
  }
}

class _ManageTileLayout extends StatelessWidget {
  const _ManageTileLayout({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.subtitle,
    required this.trailing,
    required this.position,
    required this.onTap,
    this.installDate,
    this.installedSize,
    this.hasFixedSize = false,
    this.showSizeAndDate = true,
  });

  final String id;
  final String name;
  final String? iconUrl;
  final Widget subtitle;
  final Widget trailing;
  final ManageTilePosition position;
  final VoidCallback onTap;
  final DateTime? installDate;
  final int? installedSize;
  final bool hasFixedSize;
  final bool showSizeAndDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final border = BorderSide(color: Theme.of(context).colorScheme.outline);
    final dateTimeSinceUpdate = installDate != null
        ? DateTime.now().difference(installDate!)
        : null;
    const radius = Radius.circular(8);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: switch (position) {
          ManageTilePosition.first =>
            const BorderRadius.only(topLeft: radius, topRight: radius),
          ManageTilePosition.middle => BorderRadius.zero,
          ManageTilePosition.last =>
            const BorderRadius.only(bottomLeft: radius, bottomRight: radius),
          ManageTilePosition.single => const BorderRadius.all(radius),
        },
        border: switch (position) {
          ManageTilePosition.first => Border(
              top: border,
              left: border,
              right: border,
              bottom: border,
            ),
          ManageTilePosition.middle => Border(
              left: border,
              right: border,
              bottom: border,
            ),
          ManageTilePosition.last => Border(
              bottom: border,
              left: border,
              right: border,
            ),
          ManageTilePosition.single => Border.fromBorderSide(border),
        },
      ),
      child: ListTile(
        key: ValueKey(id),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Clickable(
          onTap: onTap,
          child: AppIcon(iconUrl: iconUrl, size: 40),
        ),
        title: Row(
          children: [
            Expanded(
              flex: 2,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Clickable(
                  onTap: onTap,
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            ),
            if (showSizeAndDate &&
                ResponsiveLayout.of(context).type !=
                    ResponsiveLayoutType.small) ...[
              Expanded(
                flex: 2,
                child: dateTimeSinceUpdate != null
                    ? Text(
                        dateTimeSinceUpdate
                            .managePageUpdateSinceDateTimeAgo(l10n),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      )
                    : const SizedBox(),
              ),
              Expanded(
                child: installedSize != null
                    ? Text(
                        context.formatByteSize(
                          installedSize!,
                          precision: 0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      )
                    : const SizedBox(),
              ),
              const Spacer(),
            ],
          ],
        ),
        subtitle: Column(
          children: [
            subtitle,
            if (showSizeAndDate &&
                ResponsiveLayout.of(context).type == ResponsiveLayoutType.small)
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: dateTimeSinceUpdate != null
                        ? Text(
                            dateTimeSinceUpdate
                                .managePageUpdateSinceDateTimeAgo(l10n),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : const SizedBox(),
                  ),
                  Expanded(
                    child: installedSize != null
                        ? Text(
                            context.formatByteSize(
                              installedSize!,
                              precision: 0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          )
                        : const SizedBox(),
                  ),
                  const Spacer(),
                ],
              ),
          ],
        ),
        trailing: hasFixedSize
            ? SizedBox(width: 200, child: trailing)
            : IntrinsicWidth(child: trailing),
      ),
    );
  }
}

/// Displays snap channel and version info.
class _SnapSourceDisplay extends StatelessWidget {
  const _SnapSourceDisplay({required this.snap});

  final ManageSnapData snap;

  @override
  Widget build(BuildContext context) {
    // snap.version is the locally installed version
    // snap.updateVersion is the version available for update
    final localVersion = snap.version;
    final updateVersion = snap.updateVersion;

    return Row(
      children: [
        Text(snap.channel),
        const SizedBox(width: 4),
        if (updateVersion != null)
          Text('$localVersion \u2192 $updateVersion')
        else
          Text(localVersion),
      ],
    );
  }
}

/// Displays "Deb" label and version info.
class _DebSourceDisplay extends StatelessWidget {
  const _DebSourceDisplay({required this.deb});

  final ManageDebData deb;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final version = deb.version;
    final updateVersion = deb.updateVersion;

    return Row(
      children: [
        Text(l10n.managePageDebSourceLabel),
        const SizedBox(width: 4),
        const Text('\u00b7'),
        const SizedBox(width: 4),
        if (updateVersion != null)
          Text('$version \u2192 $updateVersion')
        else
          Text(version),
      ],
    );
  }
}
