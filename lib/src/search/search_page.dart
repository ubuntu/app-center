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

class SearchPage extends StatelessWidget {
  const SearchPage({super.key, this.query, String? category})
      : initialCategory = category;

  final String? query;
  final String? initialCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ResponsiveLayoutBuilder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kPagePadding) +
                ResponsiveLayout.of(context).padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const YaruBackButton(),
                if (query != null)
                  Text(
                    l10n.searchPageTitle(query!),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                if (initialCategory != null)
                  Text(
                    initialCategory!.toSnapCategoryEnum().localize(l10n),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(l10n.searchPageSortByLabel),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Consumer(builder: (context, ref, child) {
                        final sortOrder = ref.watch(sortOrderProvider);
                        return MenuButtonBuilder<SnapSortOrder>(
                          values: SnapSortOrder.values,
                          itemBuilder: (context, sortOrder, child) =>
                              Text(sortOrder.localize(l10n)),
                          onSelected: (value) => ref
                              .read(sortOrderProvider.notifier)
                              .state = value,
                          child: Text(sortOrder.localize(l10n)),
                        );
                      }),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Consumer(builder: (context, ref, child) {
              final category = ref.watch(
                  categoryProvider(initialCategory?.toSnapCategoryEnum()));
              final results = ref.watch(
                sortedSearchProvider(
                  SnapSearchParameters(
                    query: query,
                    category: category,
                  ),
                ),
              );
              return results.when(
                data: (data) => ResponsiveLayoutScrollView(
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

extension SnapSortOrderL10n on SnapSortOrder {
  String localize(AppLocalizations l10n) {
    return switch (this) {
      SnapSortOrder.alphabetical => l10n.searchPageAlphabeticalLabel,
      SnapSortOrder.downloadSize => l10n.searchPageDownloadSizeLabel,
      SnapSortOrder.relevance => l10n.searchPageRelevanceLabel,
    };
  }
}
