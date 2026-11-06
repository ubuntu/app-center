import 'package:app_center/snapd/snapd_cache.dart';
import 'package:app_center/snapd/snapd_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

part 'seen_snaps_model.freezed.dart';
part 'seen_snaps_model.g.dart';

@freezed
abstract class SeenSnaps with _$SeenSnaps {
  const factory SeenSnaps({
    // From any store query; listings may omit channels and apps.
    @Default({}) Map<String, Snap> store,
    // From lookups by exact name, which are complete.
    @Default({}) Map<String, Snap> byName,
    @Default({}) Map<String, Snap> local,
  }) = _SeenSnaps;
}

/// Snaps snapd already returned anywhere in the app, shown while a page's own
/// requests run; never authoritative.
@Riverpod(keepAlive: true)
class SeenSnapsModel extends _$SeenSnapsModel {
  @override
  SeenSnaps build() {
    final results = getService<SnapdService>().snapResults.listen(record);
    ref.onDispose(results.cancel);
    return const SeenSnaps();
  }

  void record(SnapdResult result) {
    state = switch (result) {
      FoundSnaps(:final snaps, :final name) => state.copyWith(
        store: {
          ...state.store,
          for (final snap in snaps)
            // Listings may omit channels; keep a richer entry over them.
            if (snap.channels.isNotEmpty ||
                (state.store[snap.name]?.channels.isEmpty ?? true))
              snap.name: snap,
        },
        byName: {
          ...state.byName,
          for (final snap in snaps)
            if (snap.name == name) snap.name: snap,
        },
      ),
      LocalSnap(:final name, snap: null) => state.copyWith(
        local: {...state.local}..remove(name),
      ),
      LocalSnap(:final name, :final snap?) => state.copyWith(
        local: {...state.local, name: snap},
      ),
      InstalledSnaps(:final snaps) => state.copyWith(
        local: {
          ...state.local,
          for (final snap in snaps)
            if (snap.status == SnapStatus.active) snap.name: snap,
        },
      ),
    };
  }
}
