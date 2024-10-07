import 'package:app_center/constants.dart';
import 'package:app_center/error/error.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/local_snap_providers.dart';
import 'package:app_center/manage/manage_snap_tile.dart';
import 'package:app_center/manage/updates_model.dart';
import 'package:app_center/snapd/currently_installing_model.dart';
import 'package:app_center/snapd/snapd.dart';
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
    final updatesModel = ref.watch(updatesModelProvider);
    final localSnapsModel = ref.watch(filteredLocalSnapsProvider);
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isLoading = updatesModel.isLoading || localSnapsModel.isLoading;
    final currentlyInstalling = ref.watch(currentlyInstallingModelProvider);
    final currentlyInstallingNames = currentlyInstalling.keys.toList();

    if (updatesModel.hasError || localSnapsModel.hasError) {
      return ErrorView(
        error: updatesModel.error ?? localSnapsModel.error,
        onRetry: () {
          ref.invalidate(updatesModelProvider);
          ref.invalidate(filteredLocalSnapsProvider);
        },
      );
    }

    final refreshableSnaps = updatesModel.valueOrNull?.snaps ?? [];
    final hasInternet = updatesModel.valueOrNull?.hasInternet ?? true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kPagePadding),
      child: ResponsiveLayoutScrollView(
        slivers: [
          SliverList.list(
            children: [
              Text(
                l10n.managePageTitle,
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: kMargin),
              Text(
                l10n.managePageDescription,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: kMargin),
              Text(
                l10n.managePageDebUpdatesMessage,
                style: textTheme.titleMedium,
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
              const SizedBox(height: kMarginLarge),
              if (!hasInternet && !isLoading)
                _MinHeightAsProgressIndicator(
                  child: Text(
                    l10n.managePageNoInternet,
                    style: textTheme.titleMedium,
                  ),
                )
              else if (refreshableSnaps.isEmpty && !isLoading)
                _MinHeightAsProgressIndicator(
                  child: Text(
                    l10n.managePageNoUpdatesAvailableDescription,
                    style: textTheme.titleMedium,
                  ),
                ),
            ],
          ),
          updatesModel.when(
            data: (snapListState) {
              // Due to the updates model loading a lot faster than the
              // local filtered snaps we force this list to show the loading
              // state too.
              if (localSnapsModel.isLoading) {
                return const SliverToBoxAdapter(
                  child: Center(child: YaruCircularProgressIndicator()),
                );
              }
              return SliverList.builder(
                itemCount: snapListState.snaps.length,
                itemBuilder: (context, index) => ManageSnapTile(
                  snap: snapListState.snaps.elementAt(index),
                  position: determineTilePosition(
                    index: index,
                    length: snapListState.snaps.length,
                  ),
                  showUpdateButton: true,
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
              itemBuilder: (context, index) => ManageSnapTile(
                snap:
                    currentlyInstalling[currentlyInstallingNames[index]]!.snap,
                position: determineTilePosition(
                  index: index,
                  length: currentlyInstalling.length,
                ),
              ),
            ),
          ],
          SliverList.list(
            children: [
              const SizedBox(height: kSectionSpacing),
              Builder(
                builder: (context) {
                  final compact = ResponsiveLayout.of(context).type ==
                      ResponsiveLayoutType.small;
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 80),
                    child: Flex(
                      direction: compact ? Axis.vertical : Axis.horizontal,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: compact
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        Text(
                          l10n.managePageInstalledAndUpdatedLabel,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox.square(dimension: kSpacing),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 300),
                                  // TODO: refactor - extract common text field decoration from
                                  // here and the `SearchField` widget
                                  child: TextFormField(
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlignVertical: TextAlignVertical.center,
                                    cursorWidth: 1,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          kSearchFieldContentPadding,
                                      prefixIcon: kSearchFieldPrefixIcon,
                                      prefixIconConstraints:
                                          kSearchFieldIconConstraints,
                                      hintText:
                                          l10n.managePageSearchFieldSearchHint,
                                    ),
                                    initialValue:
                                        ref.watch(localSnapFilterProvider),
                                    onChanged: (value) => ref
                                        .read(localSnapFilterProvider.notifier)
                                        .state = value,
                                  ),
                                ),
                              ),
                              const SizedBox(width: kSpacing),
                              Text(l10n.searchPageSortByLabel),
                              const SizedBox(width: kSpacingSmall),
                              // TODO: refactor - create proper widget
                              Consumer(
                                builder: (context, ref, child) {
                                  final sortOrder =
                                      ref.watch(localSnapSortOrderProvider);
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
                                        .read(
                                          localSnapSortOrderProvider.notifier,
                                        )
                                        .state = value,
                                    expanded: false,
                                    child: Text(sortOrder.localize(l10n)),
                                  );
                                },
                              ),
                              const SizedBox(width: kSpacing),
                              Text(l10n.managePageShowSystemSnapsLabel),
                              const SizedBox(width: kSpacingSmall),
                              YaruCheckbox(
                                value: ref.watch(showLocalSystemAppsProvider),
                                onChanged: (value) => ref
                                    .read(showLocalSystemAppsProvider.notifier)
                                    .state = value ?? false,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: kMarginLarge),
            ],
          ),
          localSnapsModel.when(
            data: (snapListState) => SliverList.builder(
              itemCount: snapListState.snaps.length,
              itemBuilder: (context, index) => ManageSnapTile(
                snap: snapListState.snaps.elementAt(index),
                position: determineTilePosition(
                  index: index,
                  length: snapListState.snaps.length,
                ),
                hasFixedSize: true,
              ),
            ),
            error: (_, __) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: YaruCircularProgressIndicator(),
              ),
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
    final localSnapsModel = ref.watch(filteredLocalSnapsProvider);
    final isRefreshingAll =
        ref.watch(currentlyRefreshAllSnapsProvider).isNotEmpty;
    final hasInternet = updatesModel.value?.hasInternet ?? true;
    final isLoading = updatesModel.isLoading || localSnapsModel.isLoading;
    final isSilentlyCheckingUpdates =
        ref.watch(isSilentlyCheckingUpdatesProvider);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        PushButton.outlined(
          onPressed: isRefreshingAll ||
                  updatesModel.hasError ||
                  isLoading ||
                  isSilentlyCheckingUpdates
              ? null
              : ref.read(updatesModelProvider.notifier).silentUpdatesCheck,
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
          onPressed: ref.watch(updatesModelProvider).whenOrNull(
                data: (snapListState) => snapListState.snaps.isNotEmpty &&
                        !isRefreshingAll &&
                        hasInternet
                    ? ref.read(updatesModelProvider.notifier).refreshAll
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
                ref.read(updatesModelProvider.notifier).cancelRefreshAll(),
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
  // ignore: unused_element
  const _SmallLoadingIndicator({this.progress});

  final double? progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: kCircularProgressIndicatorHeight,
      child: YaruCircularProgressIndicator(
        value: progress,
        strokeWidth: 2,
      ),
    );
  }
}
