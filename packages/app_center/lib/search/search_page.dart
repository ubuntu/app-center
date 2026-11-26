import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/constants.dart';
import 'package:app_center/error/error.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/search/search.dart';
import 'package:app_center/snapd/multisnap_model.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/store/store.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru/yaru.dart';

// TODO: break down into smaller widgets
class SearchPage extends StatelessWidget {
  const SearchPage({
    super.key,
    this.query,
    String? category,
    this.unifiedResults = false,
  }) : initialCategoryName = category;

  final String? query;
  final String? initialCategoryName;

  /// Whether a query search lists snaps and debs together.
  final bool unifiedResults;

  @override
  Widget build(BuildContext context) {
    final initialCategory = initialCategoryName?.toSnapCategoryEnum();
    final unified =
        unifiedResults && query != null && initialCategoryName == null;
    return ResponsiveLayoutBuilder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: kPagePadding) +
                ResponsiveLayout.paddingOf(context),
            child: unified
                ? _UnifiedHeader(query: query!)
                : _LegacyHeader(query: query, initialCategory: initialCategory),
          ),
          Expanded(
            child: unified
                ? _UnifiedSearchResults(query: query!)
                : _LegacyResults(
                    query: query,
                    initialCategory: initialCategory,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Header of the search page without unified results.
class _LegacyHeader extends StatelessWidget {
  const _LegacyHeader({required this.query, required this.initialCategory});

  final String? query;
  final SnapCategoryEnum? initialCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final initialCategory = this.initialCategory;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (query != null)
          Semantics(
            focused: true,
            header: true,
            child: Text(
              l10n.searchPageTitle(query!),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        if (initialCategory != null)
          Semantics(
            focused: true,
            header: true,
            child: Text(
              initialCategory.localize(l10n),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(l10n.searchPageSortByLabel),
            const SizedBox(width: 8),
            const _SortMenu(),
            if (query != null) ...[
              const SizedBox(width: 24),
              Text(l10n.searchPageFilterByLabel),
              const SizedBox(width: 8),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    return MenuButtonBuilder<PackageFormat>(
                      values: PackageFormat.values,
                      itemBuilder: (context, packageFormat, child) =>
                          Text(packageFormat.localize(l10n)),
                      onSelected: (value) =>
                          ref.read(packageFormatProvider.notifier).state =
                              value,
                      child: Text(
                        ref.watch(packageFormatProvider).localize(l10n),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) =>
                      switch (ref.watch(packageFormatProvider)) {
                        PackageFormat.snap => _CategoryMenu(
                          initialCategory: initialCategory,
                        ),
                        PackageFormat.deb => const SizedBox.shrink(),
                      },
                ),
              ),
            ],
          ],
        ),
        if (initialCategory == SnapCategoryEnum.gameDev ||
            initialCategory == SnapCategoryEnum.gameEmulators ||
            initialCategory == SnapCategoryEnum.gnomeGames ||
            initialCategory == SnapCategoryEnum.kdeGames) ...[
          const SizedBox(height: kPagePadding),
          InstallAll(initialCategory: initialCategory),
        ],
      ],
    );
  }
}

/// Snap or deb results, picked by the package format filter, of the search
/// page without unified results.
class _LegacyResults extends ConsumerWidget {
  const _LegacyResults({required this.query, required this.initialCategory});

  final String? query;
  final SnapCategoryEnum? initialCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageFormat = initialCategory != null
        ? PackageFormat.snap
        : ref.watch(packageFormatProvider);
    return switch (packageFormat) {
      PackageFormat.snap => _SnapSearchResults(
        initialCategory: initialCategory,
        query: query,
      ),
      PackageFormat.deb => _DebSearchResults(query: query),
    };
  }
}

class _UnifiedHeader extends StatelessWidget {
  const _UnifiedHeader({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = Semantics(
      focused: true,
      header: true,
      child: Text(
        l10n.searchPageTitle(query),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
    final filters = Wrap(
      spacing: 24,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.searchPageSortByLabel),
            const SizedBox(width: 8),
            const _SortMenu(),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.searchPageFilterByLabel),
            const SizedBox(width: 8),
            const _CategoryMenu(expanded: false),
          ],
        ),
      ],
    );
    // Filters sit beside the title, or wrap below it when there is no room.
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 24,
        runSpacing: 8,
        children: [title, filters],
      ),
    );
  }
}

class _SortMenu extends ConsumerWidget {
  const _SortMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sortOrder = ref.watch(snapSortOrderProvider);
    return MenuButtonBuilder<SnapSortOrder?>(
      expanded: false,
      values: const [
        null,
        SnapSortOrder.alphabeticalAsc,
        SnapSortOrder.alphabeticalDesc,
        SnapSortOrder.downloadSizeAsc,
        SnapSortOrder.downloadSizeDesc,
      ],
      itemBuilder: (context, sortOrder, child) =>
          Text(sortOrder?.localize(l10n) ?? l10n.snapSortOrderRelevance),
      onSelected: (value) =>
          ref.read(snapSortOrderProvider.notifier).state = value,
      child: Text(sortOrder?.localize(l10n) ?? l10n.snapSortOrderRelevance),
    );
  }
}

class _CategoryMenu extends ConsumerWidget {
  const _CategoryMenu({this.initialCategory, this.expanded = true});

  final SnapCategoryEnum? initialCategory;
  final bool expanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final category = snapCategoryProvider(initialCategory);
    return MenuButtonBuilder<SnapCategoryEnum?>(
      expanded: expanded,
      values:
          <SnapCategoryEnum?>[null] +
          SnapCategoryEnum.values.whereNot((c) => c.hidden).toList(),
      itemBuilder: (context, category, child) =>
          Text(category?.localize(l10n) ?? l10n.snapCategoryAll),
      onSelected: (value) => ref.read(category.notifier).state = value,
      child: Text(ref.watch(category)?.localize(l10n) ?? l10n.snapCategoryAll),
    );
  }
}

class InstallAll extends ConsumerWidget {
  const InstallAll({
    required this.initialCategory,
    super.key,
  });

  final SnapCategoryEnum? initialCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final multiSnapModel = ref.watch(multiSnapModelProvider(initialCategory!));
    return Center(
      child: ElevatedButton(
        onPressed: multiSnapModel.canInstall ? multiSnapModel.installAll : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (multiSnapModel.isInstalling) ...[
              const SizedBox.square(
                dimension: kLoaderHeight,
                child: YaruCircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: kSpacingSmall),
            ],
            Text(
              multiSnapModel.isInstalling
                  ? l10n.snapActionInstallingLabel
                  : l10n.installAll,
            ),
          ],
        ),
      ),
    );
  }
}

// TODO: remove redundancies between `_DebSearchResults` and `SnapSearchResults`
class _DebSearchResults extends ConsumerWidget {
  const _DebSearchResults({
    this.query,
  });

  final String? query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final results = ref.watch(appstreamSearchProvider(query ?? ''));
    return results.when(
      data: (data) => data.isNotEmpty
          ? ResponsiveLayoutScrollView(
              slivers: [
                AppCardGrid.fromDebs(
                  debs: data,
                  onTap: (deb) => StoreNavigator.pushDeb(
                    context,
                    id: deb.id,
                  ),
                ),
              ],
            )
          : Padding(
              padding: ResponsiveLayout.paddingOf(context),
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    l10n.searchPageNoResults(query!),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    l10n.searchPageNoResultsHint,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
      error: (error, stack) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(appstreamSearchProvider(query ?? '')),
      ),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _SnapSearchResults extends ConsumerWidget {
  const _SnapSearchResults({
    this.initialCategory,
    this.query,
  });

  final SnapCategoryEnum? initialCategory;
  final String? query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final category = ref.watch(snapCategoryProvider(initialCategory));
    final results = ref.watch(
      sortedSnapSearchProvider(
        SnapSearchParameters(
          query: query,
          category: category,
        ),
      ),
    );
    return results.when(
      data: (data) => data.isNotEmpty
          ? ResponsiveLayoutScrollView(
              slivers: [
                AppCardGrid.fromSnaps(
                  snaps: data,
                  onTap: (snap) => StoreNavigator.pushSearchSnap(
                    context,
                    name: snap.name,
                    query: query,
                  ),
                ),
              ],
            )
          : Padding(
              padding: ResponsiveLayout.paddingOf(context),
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    category == null
                        ? l10n.searchPageNoResults(query!)
                        : l10n.searchPageNoResultsCategory,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    category == null
                        ? l10n.searchPageNoResultsHint
                        : l10n.searchPageNoResultsCategoryHint,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
      error: (error, stack) => ErrorView(
        error: error,
        onRetry: () {
          ref.invalidate(
            snapSearchProvider(
              SnapSearchParameters(
                query: query,
                category: category,
              ),
            ),
          );
        },
      ),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _UnifiedSearchResults extends ConsumerWidget {
  const _UnifiedSearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final category = ref.watch(snapCategoryProvider(null));
    final sortOrder = ref.watch(snapSortOrderProvider);
    final results = ref.watch(
      unifiedSearchProvider((query: query, category: category)),
    );
    return results.when(
      data: (results) => results.isNotEmpty
          ? ResponsiveLayoutScrollView(
              // A new list starts at the top.
              key: ValueKey((query, category, sortOrder)),
              slivers: [
                AppCardGrid(
                  appCards: [
                    for (final result in sortSearchResults(results, sortOrder))
                      _card(context, result),
                  ],
                ),
              ],
            )
          : Padding(
              padding: ResponsiveLayout.paddingOf(context),
              child: Column(
                children: [
                  const Spacer(),
                  Text(
                    category == null
                        ? l10n.searchPageNoResults(query)
                        : l10n.searchPageNoResultsCategory,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    category == null
                        ? l10n.searchPageNoResultsHint
                        : l10n.searchPageNoResultsCategoryHint,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
      error: (error, stack) => ErrorView(
        error: error,
        onRetry: () {
          ref
            ..invalidate(
              snapSearchProvider(
                SnapSearchParameters(query: query, category: category),
              ),
            )
            ..invalidate(appstreamResultsProvider(query));
        },
      ),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }

  AppCard _card(BuildContext context, UnifiedSearchResult result) {
    void open() =>
        StoreNavigator.pushSearchResult(context, result, query: query);
    return result.fold(
      onSnap: (snap) => AppCard.fromSnap(snap: snap, onTap: open),
      onDeb: (deb) => AppCard.fromDeb(component: deb, onTap: open),
    );
  }
}

extension on PackageFormat {
  String localize(AppLocalizations l10n) {
    return switch (this) {
      PackageFormat.deb => l10n.packageFormatDebLabel,
      PackageFormat.snap => l10n.packageFormatSnapLabel,
    };
  }
}
