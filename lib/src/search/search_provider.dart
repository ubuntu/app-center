import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';

final searchProvider = FutureProvider.family((ref, String query) {
  final snapd = getService<SnapdService>();
  return snapd.find(query: query);
});

final queryProvider = StateProvider<String>((_) => '');

final autoCompleteProvider = FutureProvider((ref) async {
  final query = ref.watch(queryProvider);
  final completer = Completer();
  ref.onDispose(completer.complete);
  await Future.delayed(const Duration(milliseconds: 100));
  if (query.isNotEmpty && !completer.isCompleted) {
    return ref.watch(searchProvider(query).future);
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

final sortedSearchProvider =
    FutureProvider.family.autoDispose((ref, String query) {
  return ref.watch(searchProvider(query).future).then((snaps) {
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

final refreshProvider = FutureProvider((ref) {
  final snapd = getService<SnapdService>();
  return snapd.find(filter: SnapFindFilter.refresh);
});
