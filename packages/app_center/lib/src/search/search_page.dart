import 'package:app_center/appstream.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/search.dart';
import 'package:app_center/snapd.dart';
import 'package:app_center/src/snapd/multisnap_model.dart';
import 'package:app_center/store.dart';
import 'package:app_center/widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

// TODO: break down into smaller widgets
class SearchPage extends StatelessWidget {
  const SearchPage({super.key, this.query, String? category})
      : initialCategoryName = category;

  final String? query;
  final String? initialCategoryName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final initialCategory = initialCategoryName?.toSnapCategoryEnum();
    return ResponsiveLayoutBuilder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kPagePadding) +
                ResponsiveLayout.of(context).padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Navigator.of(context).canPop()) const YaruBackButton(),
                if (query != null)
                  Text(
                    l10n.searchPageTitle(query!),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                if (initialCategory != null)
                  Text(
                    initialCategory.localize(l10n),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                const SizedBox(height: 8),
                Row(children: [
                  Text(l10n.searchPageSortByLabel),
                  const SizedBox(width: 8),
                  Consumer(builder: (context, ref, child) {
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
                      itemBuilder: (context, sortOrder, child) => Text(
                        sortOrder?.localize(l10n) ??
                            l10n.snapSortOrderRelevance,
                      ),
                      onSelected: (value) => ref
                          .read(snapSortOrderProvider.notifier)
                          .state = value,
                      child: Text(
                        sortOrder?.localize(l10n) ??
                            l10n.snapSortOrderRelevance,
                      ),
                    );
                  }),
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
                            onSelected: (value) => ref
                                .read(packageFormatProvider.notifier)
                                .state = value,
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
                        builder: (context, ref, child) {
                          return switch (ref.watch(packageFormatProvider)) {
                            PackageFormat.snap =>
                              MenuButtonBuilder<SnapCategoryEnum?>(
                                values: <SnapCategoryEnum?>[null] +
                                    SnapCategoryEnum.values
                                        .whereNot((c) => c.hidden)
                                        .toList(),
                                itemBuilder: (context, category, child) => Text(
                                    category?.localize(l10n) ??
                                        l10n.snapCategoryAll),
                                onSelected: (value) => ref
                                    .read(snapCategoryProvider(initialCategory)
                                        .notifier)
                                    .state = value,
                                child: Text(ref
                                        .watch(snapCategoryProvider(
                                            initialCategory))
                                        ?.localize(l10n) ??
                                    l10n.snapCategoryAll),
                              ),
                            PackageFormat.deb => const SizedBox.shrink(),
                          };
                        },
                      ),
                    ),
                  ],
                ]),
                if (initialCategory == SnapCategoryEnum.gameDev ||
                    initialCategory == SnapCategoryEnum.gameEmulators ||
                    initialCategory == SnapCategoryEnum.gnomeGames ||
                    initialCategory == SnapCategoryEnum.kdeGames) ...[
                  const SizedBox(height: kPagePadding),
                  InstallAll(initialCategory: initialCategory),
                ]
              ],
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final packageFormat = initialCategoryName != null
                    ? PackageFormat.snap
                    : ref.watch(packageFormatProvider);
                return switch (packageFormat) {
                  PackageFormat.snap => _SnapSearchResults(
                      initialCategory: initialCategory,
                      query: query,
                    ),
                  PackageFormat.deb => _DebSearchResults(query: query),
                };
              },
            ),
          ),
        ],
      ),
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
    return Row(
      children: [
        Flexible(
          flex: 3,
          fit: FlexFit.tight,
          child: Container(),
        ),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: ElevatedButton(
            onPressed: multiSnapModel.install,
            child: Text(l10n.installAll),
          ),
        ),
        Flexible(
          flex: 3,
          fit: FlexFit.tight,
          child: Container(),
        ),
      ],
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
              padding: ResponsiveLayout.of(context).padding,
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
      error: (error, stack) => ErrorWidget(error),
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
              padding: ResponsiveLayout.of(context).padding,
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
      error: (error, stack) => ErrorWidget(error),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
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
