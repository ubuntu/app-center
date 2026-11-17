import 'dart:async';

import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/deb/deb_details_backend.dart'
    show appCategoriesFromFreedesktop;
import 'package:app_center/mapping/deb_package_adapter.dart';
import 'package:app_center/mapping/identifier_normalization.dart';
import 'package:app_center/mapping/package_mapping_resolver.dart';
import 'package:app_center/mapping/snap_package_adapter.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:snapd/snapd.dart';

enum PackageFormat { snap, deb }

final queryProvider = StateProvider<String?>((_) => null);

final packageFormatProvider = StateProvider.autoDispose<PackageFormat>(
  (_) => PackageFormat.snap,
);

typedef AutoCompleteOptions = ({
  Iterable<Snap> snaps,
  Iterable<AppstreamComponent> debs,
});

final autoCompleteProvider = FutureProvider<AutoCompleteOptions>((ref) async {
  final query = ref.watch(queryProvider);

  // The completer is used to make sure no queries are sent if the provider is
  // already disposed.
  final completer = Completer();
  ref.onDispose(completer.complete);

  // Wait for a short duration before sending off the query (i.e. wait until
  // the user stops typing). This also helps to ensure the results arrive in
  // the correct order.
  await Future.delayed(const Duration(milliseconds: 100));

  if ((query?.isNotEmpty ?? true) && !completer.isCompleted) {
    final results = await Future.wait([
      ref.watch(snapSearchProvider(SnapSearchParameters(query: query)).future),
      ref.watch(appstreamSearchProvider(query ?? '').future),
    ]);
    final snaps = results[0] as List<Snap>;
    final debs = results[1] as List<AppstreamComponent>;
    return (snaps: snaps, debs: debs);
  }
  return (snaps: <Snap>[], debs: <AppstreamComponent>[]);
});

/// One search result; it is shown as the snap when it has both formats.
typedef UnifiedSearchResult = ({Snap? snap, AppstreamComponent? deb});

/// Pairs each snap with its matching deb, keeping the snap order, followed by
/// the debs without a match in their own order.
List<UnifiedSearchResult> mergeSearchResults(
  List<Snap> snaps,
  List<AppstreamComponent> debs,
) {
  const resolver = PackageMappingResolver();
  final snapSources = snaps.map(snapSourceDescriptor).toList();
  final debSources = debs.map(debSourceDescriptor).toList();

  // Only pairs sharing an identifier can match, so only those are tested.
  final debsByKey = <String, Set<int>>{};
  for (final (index, deb) in debSources.indexed) {
    for (final key in [
      ...deb.commonIds,
      ...deb.aliases,
      deb.desktopId,
      deb.packageName ?? deb.packageId,
    ]) {
      debsByKey.putIfAbsent(normalizeDesktopId(key), () => {}).add(index);
    }
  }
  debsByKey.remove('');

  final matches = [
    for (final (s, snap) in snapSources.indexed)
      for (final d in {
        for (final key in [
          ...snap.commonIds.map(normalizeDesktopId),
          normalizeDesktopId(snap.desktopId, snapName: snap.packageId),
          normalizeDesktopId(snap.packageId),
        ])
          ...?debsByKey[key],
      })
        if (resolver.matchTier(snap, debSources[d]) case final tier?)
          (snap: s, deb: d, tier: tier),
  ];
  matches.sort((a, b) {
    final tier = a.tier.index.compareTo(b.tier.index);
    if (tier != 0) return tier;
    final snap = a.snap.compareTo(b.snap);
    return snap != 0 ? snap : a.deb.compareTo(b.deb);
  });

  final debBySnap = <int, AppstreamComponent>{};
  final matchedDebs = <int>{};
  for (final match in matches) {
    if (debBySnap.containsKey(match.snap) || matchedDebs.contains(match.deb)) {
      continue;
    }
    debBySnap[match.snap] = debs[match.deb];
    matchedDebs.add(match.deb);
  }

  return [
    for (final (index, snap) in snaps.indexed)
      (snap: snap, deb: debBySnap[index]),
    for (final (index, deb) in debs.indexed)
      if (!matchedDebs.contains(index)) (snap: null, deb: deb),
  ];
}

const _firstPageSize = 3;
const _pageSize = 9;

/// Splits the merged results into pages: the first holds the apps among the
/// top 3 snaps and debs, each next one the apps among the next 9 of each.
///
/// Snaps and debs are matched across the full lists, so a page never repeats
/// or changes an app from an earlier page. [sortOrder] reorders the snaps
/// within each page.
List<List<UnifiedSearchResult>> pageSearchResults(
  List<Snap> snaps,
  List<AppstreamComponent> debs, {
  SnapSortOrder? sortOrder,
}) {
  final merged = mergeSearchResults(snaps, debs);
  final snapEntries = Map<Snap, int>.identity();
  final debEntries = Map<AppstreamComponent, int>.identity();
  for (final (index, result) in merged.indexed) {
    if (result.snap case final snap?) snapEntries[snap] = index;
    if (result.deb case final deb?) debEntries[deb] = index;
  }

  final shown = <int>{};
  final pages = <List<UnifiedSearchResult>>[];
  for (
    var start = 0, size = _firstPageSize;
    start < snaps.length || start < debs.length;
    start += size, size = _pageSize
  ) {
    final page = [
      for (final index in [
        for (final snap in snaps.skip(start).take(size).sortedSnaps(sortOrder))
          snapEntries[snap]!,
        for (final deb in debs.skip(start).take(size)) debEntries[deb]!,
      ])
        if (shown.add(index)) merged[index],
    ];
    if (page.isNotEmpty) pages.add(page);
  }
  return pages;
}

/// Snap and deb search results for a query, merged and split into pages.
///
/// A failing source is left out, unless there is nothing else to show.
final unifiedSearchProvider = Provider.autoDispose
    .family<
      AsyncValue<List<List<UnifiedSearchResult>>>,
      ({String query, SnapCategoryEnum? category})
    >((ref, parameters) {
      final (:query, :category) = parameters;
      final snaps = ref.watch(
        snapSearchProvider(
          SnapSearchParameters(query: query, category: category),
        ),
      );
      final debs = ref.watch(appstreamSearchProvider(query));
      final sortOrder = ref.watch(snapSortOrderProvider);
      final sources = <AsyncValue<Object?>>[snaps, debs];

      if (sources.any((source) => !source.hasValue && !source.hasError)) {
        return const AsyncLoading();
      }
      final pages = pageSearchResults(
        snaps.value ?? const [],
        // Snaps come already filtered by the store; debs map their own
        // categories.
        [
          for (final deb in debs.value ?? const <AppstreamComponent>[])
            if (category == null ||
                appCategoriesFromFreedesktop(deb).contains(category))
              deb,
        ],
        sortOrder: sortOrder,
      );
      final failed = sources.where((source) => source.hasError).firstOrNull;
      if (pages.isEmpty && failed != null) {
        return AsyncError(failed.error!, failed.stackTrace ?? StackTrace.empty);
      }
      return AsyncData(pages);
    });
