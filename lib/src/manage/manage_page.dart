import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/l10n.dart';
import '/layout.dart';
import '/snapd.dart';
import '/store.dart';
import '/widgets.dart';
import 'local_snap_providers.dart';
import 'manage_model.dart';

class ManagePage extends ConsumerWidget {
  const ManagePage({super.key});

  static IconData icon(bool selected) => YaruIcons.app_grid;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).managePageLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manageModel = ref.watch(manageModelProvider);
    return manageModel.state.when(
      data: (_) => _ManageView(manageModel: manageModel),
      error: (error, stack) => ErrorWidget(error),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _ManageView extends ConsumerWidget {
  const _ManageView({required this.manageModel});
  final ManageModel manageModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredLocalSnaps = ref.watch(localSnapsProvider);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kPagePadding),
      child: ResponsiveLayoutScrollView(
        slivers: [
          SliverList.list(
            children: [
              Text(
                l10n.managePageLabel,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                l10n.managePageDescription,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 48),
              Builder(builder: (context) {
                final compact = ResponsiveLayout.of(context).type ==
                    ResponsiveLayoutType.small;
                return Flex(
                  direction: compact ? Axis.vertical : Axis.horizontal,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: compact
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.managePageUpdatesAvailable(
                          manageModel.refreshableSnaps.length),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.w500),
                    ),
                    if (compact) const SizedBox(height: 16),
                    const Flexible(child: _ActionButtons()),
                  ],
                );
              }),
              const SizedBox(height: 24),
              if (manageModel.refreshableSnaps.isEmpty)
                Text(
                  l10n.managePageNoUpdatesAvailableDescription,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
            ],
          ),
          SliverList.builder(
            itemCount: manageModel.refreshableSnaps.length,
            itemBuilder: (context, index) => _ManageSnapTile(
              snap: manageModel.refreshableSnaps.elementAt(index),
              position: index == (manageModel.refreshableSnaps.length - 1)
                  ? index == 0
                      ? ManageTilePosition.single
                      : ManageTilePosition.last
                  : index == 0
                      ? ManageTilePosition.first
                      : ManageTilePosition.middle,
            ),
          ),
          SliverList.list(children: [
            const SizedBox(height: 48),
            Text(
              l10n.managePageInstalledAndUpdatedLabel,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  // TODO: refactor - extract common text field decoration from
                  // here and the `SearchField` widget
                  child: TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(YaruIcons.search, size: 16),
                      hintText: l10n.managePageSearchFieldSearchHint,
                    ),
                    initialValue: ref.watch(localSnapFilterProvider),
                    onChanged: (value) => ref
                        .read(localSnapFilterProvider.notifier)
                        .state = value,
                  ),
                ),
                const SizedBox(width: 16),
                Text(l10n.searchPageSortByLabel),
                const SizedBox(width: 8),
                // TODO: refactor - create proper widget
                Expanded(
                  child: Consumer(builder: (context, ref, child) {
                    final sortOrder = ref.watch(localSnapSortOrderProvider);
                    return MenuButtonBuilder<SnapSortOrder>(
                      values: const [
                        SnapSortOrder.alphabeticalAsc,
                        SnapSortOrder.alphabeticalDesc,
                        SnapSortOrder.installedDateAsc,
                        SnapSortOrder.installedDateDesc,
                        SnapSortOrder.installedSizeAsc,
                        SnapSortOrder.installedSizeDesc,
                      ],
                      itemBuilder: (context, sortOrder, child) =>
                          Text(sortOrder.localize(l10n)),
                      onSelected: (value) => ref
                          .read(localSnapSortOrderProvider.notifier)
                          .state = value,
                      child: Text(sortOrder.localize(l10n)),
                    );
                  }),
                ),
                const SizedBox(width: 16),
                Text(l10n.managePageShowSystemSnapsLabel),
                const SizedBox(width: 8),
                YaruCheckbox(
                  value: ref.watch(showLocalSystemAppsProvider),
                  onChanged: (value) => ref
                      .read(showLocalSystemAppsProvider.notifier)
                      .state = value ?? false,
                )
              ],
            ),
            const SizedBox(height: 24),
          ]),
          SliverList.builder(
            itemCount: filteredLocalSnaps.length,
            itemBuilder: (context, index) => _ManageSnapTile(
              snap: filteredLocalSnaps.elementAt(index),
              position: index == (filteredLocalSnaps.length - 1)
                  ? index == 0
                      ? ManageTilePosition.single
                      : ManageTilePosition.last
                  : index == 0
                      ? ManageTilePosition.first
                      : ManageTilePosition.middle,
            ),
          ),
        ],
      ),
    );
  }
}

// TODO: refactor/generalize - similar to `_SnapActionButtons`
class _ActionButtons extends ConsumerWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final updatesModel = ref.watch(updatesModelProvider);
    final (label, icon) = updatesModel.state.when(
      data: (_) => (l10n.managePageCheckForUpdates, const Icon(YaruIcons.sync)),
      loading: () => (
        l10n.managePageCheckingForUpdates,
        const SizedBox(
          height: 24,
          child: YaruCircularProgressIndicator(
            strokeWidth: 4,
          ),
        ),
      ),
      error: (_, __) => ('', const SizedBox.shrink()),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PushButton.outlined(
          onPressed:
              updatesModel.activeChangeId != null ? null : updatesModel.refresh,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        PushButton.elevated(
          onPressed: updatesModel.refreshableSnapNames.isNotEmpty &&
                  !updatesModel.state.isLoading
              ? ref.read(updatesModelProvider).updateAll
              : null,
          child: updatesModel.activeChangeId != null
              ? Consumer(
                  builder: (context, ref, child) {
                    final change = ref
                        .watch(changeProvider(updatesModel.activeChangeId))
                        .whenOrNull(data: (data) => data);
                    return Row(
                      children: [
                        SizedBox.square(
                          dimension: 16,
                          child: YaruCircularProgressIndicator(
                            value: change?.progress,
                            strokeWidth: 2,
                          ),
                        ),
                        if (change != null) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              change.localize(l10n) ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]
                      ],
                    );
                  },
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(YaruIcons.download),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n.managePageUpdateAllLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

enum ManageTilePosition { first, middle, last, single }

class _ManageSnapTile extends ConsumerWidget {
  const _ManageSnapTile({
    required this.snap,
    this.position = ManageTilePosition.middle,
  });

  final Snap snap;
  final ManageTilePosition position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapLauncher = ref.watch(launchProvider(snap));
    final l10n = AppLocalizations.of(context);
    final border = BorderSide(color: Theme.of(context).colorScheme.outline);
    final daysSinceUpdate = snap.installDate != null
        ? DateTime.now().difference(snap.installDate!).inDays
        : null;

    return ListTile(
      key: ValueKey(snap.id),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: switch (position) {
        ManageTilePosition.first => RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            side: border,
          ),
        ManageTilePosition.middle => RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.zero),
            side: border,
          ),
        ManageTilePosition.last => RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            side: border,
          ),
        ManageTilePosition.single => RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            side: border,
          ),
      },
      leading: Clickable(
        onTap: () => StoreNavigator.pushDetail(context, name: snap.name),
        child: AppIcon(iconUrl: snap.iconUrl, size: 40),
      ),
      title: Row(
        children: [
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Clickable(
                onTap: () =>
                    StoreNavigator.pushDetail(context, name: snap.name),
                child: Text(
                  snap.titleOrName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          if (ResponsiveLayout.of(context).type !=
              ResponsiveLayoutType.small) ...[
            Expanded(
              flex: 2,
              child: daysSinceUpdate != null
                  ? Text(
                      l10n.managePageUpdatedDaysAgo(daysSinceUpdate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : const SizedBox(),
            ),
            Expanded(
              child: snap.installedSize != null
                  ? Text(
                      context.formatByteSize(
                        snap.installedSize!,
                        precision: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : const SizedBox(),
            ),
          ],
        ],
      ),
      subtitle: Column(
        children: [
          Row(
            children: [
              Text(snap.channel),
              const SizedBox(width: 4),
              Text(snap.version),
            ],
          ),
          if (ResponsiveLayout.of(context).type == ResponsiveLayoutType.small)
            Row(
              children: [
                Expanded(
                  child: daysSinceUpdate != null
                      ? Text(
                          l10n.managePageUpdatedDaysAgo(daysSinceUpdate),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : const SizedBox(),
                ),
                Expanded(
                  child: snap.installedSize != null
                      ? Text(
                          context.formatByteSize(
                            snap.installedSize!,
                            precision: 0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : const SizedBox(),
                ),
              ],
            )
        ],
      ),
      trailing: ButtonBar(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            visible: snapLauncher.isLaunchable,
            child: OutlinedButton(
              onPressed: snapLauncher.open,
              child: Text(l10n.snapActionOpenLabel),
            ),
          ),
          MenuAnchor(
            menuChildren: [
              MenuItemButton(
                onPressed: () =>
                    StoreNavigator.pushDetail(context, name: snap.name),
                child: Text(
                  l10n.managePageShowDetailsLabel,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            ],
            builder: (context, controller, child) => YaruOptionButton(
              onPressed: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: const Icon(YaruIcons.view_more_horizontal),
            ),
          )
        ],
      ),
    );
  }
}
