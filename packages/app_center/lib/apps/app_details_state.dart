import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center/snapd/snap_category_enum.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_details_state.freezed.dart';

/// App Center's category taxonomy, shared by every package format.
typedef AppCategory = SnapCategoryEnum;

extension type const ActionId(String value) {}

extension type const OperationId(String value) {}

extension type const IssueId(String value) {}

/// A displayed value that may still be loading, be absent or have failed.
@freezed
class FieldState<T> with _$FieldState<T> {
  const factory FieldState.loading() = FieldLoading<T>;
  const factory FieldState.value(T value, {@Default(false) bool stale}) =
      FieldValue<T>;
  const factory FieldState.unavailable() = FieldUnavailable<T>;
  const factory FieldState.failed({T? lastKnown}) = FieldFailed<T>;

  factory FieldState.fromNullable(T? value) =>
      value == null ? FieldState<T>.unavailable() : FieldState<T>.value(value);

  const FieldState._();

  T? get valueOrNull => mapOrNull(
    value: (field) => field.value,
    failed: (field) => field.lastKnown,
  );

  FieldState<T> asStale() => map(
    loading: (field) => field,
    value: (field) => field.copyWith(stale: true),
    unavailable: (field) => field,
    failed: (field) => field,
  );
}

enum InstallState { unknown, notInstalled, installed }

enum PublisherValidation { none, verified, starred }

enum RichContentType { markdown, html, plain }

enum SizeKind { download, installed }

/// Highest OARS content intensity declared by the package.
enum ContentRatingLevel { none, mild, moderate, intense }

/// Why the active package was chosen.
enum ActiveReason { installedState, installIntent, observedInstall }

enum ReleaseKind { installed, update, installCandidate, operationTarget }

enum ActionKind { install, update, open, uninstall, switchChannel, cancel }

enum DisabledReason {
  busy,
  protectedPackage,
  appRunning,
  targetUnavailable,
  installStateUnknown,
}

enum OperationKind { install, update, switchChannel, remove }

enum OperationPhase { starting, running, cancelling, reconciling, done }

enum OperationOutcome { success, failed, cancelled }

enum IssueScope { discovery, source, ratings, operation }

enum IssueKind { lookupFailed, sourceUnavailable, loadFailed, operationFailed }

enum CommandRejection { unknownAction, staleAction, disabled, busy, failed }

/// Acceptance of a command; completion arrives through the watched state.
@freezed
class CommandReceipt with _$CommandReceipt {
  const factory CommandReceipt.accepted(OperationId operationId) =
      AcceptedCommand;
  const factory CommandReceipt.completed() = CompletedCommand;
  const factory CommandReceipt.rejected(CommandRejection reason) =
      RejectedCommand;
}

@freezed
class Publisher with _$Publisher {
  const factory Publisher({
    required String name,
    @Default(PublisherValidation.none) PublisherValidation validation,
  }) = _Publisher;
}

@freezed
class ImageRef with _$ImageRef {
  const factory ImageRef.network(String url) = NetworkImageRef;
  const factory ImageRef.file(String path) = FileImageRef;
}

/// Package-supplied text; render as untrusted content.
@freezed
class RichContent with _$RichContent {
  const factory RichContent({
    required String text,
    required RichContentType type,
  }) = _RichContent;
}

@freezed
class ByteSize with _$ByteSize {
  const factory ByteSize({required int bytes, required SizeKind kind}) =
      _ByteSize;
}

@freezed
class RatingsSummary with _$RatingsSummary {
  const factory RatingsSummary({
    required RatingsBand band,
    required int totalVotes,
  }) = _RatingsSummary;
}

@freezed
class AppSection with _$AppSection {
  const factory AppSection({
    required String appId,
    required FieldState<String> name,
    required FieldState<ImageRef> icon,
    required FieldState<String> summary,
    required FieldState<RichContent> description,
    required FieldState<List<String>> screenshots,
    required FieldState<RatingsSummary> ratings,
  }) = _AppSection;
}

@freezed
class ActivePackageSection with _$ActivePackageSection {
  const factory ActivePackageSection({
    required String sourceId,
    required PackageFormat format,
    required InstallState installState,
    required ActiveReason reason,
    required FieldState<Publisher> publisher,
    required FieldState<List<AppCategory>> categories,
    required FieldState<AppConfinement> confinement,
    // Channel of the displayed release; may differ from the installed one.
    String? channel,
    String? installedChannel,
  }) = _ActivePackageSection;
}

@freezed
class ReleaseSection with _$ReleaseSection {
  const factory ReleaseSection({
    required FieldState<String> version,
    required FieldState<ByteSize> size,
    required FieldState<DateTime> releaseDate,
    ReleaseKind? kind,
  }) = _ReleaseSection;
}

@freezed
class FooterSection with _$FooterSection {
  const factory FooterSection({
    required FieldState<Publisher> publisher,
    required FieldState<DateTime> lastUpdated,
    required FieldState<String> license,
    required FieldState<ContentRatingLevel> ageRating,
    required FieldState<List<String>> languages,
    required FieldState<Map<AppLink, String>> links,
    required FieldState<String> terms,
    required FieldState<DateTime> installDate,
  }) = _FooterSection;
}

@freezed
class ActionDescriptor with _$ActionDescriptor {
  const factory ActionDescriptor({
    required ActionId id,
    required ActionKind kind,
    @Default(true) bool enabled,
    DisabledReason? disabledReason,
  }) = _ActionDescriptor;
}

@freezed
class ActionsSection with _$ActionsSection {
  const factory ActionsSection({
    ActionDescriptor? primary,
    @Default([]) List<ActionDescriptor> secondary,
    @Default(false) bool hasMoreActions,
  }) = _ActionsSection;
}

@freezed
class TargetOption with _$TargetOption {
  const factory TargetOption({
    required String label,
    required bool isInstalled,
    required FieldState<String> version,
    ActionDescriptor? action,
  }) = _TargetOption;
}

@freezed
class TargetGroup with _$TargetGroup {
  const factory TargetGroup({
    required String sourceId,
    required PackageFormat format,
    required List<TargetOption> options,
  }) = _TargetGroup;
}

@freezed
class OperationView with _$OperationView {
  const factory OperationView({
    required OperationId id,
    required String sourceId,
    required PackageFormat format,
    required String targetLabel,
    required OperationKind kind,
    required OperationPhase phase,
    // Normalized to 0..1; null means indeterminate.
    double? progress,
    @Default(false) bool canCancel,
  }) = _OperationView;
}

@freezed
class AppDetailsIssue with _$AppDetailsIssue {
  const factory AppDetailsIssue({
    required IssueId id,
    required IssueScope scope,
    required IssueKind kind,
    @Default(false) bool retryable,
    String? sourceId,
  }) = _AppDetailsIssue;
}

@freezed
class AppDetailsViewState with _$AppDetailsViewState {
  const factory AppDetailsViewState({
    required AppSection app,
    required ActivePackageSection activePackage,
    required ReleaseSection release,
    required FooterSection footer,
    required ActionsSection actions,
    @Default([]) List<TargetGroup> targets,
    OperationView? operation,
    @Default([]) List<AppDetailsIssue> issues,
  }) = _AppDetailsViewState;
}
