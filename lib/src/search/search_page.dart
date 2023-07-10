import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/l10n.dart';
import '/widgets.dart';
import 'search_provider.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(kYaruPagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const YaruBackButton(),
              Text(
                l10n.searchPageTitle(query),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(l10n.searchPageSortByLabel),
                  const SizedBox(width: 8),
                  Consumer(builder: (context, ref, child) {
                    final sortOrder = ref.watch(sortOrderProvider);
                    return YaruPopupMenuButton<SnapSortOrder>(
                      itemBuilder: (_) => SnapSortOrder.values
                          .map((e) => PopupMenuItem(
                                value: e,
                                child: Text(e.localize(l10n)),
                              ))
                          .toList(),
                      onSelected: (value) =>
                          ref.read(sortOrderProvider.notifier).state = value,
                      child: Text(sortOrder.localize(l10n)),
                    );
                  }),
                ],
              )
            ],
          ),
        ),
        Expanded(child: Consumer(builder: (context, ref, child) {
          final results = ref.watch(sortedSearchProvider(query));
          return results.when(
            data: (data) => SnapGrid(snaps: data),
            error: (error, stack) => ErrorWidget(error),
            loading: () => const Center(child: YaruCircularProgressIndicator()),
          );
        })),
      ],
    );
  }
}
