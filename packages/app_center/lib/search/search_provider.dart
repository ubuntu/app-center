import 'dart:async';

import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/deb/deb_details_backend.dart'
    show appCategoriesFromFreedesktop;
import 'package:app_center/mapping/deb_package_adapter.dart';
import 'package:app_center/mapping/identifier_normalization.dart';
import 'package:app_center/mapping/package_mapping_resolver.dart';
import 'package:app_center/mapping/package_source_descriptor.dart'
    show PackageSourceDescriptor;
import 'package:app_center/mapping/snap_package_adapter.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:appstream/appstream.dart';
import 'package:collection/collection.dart'
    show IterableIterableExtension, mergeSort;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:snapd/snapd.dart';

enum PackageFormat { snap, deb }

final queryProvider = StateProvider<String?>((_) => null);

final packageFormatProvider = StateProvider.autoDispose<PackageFormat>(
  (_) => PackageFormat.snap,
);

/// Package format the unified results are limited to, or null for all.
final unifiedPackageFormatProvider = StateProvider.autoDispose<PackageFormat?>(
  (_) => null,
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

// Store search results list no apps, so an app-type snap counts as a desktop
// app for package-name matching.
PackageSourceDescriptor _searchSnapSource(Snap snap) {
  final source = snapSourceDescriptor(snap);
  return snap.type == 'app'
      ? source.copyWith(isDesktopApplication: true)
      : source;
}

/// The details entry of [result], carrying a matched pair as is, since
/// looking the snap up again may pick another of its debs.
AppDetailsEntry searchResultEntry(UnifiedSearchResult result) {
  final (:snap, :deb) = result;
  if (snap == null) return AppDetailsEntry.debComponent(deb!.id);
  if (deb == null) return AppDetailsEntry.snap(snap.name);
  final identity = const PackageMappingResolver().resolve(
    _searchSnapSource(snap),
    [debSourceDescriptor(deb)],
  );
  return identity == null
      ? AppDetailsEntry.snap(snap.name)
      : AppDetailsEntry.identity(identity);
}

/// Pairs each snap with its matching deb, keeping the snap order, followed by
/// the debs without a match in their own order.
List<UnifiedSearchResult> mergeSearchResults(
  List<Snap> snaps,
  List<AppstreamComponent> debs,
) {
  const resolver = PackageMappingResolver();
  final snapSources = snaps.map(_searchSnapSource).toList();
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
/// Limited to one [format], pages take twice as many of it instead.
///
/// Snaps and debs are matched across the full lists, so a page never repeats
/// or changes an app from an earlier page. Debs failing [showDeb] still pair
/// with snaps but get no card of their own.
List<List<UnifiedSearchResult>> pageSearchResults(
  List<Snap> snaps,
  List<AppstreamComponent> debs, {
  bool Function(AppstreamComponent deb)? showDeb,
  PackageFormat? format,
}) {
  final merged = mergeSearchResults(snaps, debs);
  final snapEntries = Map<Snap, int>.identity();
  final debEntries = Map<AppstreamComponent, int>.identity();
  for (final (index, result) in merged.indexed) {
    if (result.snap case final snap?) snapEntries[snap] = index;
    if (result.deb case final deb?) debEntries[deb] = index;
  }
  final pagedSnaps = format == PackageFormat.deb ? const <Snap>[] : snaps;
  final pagedDebs = format == PackageFormat.snap
      ? const <AppstreamComponent>[]
      : showDeb == null
      ? debs
      : debs.where(showDeb).toList();
  final scale = format == null ? 1 : 2;

  final shown = <int>{};
  final pages = <List<UnifiedSearchResult>>[];
  for (
    var start = 0, size = _firstPageSize * scale;
    start < pagedSnaps.length || start < pagedDebs.length;
    start += size, size = _pageSize * scale
  ) {
    final page = [
      for (final index in [
        for (final snap in pagedSnaps.skip(start).take(size))
          snapEntries[snap]!,
        for (final deb in pagedDebs.skip(start).take(size)) debEntries[deb]!,
      ])
        if (shown.add(index)) merged[index],
    ];
    if (page.isNotEmpty) pages.add(page);
  }
  return pages;
}

/// Picks up to 3 suggestions from the first page of results: an app in both
/// formats, a snap and a deb, or without such an app 2 snaps and a deb. Slots
/// left free go to the other results.
List<UnifiedSearchResult> suggestSearchResults(
  List<Snap> snaps,
  List<AppstreamComponent> debs,
) {
  final candidates = pageSearchResults(snaps, debs).firstOrNull ?? const [];
  final both = candidates.where((r) => r.snap != null && r.deb != null);
  final snapOnly = candidates.where((r) => r.deb == null);
  final debOnly = candidates.where((r) => r.snap == null);
  final picks = both.isNotEmpty
      ? [both.first, ...snapOnly.take(1), ...debOnly.take(1)]
      : [...snapOnly.take(2), ...debOnly.take(1)];
  return [
    ...picks,
    ...candidates.where((r) => !picks.contains(r)),
  ].take(3).toList();
}

/// Sorts [results] by [order], keeping their order for ties and for orders
/// that don't apply. Debs have no download size, so they sort last by size.
List<UnifiedSearchResult> sortSearchResults(
  Iterable<UnifiedSearchResult> results,
  SnapSortOrder? order,
) {
  String title(UnifiedSearchResult result) =>
      (result.snap?.titleOrName ?? result.deb!.getLocalizedName())
          .toLowerCase();
  int bySize(UnifiedSearchResult a, UnifiedSearchResult b, int direction) =>
      switch ((a.snap?.downloadSize, b.snap?.downloadSize)) {
        (final sizeA?, final sizeB?) => direction * sizeA.compareTo(sizeB),
        (null, null) => 0,
        (null, _) => 1,
        (_, null) => -1,
      };
  int compare(UnifiedSearchResult a, UnifiedSearchResult b) => switch (order) {
    SnapSortOrder.alphabeticalAsc => title(a).compareTo(title(b)),
    SnapSortOrder.alphabeticalDesc => title(b).compareTo(title(a)),
    SnapSortOrder.downloadSizeAsc => bySize(a, b, 1),
    SnapSortOrder.downloadSizeDesc => bySize(a, b, -1),
    _ => 0,
  };
  final sorted = results.toList();
  mergeSort(sorted, compare: compare);
  return sorted;
}

/// The results shown after revealing [shownPages] of [pages]. Relevance keeps
/// the pages as they are; another [order] sorts all results first, then shows
/// as many as those pages hold.
List<UnifiedSearchResult> shownSearchResults(
  List<List<UnifiedSearchResult>> pages,
  int shownPages,
  SnapSortOrder? order,
) {
  final revealed = pages.take(shownPages).flattened.toList();
  if (order == null) return revealed;
  return sortSearchResults(
    pages.flattened,
    order,
  ).take(revealed.length).toList();
}

/// Snap and deb search results for a query, merged and split into pages.
///
/// A failing source is left out, unless there is nothing else to show.
final unifiedSearchProvider = Provider.autoDispose
    .family<
      AsyncValue<List<List<UnifiedSearchResult>>>,
      ({String query, SnapCategoryEnum? category, PackageFormat? format})
    >((ref, parameters) {
      final (:query, :category, :format) = parameters;
      final snaps = ref.watch(
        snapSearchProvider(
          SnapSearchParameters(query: query, category: category),
        ),
      );
      final debs = ref.watch(appstreamResultsProvider(query));
      final sources = <AsyncValue<Object?>>[snaps, debs];

      if (sources.any((source) => !source.hasValue && !source.hasError)) {
        return const AsyncLoading();
      }
      final pages = pageSearchResults(
        snaps.value ?? const [],
        debs.value ?? const [],
        // Snaps come already filtered by the store; debs map their own
        // categories, which may differ from their snap's.
        showDeb: category == null
            ? null
            : (deb) => appCategoriesFromFreedesktop(deb).contains(category),
        format: format,
      );
      final failed = sources.where((source) => source.hasError).firstOrNull;
      if (pages.isEmpty && failed != null) {
        return AsyncError(failed.error!, failed.stackTrace ?? StackTrace.empty);
      }
      return AsyncData(pages);
    });
