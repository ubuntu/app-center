import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';

class SnapSearchParameters {
  const SnapSearchParameters({this.query, this.category});
  final String? query;
  final SnapCategoryEnum? category;

  @override
  bool operator ==(Object other) =>
      other is SnapSearchParameters &&
      other.query == query &&
      other.category == category;

  @override
  int get hashCode => Object.hash(query, category);
}

final searchProvider =
    StreamProvider.family((ref, SnapSearchParameters searchParameters) async* {
  final snapd = getService<SnapdService>();
  if (searchParameters.category == SnapCategoryEnum.ubuntuDesktop) {
    yield* snapd.getStoreSnaps(searchParameters.category!.featuredSnapNames
            ?.where((name) => name.contains(searchParameters.query ?? ''))
            .toList() ??
        []);
  } else if (searchParameters.query == null &&
      searchParameters.category != null) {
    yield* snapd.getCategory(searchParameters.category!.categoryName);
  } else {
    yield await snapd.find(
      query: searchParameters.query,
      category: searchParameters.category?.categoryName,
    );
  }
});

final queryProvider = StateProvider<String?>((_) => null);

final categoryProvider = StateProvider.family
    .autoDispose<SnapCategoryEnum?, SnapCategoryEnum?>(
        (ref, initialValue) => initialValue);

final autoCompleteProvider = FutureProvider((ref) async {
  final query = ref.watch(queryProvider);
  final completer = Completer();
  ref.onDispose(completer.complete);
  await Future.delayed(const Duration(milliseconds: 100));
  if ((query?.isNotEmpty ?? true) && !completer.isCompleted) {
    return ref.watch(searchProvider(SnapSearchParameters(query: query)).future);
  }
  return [];
});

enum SnapSortOrder {
  alphabetical,
  downloadSize,
  relevance;
}

final sortOrderProvider = StateProvider.autoDispose((ref) {
  return SnapSortOrder.relevance;
});

final sortedSearchProvider = FutureProvider.family
    .autoDispose((ref, SnapSearchParameters searchParameters) {
  return ref.watch(searchProvider(searchParameters).future).then((snaps) {
    final sortOrder = ref.watch(sortOrderProvider);
    if (sortOrder == SnapSortOrder.relevance) {
      return snaps;
    }

    return snaps.sorted(((a, b) => switch (sortOrder) {
          SnapSortOrder.alphabetical => a.titleOrName.compareTo(b.titleOrName),
          SnapSortOrder.downloadSize =>
            a.downloadSize != null && b.downloadSize != null
                ? a.downloadSize!.compareTo(b.downloadSize!)
                : 0,
          _ => 0,
        }));
  });
});
