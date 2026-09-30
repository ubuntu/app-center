import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/apps/app_details_policy.dart';
import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/package_details_backend.dart';
import 'package:app_center/apps/package_operation_coordinator.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center/ratings/ratings_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_details_model.g.dart';

/// Read-only ratings summary of a snap.
@riverpod
AsyncValue<RatingsSummary?> appDetailsRatings(Ref ref, String snapName) =>
    mapAsyncValue(
      ref.watch(ratingsModelProvider(snapName)),
      (data) => data.rating == null
          ? null
          : RatingsSummary(
              band: data.rating!.ratingsBand,
              totalVotes: data.rating!.totalVotes,
            ),
    );

/// Format-agnostic ViewModel of the unified app details page.
@riverpod
class AppDetailsModel extends _$AppDetailsModel {
  static const _policy = AppDetailsPolicy();

  AppDetailsComposition? _composition;
  ResolvedAppIdentity? _identity;
  final _acknowledged = <IssueId>{};

  @override
  AsyncValue<AppDetailsViewState> build(AppDetailsEntry entry) {
    _composition = null;
    if (!entry.isValid) {
      return AsyncError(InvalidAppDetailsEntry(entry), StackTrace.current);
    }

    final resolved = ref.watch(appDetailsIdentityProvider(entry));
    final identity = resolved.valueOrNull;
    if (identity == null) {
      return resolved.hasError
          ? AsyncError(resolved.error!, resolved.stackTrace ?? StackTrace.empty)
          : const AsyncLoading();
    }
    _identity = identity;
    final keys = identity.sourceKeys;
    if (keys.isEmpty) {
      return AsyncError(InvalidAppDetailsEntry(entry), StackTrace.current);
    }

    final backends = ref.watch(packageDetailsBackendsProvider);
    final snapshots = <SourceKey, AsyncValue<PackageSourceSnapshot>>{
      for (final key in keys)
        if (backends[key.format] case final backend?)
          key: ref.watch(backend.snapshot(key)),
    };
    final operations = ref.watch(packageOperationCoordinatorProvider);
    final snapKey = keys.firstWhereOrNull(
      (key) => key.format == PackageFormat.snap,
    );
    final ratings = snapKey == null
        ? null
        : ref.watch(appDetailsRatingsProvider(snapKey.id));

    // Publish nothing until every source reports, to avoid a default flash.
    final settled = snapshots.values.every((s) => s.hasValue || s.hasError);
    if (!settled && !(stateOrNull?.hasValue ?? false)) {
      return const AsyncLoading();
    }

    final composition = _policy.compose(
      AppDetailsPolicyInput(
        identity: identity,
        snapshots: snapshots,
        operations: operations,
        ratings: ratings,
        acknowledgedIssues: _acknowledged,
      ),
    );
    _composition = composition;
    return AsyncData(composition.state);
  }

  /// Runs the action rendered with [actionId], if it is still valid.
  Future<CommandReceipt> execute(ActionId actionId) async {
    // Reading state flushes pending rebuilds, so bindings reflect the latest
    // backend capabilities rather than what was rendered.
    state;
    final binding = _composition?.bindings[actionId];
    if (binding == null) {
      return const CommandReceipt.rejected(CommandRejection.staleAction);
    }
    if (binding.disabledReason != null) {
      return CommandReceipt.rejected(
        binding.disabledReason == DisabledReason.busy
            ? CommandRejection.busy
            : CommandRejection.disabled,
      );
    }

    final coordinator = ref.read(packageOperationCoordinatorProvider.notifier);
    switch (binding.kind) {
      case ActionKind.open:
        final backend = ref.read(
          packageDetailsBackendsProvider,
        )[binding.source.format];
        try {
          await backend?.open(ref, binding.source);
          return const CommandReceipt.completed();
        } on Exception {
          return const CommandReceipt.rejected(CommandRejection.failed);
        }
      case ActionKind.cancel:
        final id = binding.operationId!;
        return await coordinator.cancel(id)
            ? CommandReceipt.accepted(id)
            : const CommandReceipt.rejected(CommandRejection.failed);
      case ActionKind.install:
      case ActionKind.update:
      case ActionKind.uninstall:
      case ActionKind.switchChannel:
        return coordinator.accept(
          OperationRequest(
            source: binding.source,
            command: binding.command!,
            targetLabel: binding.targetLabel,
            targetCandidate: binding.targetCandidate,
            lockKeys: _lockKeys(),
          ),
        );
    }
  }

  Future<void> cancel(OperationId operationId) async {
    await ref
        .read(packageOperationCoordinatorProvider.notifier)
        .cancel(operationId);
  }

  /// Re-reads authoritative state of every idle source.
  Future<void> refresh() async {
    final identity = _identity;
    if (identity == null) {
      ref.invalidate(appDetailsIdentityProvider(entry));
      return;
    }
    if (ref
        .read(packageOperationCoordinatorProvider.notifier)
        .isLocked(_lockKeys())) {
      return;
    }
    await Future.wait(identity.sourceKeys.map(_reconcile));
  }

  Future<void> retry(IssueId issueId) async {
    final value = issueId.value;
    if (value == 'discovery') {
      ref.invalidate(appDetailsIdentityProvider(entry));
    } else if (value == 'ratings') {
      final snapKey = _identity?.sourceKeys.firstWhereOrNull(
        (key) => key.format == PackageFormat.snap,
      );
      if (snapKey != null) ref.invalidate(ratingsModelProvider(snapKey.id));
    } else if (value.startsWith('source:')) {
      final key = _identity?.sourceKeys.firstWhereOrNull(
        (key) => 'source:${key.value}' == value,
      );
      if (key != null) await _reconcile(key);
    }
  }

  void acknowledge(IssueId issueId) {
    final operationId = _composition?.operationIssues[issueId];
    if (operationId != null) {
      ref
          .read(packageOperationCoordinatorProvider.notifier)
          .acknowledge(operationId);
      return;
    }
    if (_acknowledged.add(issueId)) ref.invalidateSelf();
  }

  Future<void> _reconcile(SourceKey key) async {
    final backend = ref.read(packageDetailsBackendsProvider)[key.format];
    try {
      await backend?.reconcile(ref, key);
    } on Exception {
      // Failure surfaces as a source issue through the watched snapshot.
    }
  }

  Set<String> _lockKeys() => {
    for (final source
        in _identity?.identity.sources ?? const <PackageSourceDescriptor>[])
      if (SourceKey.fromDescriptor(source) case final key?) ...[
        key.value,
        if (source.format == PackageFormat.deb)
          'deb-package:${source.packageName ?? source.packageId}',
      ],
  };
}
