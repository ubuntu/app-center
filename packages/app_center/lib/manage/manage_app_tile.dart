import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/local_deb_providers.dart';
import 'package:app_center/manage/manage_app_actions.dart';
import 'package:app_center/manage/manage_app_data.dart';
import 'package:app_center/manage/manage_l10n.dart';
import 'package:app_center/store/store.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru/yaru.dart';

/// Position of a tile within a grouped list, used to apply the correct
/// border radius (rounded top, bottom, both, or none).
enum ManageTilePosition { first, middle, last, single }

/// A list tile for displaying an installed app (snap or deb) on the manage page.
///
/// Shows the app icon, name, install date, size, source/version info, and
/// action buttons. Adapts its layout for small screens by moving date and size
/// into the subtitle row.
///
/// [showOnlyUpdate] controls whether the tile shows update-only actions (for
/// the updates section) or full actions like open/remove (for the installed
/// section). [hasFixedSize] gives the trailing action buttons a fixed width,
/// used when tiles appear in the "currently installing" section.
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
    final l10n = AppLocalizations.of(context);
    final border = BorderSide(color: Theme.of(context).colorScheme.outline);
    final dateTimeSinceUpdate = app.installDate != null
        ? DateTime.now().difference(app.installDate!)
        : null;
    const radius = Radius.circular(8);
    // Hide size for debs in the updates section
    final shouldShowSize =
        app.installedSize != null && !(showOnlyUpdate && app is ManageDebData);
    final actionButtons = Align(
      alignment: Alignment.centerRight,
      child: IntrinsicWidth(
        child: ManageAppActions(
          app: app,
          showOnlyUpdate: showOnlyUpdate,
        ),
      ),
    );

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
      child: YaruListTile(
        key: ValueKey(app.id),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Clickable(
          onTap: () => _navigateToApp(context),
          child: switch (app) {
            ManageDebData(debInfo: final debInfo)
                when debInfo.component != null =>
              DebAppIcon(component: debInfo.component!, size: 40),
            _ => AppIcon(iconUrl: app.iconUrl, size: 40),
          },
        ),
        title: Row(
          children: [
            Expanded(
              flex: 2,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Clickable(
                  onTap: () => _navigateToApp(context),
                  child: Text(
                    app.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            ),
            if (ResponsiveLayout.of(context).type !=
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
                child: shouldShowSize
                    ? Text(
                        context.formatByteSize(
                          app.installedSize!,
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
            Row(
              children: [
                _SourceDisplay(app: app),
              ],
            ),
            if (ResponsiveLayout.of(context).type == ResponsiveLayoutType.small)
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
                    child: shouldShowSize
                        ? Text(
                            context.formatByteSize(
                              app.installedSize!,
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
            ? SizedBox(width: 220, child: actionButtons)
            : IntrinsicWidth(child: actionButtons),
      ),
    );
  }

  /// Navigates to the snap detail page or deb detail page when the icon or
  /// name is tapped.
  void _navigateToApp(BuildContext context) {
    app.map(
      snap: (snapData) =>
          StoreNavigator.pushSnap(context, name: snapData.snap.name),
      localDeb: (debData) =>
          StoreNavigator.pushDeb(context, id: debData.debInfo.id),
    );
  }
}

/// Returns the [ManageTilePosition] for a tile at [index] in a list of
/// [length], so the first and last tiles get rounded corners.
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

/// Displays the package source info: channel + version for snaps, or just
/// version for debs. Shows "current → update" when an update is available.
class _SourceDisplay extends StatelessWidget {
  const _SourceDisplay({required this.app});

  final ManageAppData app;

  @override
  Widget build(BuildContext context) {
    return app.map(
      snap: (snapData) =>
          _buildSnapSource(snapData.snap, snapData.updateVersion),
      localDeb: (debData) => _buildDebSource(debData.debInfo),
    );
  }

  Widget _buildSnapSource(Snap snap, String? updateVersion) {
    final version = snap.version;
    final versionText =
        updateVersion != null ? '$version → $updateVersion' : version;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(snap.channel),
        const SizedBox(width: 4),
        Text(versionText),
      ],
    );
  }

  Widget _buildDebSource(LocalDebInfo debInfo) {
    final version = debInfo.packageInfo.packageId.version;
    final updateVersion = debInfo.updateVersion;
    final versionText =
        updateVersion != null ? '$version → $updateVersion' : version;

    return Text(versionText);
  }
}
