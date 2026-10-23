import 'dart:async';

import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/apps/app_details_model.dart';
import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/package_details_backend.dart';
import 'package:app_center/apps/package_operation_coordinator.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

const _entry = AppDetailsEntry.snap('testsnap');
const _installed = InstallState.installed;

void main() {
  tearDown(resetAllServices);

  late FakePackageDetailsBackend backend;
  late ProviderContainer container;
  ProviderSubscription<AsyncValue<AppDetailsViewState>>? subscription;

  ProviderContainer create({
    ResolvedAppIdentity? identity,
    AsyncValue<RatingsSummary?> ratings = const AsyncData(null),
  }) => createContainer(
    overrides: [
      packageDetailsBackendsProvider.overrideWithValue({
        PackageFormat.snap: backend,
        PackageFormat.deb: backend,
      }),
      appDetailsIdentityProvider(
        _entry,
      ).overrideWith((ref) async => identity ?? createResolvedIdentity()),
      appDetailsRatingsProvider('testsnap').overrideWith((ref) => ratings),
    ],
  );

  void setSnapshot(SourceKey key, PackageSourceSnapshot snapshot) =>
      container.read(fakeSnapshotProvider(key).notifier).state = AsyncData(
        snapshot,
      );

  void open() => subscription = container.listen(
    appDetailsModelProvider(_entry),
    (_, _) {},
  );

  AsyncValue<AppDetailsViewState> async() =>
      container.read(appDetailsModelProvider(_entry));
  AppDetailsViewState view() => async().requireValue;
  AppDetailsModel model() =>
      container.read(appDetailsModelProvider(_entry).notifier);

  ActionDescriptor targetAction(PackageFormat format, String label) => view()
      .targets
      .firstWhere((group) => group.format == format)
      .options
      .firstWhere((option) => option.label == label)
      .action!;

  Future<AppDetailsViewState> start({
    required PackageSourceSnapshot snap,
    required PackageSourceSnapshot deb,
    AsyncValue<RatingsSummary?> ratings = const AsyncData(null),
  }) async {
    container = create(ratings: ratings);
    setSnapshot(testSnapKey, snap);
    setSnapshot(testDebKey, deb);
    open();
    await settle();
    return view();
  }

  setUp(() {
    backend = FakePackageDetailsBackend();
    subscription = null;
  });

  test('waits for every source before publishing', () async {
    container = create();
    open();
    await settle();
    expect(async().isLoading, isTrue);

    setSnapshot(testSnapKey, createSourceSnapshot(testSnapKey));
    expect(async().isLoading, isTrue);

    setSnapshot(
      testDebKey,
      createSourceSnapshot(testDebKey, installState: _installed),
    );
    expect(view().activePackage.format, PackageFormat.deb);
  });

  test('rejects an invalid entry', () {
    container = create();
    expect(
      container.read(appDetailsModelProvider(const AppDetailsEntry.snap(''))),
      isA<AsyncError<AppDetailsViewState>>(),
    );
  });

  group('before the identity resolves', () {
    late Completer<ResolvedAppIdentity> lookup;

    setUp(() => lookup = Completer());

    ProviderContainer createPending() => createContainer(
      overrides: [
        packageDetailsBackendsProvider.overrideWithValue({
          PackageFormat.snap: backend,
          PackageFormat.deb: backend,
        }),
        appDetailsIdentityProvider(_entry).overrideWith((ref) => lookup.future),
        appDetailsRatingsProvider(
          'testsnap',
        ).overrideWith((ref) => const AsyncData(null)),
      ],
    );

    test('publishes an installed snap right away', () {
      container = createPending();
      setSnapshot(
        testSnapKey,
        createSourceSnapshot(
          testSnapKey,
          installState: _installed,
          withUpdate: true,
        ),
      );
      open();

      expect(view().activePackage.sourceId, testSnapKey.value);
      expect(view().app.name.valueOrNull, 'Snap App');
      expect(view().actions.primary?.kind, ActionKind.update);
      expect(view().actions.primary?.enabled, isTrue);
    });

    test('uses a lookup made from the other format', () {
      container = createPending();
      container
          .read(knownAppIdentitiesProvider.notifier)
          .record(createResolvedIdentity());
      setSnapshot(testSnapKey, createSourceSnapshot(testSnapKey));
      setSnapshot(testDebKey, createSourceSnapshot(testDebKey));
      open();

      expect(view().formats.map((f) => f.format), [
        PackageFormat.snap,
        PackageFormat.deb,
      ]);
      expect(view().actions.primary?.kind, ActionKind.install);
      expect(view().actions.primary?.enabled, isTrue);
    });

    test('keeps known sources when the lookup fails', () async {
      container = createPending();
      container
          .read(knownAppIdentitiesProvider.notifier)
          .record(createResolvedIdentity());
      setSnapshot(testSnapKey, createSourceSnapshot(testSnapKey));
      setSnapshot(testDebKey, createSourceSnapshot(testDebKey));
      open();

      lookup.complete(
        createResolvedIdentity(deb: false, discoveryFailed: true),
      );
      await settle();

      expect(view().formats.map((f) => f.format), [
        PackageFormat.snap,
        PackageFormat.deb,
      ]);
      expect(view().issues.map((i) => i.scope), contains(IssueScope.discovery));
    });

    test('does not report a missing app before the lookup finishes', () async {
      container = createPending();
      container.read(fakeSnapshotProvider(testSnapKey).notifier).state =
          AsyncError(PackageSourceNotFound(testSnapKey), StackTrace.empty);
      open();
      expect(async().error, isNot(isA<AppNotFound>()));

      lookup.complete(createResolvedIdentity(deb: false));
      await settle();
      expect(async().error, isA<AppNotFound>());
    });

    test('holds actions until counterparts are known', () async {
      container = createPending();
      setSnapshot(testSnapKey, createSourceSnapshot(testSnapKey));
      open();
      expect(view().app.name.valueOrNull, 'Snap App');
      expect(view().decided, isFalse);

      lookup.complete(createResolvedIdentity(deb: false));
      await settle();
      expect(view().decided, isTrue);
      expect(view().actions.primary?.kind, ActionKind.install);
      expect(view().actions.primary?.enabled, isTrue);
    });

    test('decides on an installed deb found by the lookup', () async {
      container = createPending();
      setSnapshot(testSnapKey, createSourceSnapshot(testSnapKey));
      setSnapshot(
        testDebKey,
        createSourceSnapshot(testDebKey, installState: _installed),
      );
      final shown = <(PackageFormat, bool)>[];
      subscription = container.listen(appDetailsModelProvider(_entry), (
        _,
        next,
      ) {
        if (next.value case final state?) {
          shown.add((state.activePackage.format, state.decided));
        }
      }, fireImmediately: true);

      lookup.complete(createResolvedIdentity());
      await settle();
      expect(shown.first, (PackageFormat.snap, false));
      expect(shown.last, (PackageFormat.deb, true));
      expect(shown.where((s) => s.$2).map((s) => s.$1).toSet(), {
        PackageFormat.deb,
      });
    });
  });

  test('rejects actions while the active package may change', () async {
    final shown = await start(
      snap: createSourceSnapshot(testSnapKey),
      deb: createSourceSnapshot(testDebKey),
    );
    final install = shown.actions.primary!;

    container.read(fakeSnapshotProvider(testDebKey).notifier).state =
        const AsyncLoading();
    await settle();

    expect(view().decided, isFalse);
    expect(
      await model().execute(install.id),
      const CommandReceipt.rejected(CommandRejection.busy),
    );
    expect(backend.executed, isEmpty);
  });

  test('loaded data equal to the cached data does not notify', () async {
    container = create(identity: createResolvedIdentity(deb: false));
    final cached = createSourceSnapshot(testSnapKey);
    container.read(fakeSnapshotProvider(testSnapKey).notifier).state =
        // ignore: invalid_use_of_internal_member
        const AsyncLoading<PackageSourceSnapshot>().copyWithPrevious(
          AsyncData(cached),
        );
    var notifications = 0;
    container.listen(
      appDetailsModelProvider(_entry),
      (_, _) => notifications++,
    );
    await settle();
    notifications = 0;

    setSnapshot(testSnapKey, cached);
    await settle();
    expect(notifications, 0);

    setSnapshot(
      testSnapKey,
      createSourceSnapshot(testSnapKey, installState: _installed),
    );
    await settle();
    expect(notifications, 1);
  });

  group('not found', () {
    AsyncError<PackageSourceSnapshot> notFound(SourceKey key) =>
        AsyncError(PackageSourceNotFound(key), StackTrace.empty);

    test('when every source is gone', () async {
      container = create();
      container.read(fakeSnapshotProvider(testSnapKey).notifier).state =
          notFound(testSnapKey);
      container.read(fakeSnapshotProvider(testDebKey).notifier).state =
          notFound(testDebKey);
      open();
      await settle();

      expect(async().error, isA<AppNotFound>());
    });

    test('not while another source remains', () async {
      container = create();
      container
          .read(fakeSnapshotProvider(testSnapKey).notifier)
          .state = notFound(
        testSnapKey,
        // ignore: invalid_use_of_internal_member
      ).copyWithPrevious(AsyncData(createSourceSnapshot(testSnapKey)));
      setSnapshot(
        testDebKey,
        createSourceSnapshot(testDebKey, installState: _installed),
      );
      open();
      await settle();

      expect(view().activePackage.format, PackageFormat.deb);
    });

    test('not for other source errors', () async {
      container = create();
      for (final key in [testSnapKey, testDebKey]) {
        container.read(fakeSnapshotProvider(key).notifier).state = AsyncError(
          Exception('offline'),
          StackTrace.empty,
        );
      }
      open();
      await settle();

      expect(async().error, isNot(isA<AppNotFound>()));
    });
  });

  test('installs the active package', () async {
    final initial = await start(
      snap: createSourceSnapshot(testSnapKey),
      deb: createSourceSnapshot(testDebKey),
    );
    backend.afterReconcile[testSnapKey] = createSourceSnapshot(
      testSnapKey,
      installState: _installed,
    );

    final receipt = await model().execute(initial.actions.primary!.id);
    expect(receipt, isA<AcceptedCommand>());
    expect(view().activePackage.reason, ActiveReason.installIntent);
    expect(view().operation?.phase, OperationPhase.starting);
    expect(view().activePackage.installState, InstallState.notInstalled);

    backend.complete(testSnapKey, OperationOutcome.success);
    await settle();

    expect(view().activePackage.format, PackageFormat.snap);
    expect(view().activePackage.reason, ActiveReason.installedState);
    expect(view().activePackage.installState, _installed);
    expect(view().operation, isNull);
    expect(view().actions.primary?.kind, ActionKind.uninstall);
  });

  test('rejects installing deb while snap is installed', () async {
    await start(
      snap: createSourceSnapshot(testSnapKey, installState: _installed),
      deb: createSourceSnapshot(testDebKey),
    );

    expect(
      await model().execute(targetAction(PackageFormat.deb, 'test-app').id),
      const CommandReceipt.rejected(CommandRejection.disabled),
    );
    expect(backend.executed, isEmpty);
    expect(view().activePackage.format, PackageFormat.snap);
  });

  test('switches channel in place and rejects the old update', () async {
    final initial = await start(
      snap: createSourceSnapshot(
        testSnapKey,
        installState: _installed,
        withUpdate: true,
      ),
      deb: createSourceSnapshot(testDebKey),
    );
    final oldUpdate = initial.actions.primary!;
    expect(oldUpdate.kind, ActionKind.update);
    backend.afterReconcile[testSnapKey] = createSourceSnapshot(
      testSnapKey,
      installState: _installed,
      installedChannel: 'latest/beta',
      withUpdate: true,
    );

    final beta = targetAction(PackageFormat.snap, 'latest/beta');
    expect(beta.kind, ActionKind.switchChannel);
    await model().execute(beta.id);

    expect(view().activePackage.channel, 'latest/beta');
    expect(view().activePackage.installedChannel, 'latest/stable');
    expect(backend.executed.single.$2.targetId, 'latest/beta');

    backend.complete(testSnapKey, OperationOutcome.success);
    await settle();

    expect(view().activePackage.installedChannel, 'latest/beta');
    expect(
      await model().execute(oldUpdate.id),
      const CommandReceipt.rejected(CommandRejection.staleAction),
    );
  });

  test('removing snap while deb is installed makes deb active', () async {
    final initial = await start(
      snap: createSourceSnapshot(testSnapKey, installState: _installed),
      deb: createSourceSnapshot(testDebKey, installState: _installed),
    );
    backend.afterReconcile[testSnapKey] = createSourceSnapshot(testSnapKey);

    expect(initial.actions.primary?.kind, ActionKind.uninstall);
    await model().execute(initial.actions.primary!.id);
    expect(view().activePackage.format, PackageFormat.snap);

    backend.complete(testSnapKey, OperationOutcome.success);
    await settle();

    expect(view().activePackage.format, PackageFormat.deb);
    expect(view().app.name.valueOrNull, 'Snap App');
  });

  test('rejects duplicate, disabled and unknown actions', () async {
    final initial = await start(
      snap: createSourceSnapshot(
        testSnapKey,
        installState: _installed,
        withUpdate: true,
        removeBlocked: DisabledReason.protectedPackage,
      ),
      deb: createSourceSnapshot(testDebKey),
    );
    final protectedRemoval = targetAction(PackageFormat.snap, 'latest/stable');
    expect(
      await model().execute(protectedRemoval.id),
      const CommandReceipt.rejected(CommandRejection.disabled),
    );

    final update = initial.actions.primary!;
    expect(update.kind, ActionKind.update);
    expect(await model().execute(update.id), isA<AcceptedCommand>());
    expect(
      await model().execute(update.id),
      const CommandReceipt.rejected(CommandRejection.busy),
    );
    expect(
      await model().execute(const ActionId('install|snap:other||')),
      const CommandReceipt.rejected(CommandRejection.staleAction),
    );
    expect(backend.executed, hasLength(1));
    expect(initial.activePackage.format, PackageFormat.snap);
  });

  test('reopening during a deb install shows it without re-running', () async {
    await start(
      snap: createSourceSnapshot(testSnapKey),
      deb: createSourceSnapshot(testDebKey),
    );
    await model().execute(targetAction(PackageFormat.deb, 'test-app').id);

    subscription!.close();
    await settle();

    open();
    await settle();
    expect(view().activePackage.format, PackageFormat.deb);
    expect(view().operation?.kind, OperationKind.install);
    expect(view().activePackage.installState, InstallState.notInstalled);
    expect(backend.executed, hasLength(1));

    backend.afterReconcile[testDebKey] = createSourceSnapshot(testDebKey);
    backend.complete(testDebKey, OperationOutcome.cancelled);
    await settle();
    expect(view().activePackage.format, PackageFormat.snap);
    expect(view().issues, isEmpty);
  });

  test('observed deb installation selects deb on a fresh page', () async {
    final state = await start(
      snap: createSourceSnapshot(testSnapKey),
      deb: createSourceSnapshot(
        testDebKey,
        activeOperation: const ObservedOperation(
          kind: OperationKind.install,
          targetId: 'test-app',
        ),
      ),
    );
    expect(state.activePackage.reason, ActiveReason.observedInstall);
    expect(state.operation?.canCancel, isFalse);
    expect(state.actions.primary, isNull);
  });

  test('failures surface once until acknowledged', () async {
    final initial = await start(
      snap: createSourceSnapshot(testSnapKey),
      deb: createSourceSnapshot(testDebKey),
    );
    await model().execute(initial.actions.primary!.id);
    backend.complete(testSnapKey, OperationOutcome.failed);
    await settle();

    final issue = view().issues.single;
    expect(issue.kind, IssueKind.operationFailed);
    expect(view().activePackage.reason, ActiveReason.installedState);

    model().acknowledge(issue.id);
    expect(view().issues, isEmpty);
    expect(container.read(packageOperationCoordinatorProvider), isEmpty);
  });

  test('open completes without an operation', () async {
    final initial = await start(
      snap: createSourceSnapshot(
        testSnapKey,
        installState: _installed,
        canLaunch: true,
      ),
      deb: createSourceSnapshot(testDebKey),
    );
    expect(initial.actions.primary?.kind, ActionKind.open);
    expect(
      await model().execute(initial.actions.primary!.id),
      const CommandReceipt.completed(),
    );
    expect(backend.opened, [testSnapKey]);
    expect(container.read(packageOperationCoordinatorProvider), isEmpty);
  });

  test('cancels an owned operation', () async {
    final initial = await start(
      snap: createSourceSnapshot(testSnapKey),
      deb: createSourceSnapshot(testDebKey),
    );
    await model().execute(initial.actions.primary!.id);
    setSnapshot(
      testSnapKey,
      createSourceSnapshot(
        testSnapKey,
        activeOperation: const ObservedOperation(
          kind: OperationKind.install,
          progress: 0.5,
          cancellable: true,
        ),
      ),
    );

    expect(view().operation?.phase, OperationPhase.running);
    expect(view().operation?.progress, 0.5);
    final cancel = view().actions.primary!;
    expect(cancel.kind, ActionKind.cancel);
    expect(await model().execute(cancel.id), isA<AcceptedCommand>());
    expect(backend.cancelled, [testSnapKey]);
    expect(view().operation?.phase, OperationPhase.cancelling);
  });

  test('refresh reconciles only when idle', () async {
    final initial = await start(
      snap: createSourceSnapshot(testSnapKey),
      deb: createSourceSnapshot(testDebKey),
    );
    await model().refresh();
    expect(backend.reconciled, [testSnapKey, testDebKey]);

    backend.reconciled.clear();
    await model().execute(initial.actions.primary!.id);
    await model().refresh();
    expect(backend.reconciled, isEmpty);
  });

  test('page-level issues can be acknowledged', () async {
    final initial = await start(
      snap: createSourceSnapshot(testSnapKey),
      deb: createSourceSnapshot(testDebKey),
      ratings: AsyncError(Exception('ratings down'), StackTrace.empty),
    );
    final issue = initial.issues.single;
    expect(issue.scope, IssueScope.ratings);
    expect(initial.actions.primary?.enabled, isTrue);

    model().acknowledge(issue.id);
    expect(view().issues, isEmpty);
  });
}
