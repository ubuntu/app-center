import 'dart:async';

import 'package:app_center/constants.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/snapd.dart';
import 'package:app_center/src/manage/local_snap_providers.dart';
import 'package:app_center/src/manage/manage_model.dart';
import 'package:app_center/store.dart';
import 'package:app_center/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class ManagePage extends ConsumerStatefulWidget {
  const ManagePage({super.key});

  static IconData icon(bool selected) => YaruIcons.app_grid;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).managePageLabel;

  @override
  ConsumerState<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends ConsumerState<ManagePage> {
  StreamSubscription<SnapdException>? _errorSubscription;

  @override
  void initState() {
    super.initState();

    _errorSubscription =
        ref.read(updatesModelProvider).errorStream.listen(showError);
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    _errorSubscription = null;
    super.dispose();
  }

  Future<void> showError(SnapdException e) => showErrorDialog(
        context: context,
        title: e.kind ?? 'Unknown Snapd Exception',
        message: e.message,
      );

  @override
  Widget build(BuildContext context) {
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
              showUpdateButton: true,
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
          height: kCircularProgressIndicatorHeight,
          child: YaruCircularProgressIndicator(
            strokeWidth: 4,
          ),
        ),
      ),
      error: (_, __) => ('', const SizedBox.shrink()),
    );

    final updatesInprogress = updatesModel.refreshableSnapNames.isNotEmpty &&
        !updatesModel.state.isLoading &&
        updatesModel.activeChangeId != null;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
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
        PushButton.elevated(
          onPressed: updatesModel.refreshableSnapNames.isNotEmpty &&
                  !updatesModel.state.isLoading &&
                  updatesModel.activeChangeId == null
              ? ref.read(updatesModelProvider).updateAll
              : null,
          child: updatesModel.activeChangeId != null
              ? Consumer(
                  builder: (context, ref, child) {
                    final change = ref
                        .watch(changeProvider(updatesModel.activeChangeId))
                        .whenOrNull(data: (data) => data);
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
        if (updatesInprogress)
          PushButton.outlined(
            onPressed: () => ref
                .read(updatesModelProvider)
                .cancelChange(updatesModel.activeChangeId!),
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

class _ManageSnapTile extends ConsumerWidget {
  const _ManageSnapTile({
    required this.snap,
    this.position = ManageTilePosition.middle,
    this.showUpdateButton = false,
  });

  final Snap snap;
  final ManageTilePosition position;
  final bool showUpdateButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapLauncher = ref.watch(launchProvider(snap));
    final l10n = AppLocalizations.of(context);
    final border = BorderSide(color: Theme.of(context).colorScheme.outline);
    final daysSinceUpdate = snap.installDate != null
        ? DateTime.now().difference(snap.installDate!).inDays
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
          ManageTilePosition.single => BorderRadius.zero,
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
          ManageTilePosition.single =>
            const Border.fromBorderSide(BorderSide.none),
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
        trailing: showUpdateButton
            ? buildButtonBarForUpdate(ref, l10n, snapLauncher, context)
            : buildButtonBarForOpen(ref, l10n, snapLauncher, context),
      ),
    );
  }

  ButtonBar buildButtonBarForUpdate(WidgetRef ref, AppLocalizations l10n,
      SnapLauncher snapLauncher, BuildContext context) {
    return ButtonBar(
      mainAxisSize: MainAxisSize.min,
      children: [
        Consumer(
          builder: (context, ref, child) {
            final snapModel = ref.watch(snapModelProvider(snap.name));
            final updatesModel = ref.watch(updatesModelProvider);

            return PushButton.outlined(
              onPressed: updatesModel.activeChangeId != null
                  ? null
                  : () {
                      ref.read(snapModelProvider(snap.name)).refresh();
                    },
              child: snapModel.activeChangeId != null
                  ? Consumer(
                      builder: (context, ref, child) {
                        final change = ref
                            .watch(changeProvider(snapModel.activeChangeId))
                            .whenOrNull(data: (data) => data);
                        return Row(
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
                            l10n.snapActionUpdateLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
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
    );
  }

  ButtonBar buildButtonBarForOpen(WidgetRef ref, AppLocalizations l10n,
      SnapLauncher snapLauncher, BuildContext context) {
    return ButtonBar(
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
                  StoreNavigator.pushSnap(context, name: snap.name),
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
    );
  }
}
