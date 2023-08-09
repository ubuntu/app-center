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
import 'manage_model.dart';

class ManagePage extends ConsumerWidget {
  const ManagePage({super.key});

  static IconData icon(bool selected) => YaruIcons.app_grid;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).managePageLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manageModel = ref.watch(manageModelProvider);
    final updatesModel = ref.watch(updatesModelProvider);
    return manageModel.state.when(
      data: (_) => _ManageView(
        manageModel: manageModel,
        updatesModel: updatesModel,
      ),
      error: (error, stack) => ErrorWidget(error),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _ManageView extends ConsumerWidget {
  const _ManageView({required this.manageModel, required this.updatesModel});
  final ManageModel manageModel;
  final UpdatesModel updatesModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              Row(
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
                  ButtonBar(
                    children: [
                      if (manageModel.refreshableSnaps.isNotEmpty)
                        PushButton.elevated(
                          onPressed: updatesModel.updateAll,
                          child: Row(
                            children: [
                              const Icon(YaruIcons.download),
                              Text(l10n.managePageUpdateAllLabel),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
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
            const SizedBox(height: 24),
          ]),
          SliverList.builder(
            itemCount: manageModel.nonRefreshableSnaps.length,
            itemBuilder: (context, index) => _ManageSnapTile(
              snap: manageModel.nonRefreshableSnaps.elementAt(index),
              position: index == (manageModel.nonRefreshableSnaps.length - 1)
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
        onTap: () => StoreNavigator.pushDetail(context, snap.name),
        child: SnapIcon(iconUrl: snap.iconUrl, size: 40),
      ),
      title: Row(
        children: [
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Clickable(
                onTap: () => StoreNavigator.pushDetail(context, snap.name),
                child: Text(
                  snap.titleOrName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
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
      ),
      subtitle: Row(
        children: [
          Text(snap.channel),
          const SizedBox(width: 4),
          Text(snap.version),
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
          // TODO: seconday actions
          YaruOptionButton(
            onPressed: () {},
            child: const Icon(YaruIcons.view_more_horizontal),
          )
        ],
      ),
    );
  }
}
