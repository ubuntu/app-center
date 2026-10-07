import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/deb/deb_details_backend.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center/snapd/snap_category_enum.dart';
import 'package:app_center/snapd/snap_details_backend.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_details_backend.freezed.dart';

/// One exact release reported by a backend.
@freezed
class PackageRelease with _$PackageRelease {
  const factory PackageRelease({
    // Exact backend identity (e.g. snap revision, PackageKit package ID).
    required String candidateId,
    String? version,
    String? channel,
    @Default(FieldState<ByteSize>.unavailable()) FieldState<ByteSize> size,
    @Default(FieldState<DateTime>.unavailable())
    FieldState<DateTime> releaseDate,
    AppConfinement? confinement,
  }) = _PackageRelease;
}

/// An installation destination: a Deb package or a Snap channel.
@freezed
class PackageTarget with _$PackageTarget {
  const factory PackageTarget({
    required String id,
    required String label,
    required bool isInstalled,
    PackageRelease? candidate,
  }) = _PackageTarget;
}

/// A live mutation observed on a source, whoever started it.
@freezed
class ObservedOperation with _$ObservedOperation {
  const factory ObservedOperation({
    required OperationKind kind,
    String? targetId,
    double? progress,
    @Default(false) bool cancellable,
  }) = _ObservedOperation;
}

@freezed
class PackageCapabilities with _$PackageCapabilities {
  const factory PackageCapabilities({
    @Default(false) bool canLaunch,
    DisabledReason? updateBlocked,
    DisabledReason? removeBlocked,
  }) = _PackageCapabilities;
}

/// Normalized, immutable state of one package source.
@freezed
class PackageSourceSnapshot with _$PackageSourceSnapshot {
  const factory PackageSourceSnapshot({
    required SourceKey key,
    required InstallState installState,
    @Default(FieldState<String>.unavailable()) FieldState<String> appName,
    @Default(FieldState<ImageRef>.unavailable()) FieldState<ImageRef> icon,
    @Default(FieldState<String>.unavailable()) FieldState<String> summary,
    @Default(FieldState<RichContent>.unavailable())
    FieldState<RichContent> description,
    @Default(FieldState<List<String>>.unavailable())
    FieldState<List<String>> screenshots,
    @Default(FieldState<Publisher>.unavailable())
    FieldState<Publisher> publisher,
    @Default(FieldState<List<AppCategory>>.unavailable())
    FieldState<List<AppCategory>> categories,
    @Default(FieldState<AppConfinement>.unavailable())
    FieldState<AppConfinement> confinement,
    @Default(FieldState<String>.unavailable()) FieldState<String> license,
    @Default(FieldState<Map<AppLink, String>>.unavailable())
    FieldState<Map<AppLink, String>> links,
    @Default(FieldState<ContentRatingLevel>.unavailable())
    FieldState<ContentRatingLevel> ageRating,
    @Default(FieldState<List<String>>.unavailable())
    FieldState<List<String>> languages,
    @Default(FieldState<String>.unavailable()) FieldState<String> terms,
    @Default(FieldState<DateTime>.unavailable())
    FieldState<DateTime> installDate,
    PackageRelease? installed,
    PackageRelease? installCandidate,
    PackageRelease? updateCandidate,
    @Default(PackageCapabilities()) PackageCapabilities capabilities,
    @Default([]) List<PackageTarget> targets,
    ObservedOperation? activeOperation,
  }) = _PackageSourceSnapshot;

  const PackageSourceSnapshot._();

  PackageTarget? target(String? id) {
    for (final target in targets) {
      if (target.id == id) return target;
    }
    return null;
  }
}

/// A mutation bound to an exact target.
@freezed
class PackageCommand with _$PackageCommand {
  const factory PackageCommand({
    required OperationKind kind,
    String? targetId,
    String? candidateId,
  }) = _PackageCommand;
}

/// A backend refused or could not perform a request.
class PackageBackendException implements Exception {
  const PackageBackendException(this.message);

  final String message;

  @override
  String toString() => 'PackageBackendException: $message';
}

/// The package has neither an installed copy nor store metadata.
class PackageSourceNotFound implements Exception {
  const PackageSourceNotFound(this.key);

  final SourceKey key;

  @override
  String toString() => 'PackageSourceNotFound(${key.value})';
}

/// Like `AsyncValue.whenData`, but keeps the previous value on error/reload.
AsyncValue<R> mapAsyncValue<T, R>(
  AsyncValue<T> source,
  R Function(T value) map,
) {
  if (!source.hasValue) {
    return source.hasError
        ? AsyncError<R>(source.error!, source.stackTrace ?? StackTrace.empty)
        : AsyncLoading<R>();
  }
  final mapped = AsyncData<R>(map(source.valueOrNull as T));
  if (source.hasError) {
    return AsyncError<R>(
      source.error!,
      source.stackTrace ?? StackTrace.empty,
    ).copyWithPrevious(mapped);
  }
  if (source.isLoading) return AsyncLoading<R>().copyWithPrevious(mapped);
  return mapped;
}

/// Reads and mutates one package format.
abstract interface class PackageDetailsBackend {
  ProviderListenable<AsyncValue<PackageSourceSnapshot>> snapshot(SourceKey key);

  /// Re-reads authoritative state and completes once it is published.
  Future<void> reconcile(Ref ref, SourceKey key);

  /// Runs [command] until the backend reports a terminal state.
  Future<OperationOutcome> execute(
    Ref ref,
    SourceKey key,
    PackageCommand command,
  );

  Future<void> cancel(Ref ref, SourceKey key);

  Future<void> open(Ref ref, SourceKey key);
}

final packageDetailsBackendsProvider =
    Provider<Map<PackageFormat, PackageDetailsBackend>>(
      (ref) => const {
        PackageFormat.snap: SnapDetailsBackend(),
        PackageFormat.deb: DebDetailsBackend(),
      },
    );
