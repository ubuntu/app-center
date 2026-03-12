import 'package:app_center/constants.dart';
import 'package:app_center/error/error.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/combined_providers.dart';
import 'package:app_center/manage/local_deb_providers.dart';
import 'package:app_center/manage/manage_app_data.dart';
import 'package:app_center/manage/manage_app_tile.dart';
import 'package:app_center/manage/manage_filters.dart';
import 'package:app_center/manage/snap_updates_provider.dart';
import 'package:app_center/snapd/currently_installing_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru/yaru.dart';

class ManagePage extends ConsumerWidget {
  const ManagePage({super.key});

  static IconData icon(bool selected) => YaruIcons.app_grid;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).managePageLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final combinedUpdates = ref.watch(combinedUpdatesProvider);
    final combinedInstalled = ref.watch(combinedInstalledProvider);
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isLoading = combinedUpdates.isLoading || combinedInstalled.isLoading;
    final currentlyInstalling = ref.watch(currentlyInstallingModelProvider);
    final currentlyInstallingNames = currentlyInstalling.keys.toList();

    if (combinedUpdates.hasError || combinedInstalled.hasError) {
      return ErrorView(
        error: combinedUpdates.error ?? combinedInstalled.error,
        onRetry: () {
          ref.invalidate(combinedUpdatesProvider);
          ref.invalidate(combinedInstalledProvider);
          ref.invalidate(installedDebsProvider);
        },
      );
    }

    final updates = combinedUpdates.valueOrNull ?? [];
    final hasInternet = ref.watch(combinedHasInternetProvider);

    return ResponsiveLayoutScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: kPagePadding),
          sliver: SliverList.list(
            children: [
              Center(
                child: Semantics(
                  header: true,
                  focused: true,
                  child: Text(
                    l10n.managePageLabel,
                    style: textTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              _SelfUpdateInfoBox(),
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
                          updates.length,
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
              const SizedBox(height: kMarginLarge),
              if (!hasInternet && !isLoading)
                _MinHeightAsProgressIndicator(
                  child: Text(
                    l10n.managePageNoInternet,
                    style: textTheme.titleMedium,
                  ),
                )
              else if (updates.isEmpty && !isLoading)
                _MinHeightAsProgressIndicator(
                  child: Text(
                    l10n.managePageNoUpdatesAvailableDescription,
                    style: textTheme.titleMedium,
                  ),
                ),
            ],
          ),
        ),

        combinedUpdates.when(
          data: (updatesList) {
            // Due to the updates model loading a lot faster than the
            // local filtered list we force this list to show the loading
            // state too.
            if (combinedInstalled.isLoading) {
              return const SliverToBoxAdapter(
                child: Center(child: YaruCircularProgressIndicator()),
              );
            }
            return SliverList.builder(
              itemCount: updatesList.length,
              itemBuilder: (context, index) => ManageAppTile(
                app: updatesList[index],
                position: determineTilePosition(
                  index: index,
                  length: updatesList.length,
                ),
                showOnlyUpdate: true,
              ),
            );
          },
          error: (error, stack) =>
              const SliverToBoxAdapter(child: SizedBox.shrink()),
          loading: () => const SliverToBoxAdapter(
            child: Center(child: YaruCircularProgressIndicator()),
          ),
        ),

        if (currentlyInstalling.isNotEmpty) ...[
          SliverList.list(
            children: [
              const SizedBox(height: kSectionSpacing),
              Text(
                l10n.managePageInstallingLabel(1),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: kMarginLarge),
            ],
          ),
          SliverList.builder(
            itemCount: currentlyInstalling.length,
            itemBuilder: (context, index) {
              final snapData =
                  currentlyInstalling[currentlyInstallingNames[index]]!;
              return ManageAppTile(
                app: ManageSnapData(snap: snapData.snap),
                position: determineTilePosition(
                  index: index,
                  length: currentlyInstalling.length,
                ),
              );
            },
          ),
        ],

        SliverList.list(
          children: [
            const SizedBox(height: kSectionSpacing),
            Text(
              l10n.managePageInstalledAndUpdatedLabel,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: kSpacing),
            Row(
              children: [
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: TextFormField(
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlignVertical: TextAlignVertical.center,
                      cursorWidth: 1,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: kSearchFieldContentPadding,
                        prefixIcon: kSearchFieldPrefixIcon,
                        prefixIconConstraints: kSearchFieldIconConstraints,
                        hintText: l10n.managePageSearchFieldSearchHint,
                      ),
                      initialValue: ref.watch(appFilterProvider),
                      onChanged: (value) =>
                          ref.read(appFilterProvider.notifier).state = value,
                    ),
                  ),
                ),
                const SizedBox(width: kSpacing),
                Text(l10n.managePagePackageTypeLabel),
                const SizedBox(width: kSpacingSmall),
                Consumer(
                  builder: (context, ref, child) {
                    final packageTypeFilter =
                        ref.watch(packageTypeFilterProvider);
                    return MenuButtonBuilder<PackageTypeFilter>(
                      values: PackageTypeFilter.values,
                      itemBuilder: (context, filter, child) =>
                          Text(filter.localize(l10n)),
                      onSelected: (value) => ref
                          .read(packageTypeFilterProvider.notifier)
                          .state = value,
                      expanded: false,
                      child: Text(packageTypeFilter.localize(l10n)),
                    );
                  },
                ),
                const SizedBox(width: kSpacing),
                Text(l10n.managePageShowSystemSnapsLabel),
                const SizedBox(width: kSpacingSmall),
                YaruCheckbox(
                  value: ref.watch(showSystemAppsProvider),
                  onChanged: (value) => ref
                      .read(showSystemAppsProvider.notifier)
                      .state = value ?? false,
                ),
                const Spacer(),
                Text(l10n.searchPageSortByLabel),
                const SizedBox(width: kSpacingSmall),
                Consumer(
                  builder: (context, ref, child) {
                    final sortOrder = ref.watch(appSortOrderProvider);
                    return MenuButtonBuilder<AppSortOrder>(
                      values: const [
                        AppSortOrder.alphabeticalAsc,
                        AppSortOrder.alphabeticalDesc,
                        AppSortOrder.installedDateAsc,
                        AppSortOrder.installedDateDesc,
                        AppSortOrder.installedSizeAsc,
                        AppSortOrder.installedSizeDesc,
                      ],
                      itemBuilder: (context, sortOrder, child) =>
                          Text(sortOrder.localize(l10n)),
                      onSelected: (value) =>
                          ref.read(appSortOrderProvider.notifier).state = value,
                      expanded: false,
                      child: Text(sortOrder.localize(l10n)),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: kMarginLarge),
          ],
        ),

        combinedInstalled.when(
          data: (installedList) => SliverList.builder(
            itemCount: installedList.length,
            itemBuilder: (context, index) => ManageAppTile(
              app: installedList[index],
              position: determineTilePosition(
                index: index,
                length: installedList.length,
              ),
              hasFixedSize: true,
            ),
          ),
          error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          loading: () => const SliverToBoxAdapter(
            child: Center(
              child: YaruCircularProgressIndicator(),
            ),
          ),
        ),

        // Bottom spacing
        const SliverPadding(
          padding: EdgeInsets.only(bottom: kPagePadding),
        ),
      ],
    );
  }
}

// TODO: refactor/generalize - similar to `_SnapActionButtons`
class _ActionButtons extends ConsumerWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final combinedUpdates = ref.watch(combinedUpdatesProvider);
    final combinedInstalled = ref.watch(combinedInstalledProvider);
    final isRefreshingAll =
        ref.watch(currentlyRefreshAllSnapsProvider).isNotEmpty;
    final hasInternet = ref.watch(combinedHasInternetProvider);
    final isLoading = combinedUpdates.isLoading || combinedInstalled.isLoading;
    final isSilentlyCheckingUpdates =
        ref.watch(isSilentlyCheckingUpdatesProvider);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        PushButton.outlined(
          onPressed: isRefreshingAll ||
                  combinedUpdates.hasError ||
                  isLoading ||
                  isSilentlyCheckingUpdates
              ? null
              : ref.read(snapUpdatesProvider.notifier).silentUpdatesCheck,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isSilentlyCheckingUpdates
                  ? const _SmallLoadingIndicator()
                  : const Icon(YaruIcons.sync),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l10n.managePageCheckForUpdates,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        PushButton.elevated(
          onPressed: combinedUpdates.whenOrNull(
            data: (updates) =>
                updates.isNotEmpty && !isRefreshingAll && hasInternet
                    ? ref.read(combinedUpdatesProvider.notifier).refreshAll
                    : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(YaruIcons.download),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  isRefreshingAll
                      ? l10n.snapActionUpdatingLabel
                      : l10n.managePageUpdateAllLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (isRefreshingAll)
          PushButton.outlined(
            onPressed: () =>
                ref.read(combinedUpdatesProvider.notifier).cancelRefreshAll(),
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

class _SelfUpdateInfoBox extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final refreshInhibitModel = ref.watch(
      refreshInhibitSnapsProvider.select(
        (value) => value.whenData(
          (data) => data.firstWhere((s) => s.name == kSnapName),
        ),
      ),
    );
    final proceedTime =
        refreshInhibitModel.valueOrNull?.refreshInhibit?.proceedTime;

    if (proceedTime == null) {
      return const SizedBox(height: kSectionSpacing);
    }

    final buttonStyle = OutlinedButtonTheme.of(context).style?.copyWith(
          backgroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.surface,
          ),
        );

    return Padding(
      padding: const EdgeInsets.only(top: 34, bottom: 34),
      child: YaruInfoBox(
        title: Text(l10n.managePageOwnUpdateAvailable),
        subtitle: Padding(
          padding: const EdgeInsets.only(right: kMarginLarge),
          child: Text(l10n.managePageOwnUpdateDescription),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PushButton.outlined(
              style: buttonStyle,
              onPressed: () => YaruWindow.of(context).close(),
              child: Text(
                l10n.managePageOwnUpdateQuitButton,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        yaruInfoType: YaruInfoType.information,
        isThreeLine: true,
      ),
    );
  }
}

class _MinHeightAsProgressIndicator extends StatelessWidget {
  const _MinHeightAsProgressIndicator({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Visibility(
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: YaruCircularProgressIndicator(),
        ),
        child,
      ],
    );
  }
}

class _SmallLoadingIndicator extends StatelessWidget {
  // ignore: unused_element_parameter
  const _SmallLoadingIndicator({this.progress});

  final double? progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: kLoaderHeight,
      child: YaruCircularProgressIndicator(
        value: progress,
        strokeWidth: 2,
      ),
    );
  }
}
