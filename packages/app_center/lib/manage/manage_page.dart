import 'package:app_center/constants.dart';
import 'package:app_center/error/error.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/local_snap_providers.dart';
import 'package:app_center/manage/manage_snap_tile.dart';
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
    final filteredLocalSnaps = ref.watch(filteredLocalSnapsProvider);
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    if (updatesModel.hasError || filteredLocalSnaps.hasError) {
      return ErrorView(
        error: updatesModel.error ?? filteredLocalSnaps.error,
        onRetry: () {
          ref.invalidate(updatesModelProvider);
          ref.invalidate(filteredLocalSnapsProvider);
        },
      );
    }

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
                error: (_, __) => [],
                loading: () =>
                    [const Center(child: YaruCircularProgressIndicator())],
              ),
            ],
          ),
          updatesModel.when(
            data: (refreshableSnaps) => SliverList.builder(
              itemCount: refreshableSnaps.length,
              itemBuilder: (context, index) => ManageSnapTile(
                snap: refreshableSnaps.elementAt(index),
                position: determineTilePosition(
                  index: index,
                  length: refreshableSnaps.length,
                ),
                showUpdateButton: true,
              ),
            ),
            error: (error, stack) =>
                const SliverToBoxAdapter(child: SizedBox.shrink()),
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
          filteredLocalSnaps.when(
            data: (data) => SliverList.builder(
              itemCount: data.length,
              itemBuilder: (context, index) => ManageSnapTile(
                snap: data.elementAt(index),
                position:
                    determineTilePosition(index: index, length: data.length),
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
