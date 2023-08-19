import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/l10n.dart';
import '/layout.dart';
import '/snapd.dart';
import '/store.dart';
import '/widgets.dart';
import 'search_provider.dart';

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
                  Expanded(
                    child: Consumer(builder: (context, ref, child) {
                      final sortOrder = ref.watch(sortOrderProvider);
                      return MenuButtonBuilder<SnapSortOrder?>(
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
                        onSelected: (value) =>
                            ref.read(sortOrderProvider.notifier).state = value,
                        child: Text(
                          sortOrder?.localize(l10n) ??
                              l10n.snapSortOrderRelevance,
                        ),
                      );
                    }),
                  ),
                  if (query != null) ...[
                    const SizedBox(width: 24),
                    Text(l10n.searchPageFilterByLabel),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          return MenuButtonBuilder<SnapCategoryEnum?>(
                            values: <SnapCategoryEnum?>[null] +
                                SnapCategoryEnum.values
                                    .whereNot((c) => c.hidden)
                                    .toList(),
                            itemBuilder: (context, category, child) => Text(
                                category?.localize(l10n) ??
                                    l10n.snapCategoryAll),
                            onSelected: (value) => ref
                                .read(
                                    categoryProvider(initialCategory).notifier)
                                .state = value,
                            child: Text(ref
                                    .watch(categoryProvider(initialCategory))
                                    ?.localize(l10n) ??
                                l10n.snapCategoryAll),
                          );
                        },
                      ),
                    )
                  ],
                ])
              ],
            ),
          ),
          Expanded(
            child: Consumer(builder: (context, ref, child) {
              final category = ref.watch(
                  categoryProvider(initialCategoryName?.toSnapCategoryEnum()));
              final results = ref.watch(
                sortedSearchProvider(
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
                          SnapCardGrid(
                            snaps: data,
                            onTap: (snap) => StoreNavigator.pushSearchDetail(
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
                            const Spacer(flex: 1),
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
                loading: () =>
                    const Center(child: YaruCircularProgressIndicator()),
              );
            }),
          ),
        ],
      ),
    );
  }
}
