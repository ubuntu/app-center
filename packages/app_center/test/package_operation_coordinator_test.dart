import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/package_details_backend.dart';
import 'package:app_center/apps/package_operation_coordinator.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

OperationRequest _request(
  SourceKey source, {
  OperationKind kind = OperationKind.install,
  Set<String>? lockKeys,
}) => OperationRequest(
  source: source,
  command: PackageCommand(kind: kind, targetId: 'latest/stable'),
  targetLabel: 'latest/stable',
  targetCandidate: testSnapStable,
  lockKeys: lockKeys ?? {testSnapKey.value, testDebKey.value},
);

void main() {
  tearDown(resetAllServices);

  late FakePackageDetailsBackend backend;
  late ProviderContainer container;

  PackageOperationCoordinator coordinator() =>
      container.read(packageOperationCoordinatorProvider.notifier);
  List<TrackedOperation> operations() =>
      container.read(packageOperationCoordinatorProvider);

  setUp(() {
    backend = FakePackageDetailsBackend();
    container = createContainer(
      overrides: [
        packageDetailsBackendsProvider.overrideWithValue({
          PackageFormat.snap: backend,
          PackageFormat.deb: backend,
        }),
      ],
    );
  });

  test('publishes starting state before the backend call', () async {
    List<TrackedOperation>? stateAtExecute;
    backend.onExecute = (_, _, _) => stateAtExecute = operations();

    final receipt = coordinator().accept(_request(testSnapKey));

    expect(receipt, isA<AcceptedCommand>());
    expect(stateAtExecute?.single.phase, OperationPhase.starting);
    expect(stateAtExecute?.single.targetCandidate, testSnapStable);
    expect(backend.executed.single.$2.targetId, 'latest/stable');
  });

  test('completes through reconciliation', () async {
    backend.afterReconcile[testSnapKey] = createSourceSnapshot(
      testSnapKey,
      installState: InstallState.installed,
    );
    coordinator().accept(_request(testSnapKey));
    backend.complete(testSnapKey, OperationOutcome.success);
    await settle();

    final op = operations().single;
    expect(op.phase, OperationPhase.done);
    expect(op.outcome, OperationOutcome.success);
    expect(backend.reconciled, [testSnapKey]);
    expect(
      container
          .read(fakeSnapshotProvider(testSnapKey))
          .valueOrNull
          ?.installState,
      InstallState.installed,
    );
  });

  test('guards every source of the identity', () {
    coordinator().accept(_request(testSnapKey));

    expect(
      coordinator().accept(_request(testDebKey)),
      const CommandReceipt.rejected(CommandRejection.busy),
    );
    expect(
      coordinator().accept(
        _request(testSnapKey, lockKeys: {testSnapKey.value}),
      ),
      const CommandReceipt.rejected(CommandRejection.busy),
    );
    expect(backend.executed, hasLength(1));
  });

  test('unrelated identities are not blocked', () {
    coordinator().accept(_request(testSnapKey));
    const other = SourceKey(format: PackageFormat.snap, id: 'other');
    expect(
      coordinator().accept(_request(other, lockKeys: {other.value})),
      isA<AcceptedCommand>(),
    );
  });

  test('backend exceptions become failed outcomes', () async {
    coordinator().accept(_request(testSnapKey));
    backend.fail(testSnapKey, Exception('boom'));
    await settle();

    expect(operations().single.outcome, OperationOutcome.failed);
    expect(backend.reconciled, [testSnapKey]);
  });

  test('accepted cancellation keeps tracking until terminal', () async {
    final receipt =
        coordinator().accept(_request(testSnapKey)) as AcceptedCommand;

    expect(await coordinator().cancel(receipt.operationId), isTrue);
    expect(operations().single.phase, OperationPhase.cancelling);
    expect(backend.cancelled, [testSnapKey]);

    backend.complete(testSnapKey, OperationOutcome.failed);
    await settle();
    expect(operations().single.outcome, OperationOutcome.cancelled);
    expect(operations().single.phase, OperationPhase.done);
  });

  test('refused cancellation restores the previous phase', () async {
    backend.cancelError = Exception('too late');
    final receipt =
        coordinator().accept(_request(testSnapKey)) as AcceptedCommand;

    expect(await coordinator().cancel(receipt.operationId), isFalse);
    expect(operations().single.phase, OperationPhase.starting);
    expect(operations().single.cancelRequested, isFalse);
  });

  test('failed reconciliation still reaches a terminal state', () async {
    backend.reconcileError = Exception('daemon gone');
    coordinator().accept(_request(testSnapKey));
    backend.complete(testSnapKey, OperationOutcome.success);
    await settle();

    expect(operations().single.phase, OperationPhase.done);
  });

  test('acknowledge only removes finished operations', () async {
    final receipt =
        coordinator().accept(_request(testSnapKey)) as AcceptedCommand;
    coordinator().acknowledge(receipt.operationId);
    expect(operations(), hasLength(1));

    backend.complete(testSnapKey, OperationOutcome.failed);
    await settle();
    coordinator().acknowledge(receipt.operationId);
    expect(operations(), isEmpty);
  });

  test('retains a bounded number of finished operations', () async {
    for (var i = 0; i < kMaxRetainedOperations + 5; i++) {
      final key = SourceKey(format: PackageFormat.snap, id: 'snap$i');
      coordinator().accept(_request(key, lockKeys: {key.value}));
      backend.complete(key, OperationOutcome.success);
      await settle();
    }
    expect(operations(), hasLength(kMaxRetainedOperations));
    expect(operations().first.source.id, 'snap5');
  });

  test('supervision outlives listeners', () async {
    final subscription = container.listen(
      packageOperationCoordinatorProvider,
      (_, _) {},
    );
    coordinator().accept(_request(testSnapKey));
    subscription.close();
    await settle();

    backend.complete(testSnapKey, OperationOutcome.success);
    await settle();
    expect(operations().single.phase, OperationPhase.done);
  });
}
