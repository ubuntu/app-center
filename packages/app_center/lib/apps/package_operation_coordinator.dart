import 'dart:async';

import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/package_details_backend.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ubuntu_logger/ubuntu_logger.dart';

part 'package_operation_coordinator.freezed.dart';
part 'package_operation_coordinator.g.dart';

final _log = Logger('package_operation_coordinator');

const kReconcileTimeout = Duration(seconds: 30);
const kMaxRetainedOperations = 20;

/// A mutation accepted by the coordinator; it outlives the page.
@freezed
abstract class TrackedOperation with _$TrackedOperation {
  const factory TrackedOperation({
    required OperationId id,
    required SourceKey source,
    required PackageCommand command,
    required String targetLabel,
    required Set<String> lockKeys,
    @Default(OperationPhase.starting) OperationPhase phase,
    PackageRelease? targetCandidate,
    OperationOutcome? outcome,
    @Default(false) bool cancelRequested,
  }) = _TrackedOperation;

  const TrackedOperation._();

  bool get isActive => phase != OperationPhase.done;

  bool get isInstallIntent =>
      isActive &&
      (command.kind == OperationKind.install ||
          command.kind == OperationKind.switchChannel);
}

@freezed
abstract class OperationRequest with _$OperationRequest {
  const factory OperationRequest({
    required SourceKey source,
    required PackageCommand command,
    required String targetLabel,
    // Every source of the identity, so different entries share one lock.
    required Set<String> lockKeys,
    PackageRelease? targetCandidate,
  }) = _OperationRequest;
}

@Riverpod(keepAlive: true)
class PackageOperationCoordinator extends _$PackageOperationCoordinator {
  var _nextId = 0;

  @override
  List<TrackedOperation> build() => const [];

  bool isLocked(Set<String> lockKeys) => state.any(
    (op) => op.isActive && op.lockKeys.intersection(lockKeys).isNotEmpty,
  );

  /// Publishes the starting state synchronously, then runs the command.
  CommandReceipt accept(OperationRequest request) {
    if (isLocked(request.lockKeys)) {
      return const CommandReceipt.rejected(CommandRejection.busy);
    }
    final backend = ref.read(
      packageDetailsBackendsProvider,
    )[request.source.format];
    if (backend == null) {
      return const CommandReceipt.rejected(CommandRejection.failed);
    }

    final operation = TrackedOperation(
      id: OperationId('op-${_nextId++}'),
      source: request.source,
      command: request.command,
      targetLabel: request.targetLabel,
      lockKeys: request.lockKeys,
      targetCandidate: request.targetCandidate,
    );
    state = [...state, operation];
    unawaited(_run(backend, operation));
    return CommandReceipt.accepted(operation.id);
  }

  /// Requests cancellation; tracking continues until a terminal state.
  Future<bool> cancel(OperationId id) async {
    final operation = _find(id);
    if (operation == null ||
        (operation.phase != OperationPhase.starting &&
            operation.phase != OperationPhase.running)) {
      return false;
    }
    final backend = ref.read(
      packageDetailsBackendsProvider,
    )[operation.source.format];
    if (backend == null) return false;

    final previousPhase = operation.phase;
    _update(
      id,
      (op) => op.copyWith(
        phase: OperationPhase.cancelling,
        cancelRequested: true,
      ),
    );
    try {
      await backend.cancel(ref, operation.source);
      return true;
    } on Exception catch (e) {
      _log.info('Cancellation of $id refused: $e');
      _update(
        id,
        (op) => op.phase == OperationPhase.cancelling
            ? op.copyWith(phase: previousPhase, cancelRequested: false)
            : op,
      );
      return false;
    }
  }

  void acknowledge(OperationId id) {
    state = [
      for (final op in state)
        if (op.id != id || op.isActive) op,
    ];
  }

  Future<void> _run(
    PackageDetailsBackend backend,
    TrackedOperation operation,
  ) async {
    var outcome = OperationOutcome.failed;
    try {
      outcome = await backend.execute(
        ref,
        operation.source,
        operation.command,
      );
    } on Exception catch (e) {
      _log.error('Operation ${operation.id} failed: $e');
    }
    if (outcome == OperationOutcome.failed &&
        (_find(operation.id)?.cancelRequested ?? false)) {
      outcome = OperationOutcome.cancelled;
    }

    _update(
      operation.id,
      (op) => op.copyWith(phase: OperationPhase.reconciling, outcome: outcome),
    );
    try {
      await backend.reconcile(ref, operation.source).timeout(kReconcileTimeout);
    } on Exception catch (e) {
      _log.error('Reconciliation after ${operation.id} failed: $e');
    }
    _update(operation.id, (op) => op.copyWith(phase: OperationPhase.done));
    _prune();
  }

  TrackedOperation? _find(OperationId id) {
    for (final op in state) {
      if (op.id == id) return op;
    }
    return null;
  }

  void _update(
    OperationId id,
    TrackedOperation Function(TrackedOperation op) update,
  ) {
    state = [
      for (final op in state) op.id == id ? update(op) : op,
    ];
  }

  void _prune() {
    final done = state.where((op) => !op.isActive).toList();
    if (done.length <= kMaxRetainedOperations) return;
    final dropped = done
        .take(done.length - kMaxRetainedOperations)
        .map((op) => op.id)
        .toSet();
    state = state.where((op) => !dropped.contains(op.id)).toList();
  }
}
