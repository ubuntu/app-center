import 'package:app_center/constants.dart';
import 'package:app_center/error/error.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/local_snap_providers.dart';
import 'package:app_center/manage/manage_l10n.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/store/store.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru/yaru.dart';

class ManagePage extends ConsumerWidget {
  const ManagePage({super.key});

  static IconData icon(bool selected) => YaruIcons.app_grid;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).managePageLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatesModel = ref.watch(updatesModelProvider);
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kPagePadding),
      child: ResponsiveLayoutScrollView(
        slivers: [
          SliverList.list(
            children: [
              Text(
                l10n.managePageLabel,
                style: textTheme.headlineSmall,
              ),
              Text(
                l10n.managePageDescription,
                style: textTheme.titleMedium,
              ),
              Text(
                l10n.managePageDebUpdatesMessage,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 48),
              ...updatesModel.when(
                data: (refreshableSnaps) {
                  return [
                    Builder(
                      builder: (context) {
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
                                refreshableSnaps.length,
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.w500),
                            ),
                            if (compact) const SizedBox(height: 16),
                            const Flexible(child: _ActionButtons()),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    if (refreshableSnaps.isEmpty)
                      Text(
                        l10n.managePageNoUpdatesAvailableDescription,
                        style: textTheme.titleMedium,
                      ),
                  ];
                },
                error: (error, stack) => [ErrorView(error: error)],
                loading: () =>
                    [const Center(child: YaruCircularProgressIndicator())],
              ),
            ],
          ),
          updatesModel.when(
            data: (refreshableSnaps) => SliverList.builder(
              itemCount: refreshableSnaps.length,
              itemBuilder: (context, index) => _ManageSnapTile(
                snap: refreshableSnaps.elementAt(index),
                position: determinePosition(
                  index: index,
                  length: refreshableSnaps.length,
                ),
                showUpdateButton: true,
              ),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: ErrorView(error: error),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Center(child: YaruCircularProgressIndicator()),
            ),
          ),
          SliverList.list(
            children: [
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
                      style: Theme.of(context).textTheme.bodyMedium,
                      strutStyle: kSearchFieldStrutStyle,
                      textAlignVertical: TextAlignVertical.center,
                      cursorWidth: 1,
                      decoration: InputDecoration(
                        prefixIcon: kSearchFieldPrefixIcon,
                        prefixIconConstraints: kSearchFieldIconConstraints,
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
                    child: Consumer(
                      builder: (context, ref, child) {
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
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(l10n.managePageShowSystemSnapsLabel),
                  const SizedBox(width: 8),
                  YaruCheckbox(
                    value: ref.watch(showLocalSystemAppsProvider),
                    onChanged: (value) => ref
                        .read(showLocalSystemAppsProvider.notifier)
                        .state = value ?? false,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
          Consumer(
            builder: (context, ref, _) {
              final filteredLocalSnaps = ref.watch(filteredLocalSnapsProvider);
              return filteredLocalSnaps.when(
                data: (data) => SliverList.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) => _ManageSnapTile(
                    snap: data.elementAt(index),
                    position:
                        determinePosition(index: index, length: data.length),
                  ),
                ),
                error: (error, stack) => SliverToBoxAdapter(
                  child: ErrorWidget(error),
                ),
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: YaruCircularProgressIndicator(),
                  ),
                ),
              );
            },
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
    final updateChangeId = ref.watch(updateChangeIdProvider);

    final (label, icon) = updatesModel.when(
      data: (_) => (l10n.managePageCheckForUpdates, const Icon(YaruIcons.sync)),
      loading: () => (
        l10n.managePageCheckingForUpdates,
        const SizedBox(
          height: kCircularProgressIndicatorHeight,
          child: YaruCircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
      error: (_, __) =>
          (l10n.managePageCheckForUpdates, const Icon(YaruIcons.sync)),
    );

    final updatesInProgress = !updatesModel.isLoading && updateChangeId != null;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        PushButton.outlined(
          onPressed: updatesInProgress || updatesModel.hasError
              ? null
              : () => ref.refresh(updatesModelProvider),
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
        PushButton.elevated(
          onPressed: ref.watch(updatesModelProvider).whenOrNull(
                data: (updates) => updates.isNotEmpty && updateChangeId == null
                    ? ref.read(updatesModelProvider.notifier).updateAll
                    : null,
              ),
          child: updateChangeId != null
              ? Consumer(
                  builder: (context, ref, child) {
                    final change = ref.watch(
                      activeChangeProvider(updateChangeId),
                    );
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox.square(
                          dimension: kCircularProgressIndicatorHeight,
                          child: YaruCircularProgressIndicator(
                            value: change?.progress,
                            strokeWidth: 2,
                          ),
                        ),
                        if (change != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            change.localize(l10n) ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
        if (updatesInProgress)
          PushButton.outlined(
            onPressed: () => ref
                .read(updatesModelProvider.notifier)
                .cancelChange(updateChangeId),
            child: Text(
              l10n.snapActionCancelLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

enum ManageTilePosition { first, middle, last, single }

class _ManageSnapTile extends StatelessWidget {
  const _ManageSnapTile({
    required this.snap,
    this.position = ManageTilePosition.middle,
    this.showUpdateButton = false,
  });

  final Snap snap;
  final ManageTilePosition position;
  final bool showUpdateButton;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final border = BorderSide(color: Theme.of(context).colorScheme.outline);
    final dateTimeSinceUpdate = snap.installDate != null
        ? DateTime.now().difference(snap.installDate!)
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
        key: ValueKey(snap.id),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Clickable(
          onTap: () => StoreNavigator.pushSnap(context, name: snap.name),
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
                      StoreNavigator.pushSnap(context, name: snap.name),
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
              ),
          ],
        ),
        trailing: showUpdateButton
            ? _ButtonBarForUpdate(snap)
            : _ButtonBarForOpen(snap),
      ),
    );
  }
}

ManageTilePosition determinePosition({
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

class _ButtonBarForUpdate extends ConsumerWidget {
  const _ButtonBarForUpdate(this.snap);

  final Snap snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snapLauncher = ref.watch(launchProvider(snap));
    final snapModel = ref.watch(snapModelProvider(snap.name));
    final activeChangeId = snapModel.value?.activeChangeId;
    final change = activeChangeId != null
        ? ref.watch(activeChangeProvider(activeChangeId))
        : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton(
          onPressed: activeChangeId != null || !snapModel.hasValue
              ? null
              : ref.read(snapModelProvider(snap.name).notifier).refresh,
          child: snapModel.value?.activeChangeId != null
              ? Row(
                  children: [
                    SizedBox.square(
                      dimension: kCircularProgressIndicatorHeight,
                      child: YaruCircularProgressIndicator(
                        value: change?.progress,
                        strokeWidth: 2,
                      ),
                    ),
                    if (change != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        change.localize(l10n) ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(YaruIcons.download),
                    const SizedBox(width: 8),
                    Text(
                      l10n.snapActionUpdateLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
        const SizedBox(width: 8),
        MenuAnchor(
          menuChildren: [
            Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: snapLauncher.isLaunchable,
              child: MenuItemButton(
                onPressed: snapLauncher.open,
                child: Text(l10n.snapActionOpenLabel),
              ),
            ),
            MenuItemButton(
              onPressed: () =>
                  StoreNavigator.pushSnap(context, name: snap.name),
              child: Text(
                l10n.managePageShowDetailsLabel,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
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
        ),
      ],
    );
  }
}

class _ButtonBarForOpen extends ConsumerWidget {
  const _ButtonBarForOpen(this.snap);

  final Snap snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapLauncher = ref.watch(launchProvider(snap));
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility(
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          visible: snapLauncher.isLaunchable,
          child: OutlinedButton(
            onPressed: snapLauncher.open,
            child: Text(
              l10n.snapActionOpenLabel,
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        MenuAnchor(
          menuChildren: [
            MenuItemButton(
              onPressed: () =>
                  StoreNavigator.pushSnap(context, name: snap.name),
              child: Text(
                l10n.managePageShowDetailsLabel,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
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
        ),
      ],
    );
  }
}
