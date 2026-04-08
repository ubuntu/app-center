import 'dart:async';

import 'package:app_center/constants.dart';
import 'package:app_center/error/error.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/app_providers.dart';
import 'package:app_center/manage/local_deb_providers.dart';
import 'package:app_center/manage/local_deb_updates_model.dart';
import 'package:app_center/manage/local_snap_providers.dart';
import 'package:app_center/manage/manage_app_data.dart';
import 'package:app_center/manage/manage_app_tile.dart';
import 'package:app_center/manage/snap_updates_model.dart';
import 'package:app_center/snapd/currently_installing_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
    final appUpdatesModel = ref.watch(appUpdatesProvider);
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final currentlyInstalling = ref.watch(currentlyInstallingModelProvider);
    final currentlyInstallingNames = currentlyInstalling.keys.toList();

    if (appUpdatesModel.hasError) {
      return ErrorView(
        error: appUpdatesModel.error,
        onRetry: () {
          ref.invalidate(appUpdatesProvider);
          ref.invalidate(installedAppsProvider);
        },
      );
    }

    final appUpdates = appUpdatesModel.valueOrNull ?? [];
    final isLoading = appUpdatesModel.isLoading;
    final hasInternet = ref.watch(
      snapUpdatesModelProvider
          .select((value) => value.valueOrNull?.hasInternet ?? true),
    );

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
                          appUpdates.length,
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
              else if (appUpdates.isEmpty && !isLoading)
                _MinHeightAsProgressIndicator(
                  child: Text(
                    l10n.managePageNoUpdatesAvailableDescription,
                    style: textTheme.titleMedium,
                  ),
                ),
            ],
          ),
        ),

        appUpdatesModel.when(
          data: (updates) {
            return SliverList.builder(
              itemCount: updates.length,
              itemBuilder: (context, index) => ManageAppTile(
                app: updates.elementAt(index),
                position: determineTilePosition(
                  index: index,
                  length: updates.length,
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
            itemBuilder: (context, index) => ManageAppTile(
              app: ManageAppData.snap(
                snap:
                    currentlyInstalling[currentlyInstallingNames[index]]!.snap,
              ),
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
            Text(
              l10n.managePageInstalledAndUpdatedLabel,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: kSpacing),
            _FilterRow(),
            const SizedBox(height: kMarginLarge),
          ],
        ),

        Consumer(
          builder: (context, ref, child) {
            final installedAppsModel = ref.watch(installedAppsProvider);
            return installedAppsModel.when(
              data: (apps) => SliverList.builder(
                itemCount: apps.length,
                itemBuilder: (context, index) => ManageAppTile(
                  app: apps.elementAt(index),
                  position: determineTilePosition(
                    index: index,
                    length: apps.length,
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
            );
          },
        ),

        // Bottom spacing
        const SliverPadding(
          padding: EdgeInsets.only(bottom: kPagePadding),
        ),
      ],
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final appUpdatesModel = ref.watch(appUpdatesProvider);
    final isRefreshingAll =
        ref.watch(currentlyRefreshAllSnapsProvider).isNotEmpty;
    final isUpdatingAllDebs =
        ref.watch(currentlyUpdatingAllDebsProvider).isNotEmpty;
    final isUpdatingAll = isRefreshingAll || isUpdatingAllDebs;
    final hasInternet = ref.watch(
      snapUpdatesModelProvider
          .select((value) => value.valueOrNull?.hasInternet ?? true),
    );
    final isLoading = appUpdatesModel.isLoading;
    final isSilentlyCheckingSnapUpdates =
        ref.watch(isSilentlyCheckingUpdatesProvider);
    final isSilentlyCheckingDebUpdates =
        ref.watch(isSilentlyCheckingDebUpdatesProvider);
    final isSilentlyCheckingUpdates =
        isSilentlyCheckingSnapUpdates || isSilentlyCheckingDebUpdates;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        PushButton.outlined(
          onPressed: isUpdatingAll ||
                  appUpdatesModel.hasError ||
                  isLoading ||
                  isSilentlyCheckingUpdates
              ? null
              : () {
                  ref
                      .read(snapUpdatesModelProvider.notifier)
                      .silentUpdatesCheck();
                  ref
                      .read(localDebUpdatesModelProvider.notifier)
                      .silentUpdatesCheck();
                },
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
          onPressed: ref.watch(appUpdatesProvider).whenOrNull(
                data: (updates) =>
                    updates.isNotEmpty && !isUpdatingAll && hasInternet
                        ? () {
                            ref
                                .read(snapUpdatesModelProvider.notifier)
                                .refreshAll();
                            ref
                                .read(localDebUpdatesModelProvider.notifier)
                                .updateAll();
                          }
                        : null,
              ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(YaruIcons.download),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  isUpdatingAll
                      ? l10n.snapActionUpdatingLabel
                      : l10n.managePageUpdateAllLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (isUpdatingAll)
          PushButton.outlined(
            onPressed: () {
              ref.read(snapUpdatesModelProvider.notifier).cancelRefreshAll();
              ref.read(localDebUpdatesModelProvider.notifier).cancelAll();
            },
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

class _FilterRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final compact =
        ResponsiveLayout.of(context).type == ResponsiveLayoutType.small;
    final packageType = ref.watch(packageTypeFilterProvider);

    final searchField = _DebouncedSearchField(
      hintText: l10n.managePageSearchFieldSearchHint,
    );

    final packageTypeFilter = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.managePagePackageTypeLabel),
        const SizedBox(width: kSpacingSmall),
        Consumer(
          builder: (context, ref, child) {
            final packageType = ref.watch(packageTypeFilterProvider);
            return IntrinsicWidth(
              child: Stack(
                children: [
                  // Invisible texts to establish fixed width
                  for (final type in PackageTypeFilter.values)
                    Visibility(
                      visible: false,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: MenuButtonBuilder<PackageTypeFilter>(
                        values: const [],
                        itemBuilder: (context, type, child) =>
                            const SizedBox.shrink(),
                        onSelected: (_) {},
                        expanded: false,
                        child: Text(type.localize(l10n)),
                      ),
                    ),
                  // Actual visible dropdown
                  MenuButtonBuilder<PackageTypeFilter>(
                    values: PackageTypeFilter.values,
                    itemBuilder: (context, type, child) =>
                        Text(type.localize(l10n)),
                    onSelected: (value) {
                      ref.read(packageTypeFilterProvider.notifier).state =
                          value;
                      if (value != PackageTypeFilter.snap) {
                        ref.read(showLocalSystemAppsProvider.notifier).state =
                            false;
                      }
                    },
                    expanded: false,
                    child: Text(packageType.localize(l10n)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );

    final showSystemApps = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.managePageShowSystemSnapsLabel),
        const SizedBox(width: kSpacingSmall),
        YaruSwitch(
          value: ref.watch(showLocalSystemAppsProvider),
          onChanged: (value) {
            ref.read(showLocalSystemAppsProvider.notifier).state = value;
          },
        ),
      ],
    );

    final sortBy = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
    );

    final filterGroup = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        packageTypeFilter,
        if (packageType == PackageTypeFilter.snap) ...[
          const SizedBox(width: kSpacing),
          showSystemApps,
        ],
      ],
    );

    final filterAndSort = _FilterSortLayout(
      spacing: kSpacing / 2,
      filter: filterGroup,
      sort: sortBy,
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: double.infinity, child: searchField),
          const SizedBox(height: kSpacing),
          filterAndSort,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 200, child: searchField),
        const SizedBox(width: kSpacing),
        Expanded(child: filterAndSort),
      ],
    );
  }
}

/// Filter left, sort right. When they don't fit, sort wraps to a second line
/// right-aligned.
class _FilterSortLayout extends MultiChildRenderObjectWidget {
  _FilterSortLayout({
    required Widget filter,
    required Widget sort,
    this.spacing = 0,
  }) : super(children: [filter, sort]);

  final double spacing;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderFilterSort(spacing: spacing);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderFilterSort renderObject,
  ) =>
      renderObject.spacing = spacing;
}

class _FilterSortParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderFilterSort extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _FilterSortParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _FilterSortParentData> {
  _RenderFilterSort({required double spacing}) : _spacing = spacing;

  double _spacing;
  set spacing(double v) {
    if (_spacing == v) return;
    _spacing = v;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _FilterSortParentData) {
      child.parentData = _FilterSortParentData();
    }
  }

  @override
  void performLayout() {
    final filter = firstChild!;
    final sort = lastChild!;
    final loose = constraints.loosen();

    filter.layout(loose, parentUsesSize: true);
    sort.layout(loose, parentUsesSize: true);

    final fS = filter.size;
    final sS = sort.size;
    final maxW = constraints.maxWidth;
    final filterParent = filter.parentData! as _FilterSortParentData;
    final sortParent = sort.parentData! as _FilterSortParentData;

    if (fS.width + _spacing + sS.width <= maxW) {
      // Inline: filter at left edge, sort at right edge.
      filterParent.offset = Offset.zero;
      sortParent.offset = Offset(maxW - sS.width, 0);
      size = constraints.constrain(
        Size(maxW, fS.height > sS.height ? fS.height : sS.height),
      );
    } else {
      // Overflow: filter top-left, sort bottom-right.
      filterParent.offset = Offset.zero;
      sortParent.offset = Offset(maxW - sS.width, fS.height + _spacing);
      size = constraints.constrain(
        Size(maxW, fS.height + _spacing + sS.height),
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

class _DebouncedSearchField extends ConsumerStatefulWidget {
  const _DebouncedSearchField({required this.hintText});

  final String hintText;

  @override
  ConsumerState<_DebouncedSearchField> createState() =>
      _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends ConsumerState<_DebouncedSearchField> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      ref.read(localSnapFilterProvider.notifier).state = value;
      ref.read(localDebFilterProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 170),
      child: TextFormField(
        style: Theme.of(context).textTheme.bodyMedium,
        textAlignVertical: TextAlignVertical.center,
        cursorWidth: 1,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: kSearchFieldContentPadding,
          prefixIcon: kSearchFieldPrefixIcon,
          prefixIconConstraints: kSearchFieldIconConstraints,
          hintText: widget.hintText,
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }
}
