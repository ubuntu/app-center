import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/apps/app_details_policy.dart';
import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/apps/package_details_backend.dart';
import 'package:app_center/apps/package_operation_coordinator.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

const _policy = AppDetailsPolicy();

AppDetailsComposition _compose({
  ResolvedAppIdentity? identity,
  PackageSourceSnapshot? snap,
  PackageSourceSnapshot? deb,
  Map<SourceKey, AsyncValue<PackageSourceSnapshot>> async = const {},
  List<TrackedOperation> operations = const [],
  AsyncValue<RatingsSummary?>? ratings,
  Set<IssueId> acknowledged = const {},
}) => _policy.compose(
  AppDetailsPolicyInput(
    identity:
        identity ??
        createResolvedIdentity(snap: snap != null, deb: deb != null),
    snapshots: {
      if (snap != null) testSnapKey: AsyncData(snap),
      if (deb != null) testDebKey: AsyncData(deb),
      ...async,
    },
    operations: operations,
    ratings: ratings,
    acknowledgedIssues: acknowledged,
  ),
);

PackageSourceSnapshot _snap([
  InstallState state = InstallState.notInstalled,
]) => createSourceSnapshot(testSnapKey, installState: state);

PackageSourceSnapshot _deb([InstallState state = InstallState.notInstalled]) =>
    createSourceSnapshot(testDebKey, installState: state);

TrackedOperation _operation(
  SourceKey source,
  OperationKind kind, {
  OperationPhase phase = OperationPhase.starting,
  String? targetId,
  PackageRelease? candidate,
  OperationOutcome? outcome,
}) => TrackedOperation(
  id: const OperationId('op-1'),
  source: source,
  command: PackageCommand(
    kind: kind,
    targetId: targetId,
    candidateId: candidate?.candidateId,
  ),
  targetLabel: targetId ?? source.id,
  lockKeys: {source.value},
  phase: phase,
  targetCandidate: candidate,
  outcome: outcome,
);

const _installed = InstallState.installed;
const _notInstalled = InstallState.notInstalled;

void main() {
  tearDown(resetAllServices);

  group('default active package', () {
    final cases =
        <
          (
            String,
            PackageSourceSnapshot?,
            PackageSourceSnapshot?,
            PackageFormat,
          )
        >[
          ('snap only, not installed', _snap(), null, PackageFormat.snap),
          ('snap only, installed', _snap(_installed), null, PackageFormat.snap),
          ('deb only, not installed', null, _deb(), PackageFormat.deb),
          ('deb only, installed', null, _deb(_installed), PackageFormat.deb),
          ('both, neither installed', _snap(), _deb(), PackageFormat.snap),
          (
            'both, only snap installed',
            _snap(_installed),
            _deb(),
            PackageFormat.snap,
          ),
          (
            'both, only deb installed',
            _snap(),
            _deb(_installed),
            PackageFormat.deb,
          ),
          (
            'both, both installed',
            _snap(_installed),
            _deb(_installed),
            PackageFormat.snap,
          ),
        ];
    for (final (name, snap, deb, expected) in cases) {
      test(name, () {
        final state = _compose(snap: snap, deb: deb).state;
        expect(state.activePackage.format, expected);
        expect(state.activePackage.reason, ActiveReason.installedState);
      });
    }

    test('unknown snap state is not treated as uninstalled', () {
      final state = _compose(
        snap: _snap(InstallState.unknown),
        deb: _deb(_installed),
      ).state;
      expect(state.activePackage.format, PackageFormat.snap);
      expect(state.activePackage.installState, InstallState.unknown);
      expect(state.actions.primary, isNull);
    });

    test('loading snap does not fall back to deb', () {
      final state = _compose(
        deb: _deb(_installed),
        identity: createResolvedIdentity(),
        async: {testSnapKey: const AsyncLoading()},
      ).state;
      expect(state.activePackage.format, PackageFormat.snap);
      expect(state.activePackage.publisher, isA<FieldLoading<Publisher>>());
    });
  });

  group('metadata ownership', () {
    test('snap owns app metadata while deb is active', () {
      final state = _compose(snap: _snap(), deb: _deb(_installed)).state;

      expect(state.activePackage.format, PackageFormat.deb);
      expect(state.app.name.valueOrNull, 'Snap App');
      expect(state.app.icon.valueOrNull, isA<NetworkImageRef>());
      expect(state.app.description.valueOrNull?.type, RichContentType.markdown);
      expect(state.app.screenshots.valueOrNull, [
        'https://example.com/Snap-shot.png',
      ]);
      expect(state.activePackage.publisher.valueOrNull?.name, 'Deb Publisher');
      expect(state.activePackage.categories.valueOrNull, [
        AppCategory.utilities,
      ]);
      expect(
        state.activePackage.confinement.valueOrNull,
        AppConfinement.unrestricted,
      );
      expect(state.footer.license.valueOrNull, 'GPL-3.0');
      expect(state.footer.ageRating.valueOrNull, ContentRatingLevel.mild);
    });

    test('failed snap metadata never uses deb content', () {
      final partialSnap = _snap().copyWith(
        appName: FieldState<String>.failed(),
        icon: FieldState<ImageRef>.failed(),
        screenshots: FieldState<List<String>>.failed(),
      );
      final composition = _compose(
        identity: createResolvedIdentity(),
        deb: _deb(_installed),
        async: {
          testSnapKey: AsyncError<PackageSourceSnapshot>(
            Exception('store down'),
            StackTrace.empty,
            // ignore: invalid_use_of_internal_member
          ).copyWithPrevious(AsyncData(partialSnap)),
        },
      );
      final state = composition.state;

      expect(state.activePackage.format, PackageFormat.deb);
      expect(state.app.name, isA<FieldFailed<String>>());
      expect(state.app.icon, isA<FieldFailed<ImageRef>>());
      expect(state.app.screenshots, isA<FieldFailed<List<String>>>());
      expect(state.actions.primary?.kind, ActionKind.uninstall);
      expect(state.actions.primary?.enabled, isTrue);
      expect(
        state.issues.map((i) => i.id),
        contains(const IssueId('source:snap:testsnap')),
      );
    });

    test('deb-only apps use deb metadata and have no ratings', () {
      final state = _compose(
        deb: _deb(),
        ratings: const AsyncData(null),
      ).state;
      expect(state.app.name.valueOrNull, 'Deb App');
      expect(state.app.ratings, isA<FieldUnavailable<RatingsSummary>>());
    });

    test('failed ratings do not block actions', () {
      final state = _compose(
        snap: _snap(),
        ratings: AsyncError(Exception('ratings'), StackTrace.empty),
      ).state;
      expect(state.app.ratings, isA<FieldFailed<RatingsSummary>>());
      expect(state.actions.primary?.kind, ActionKind.install);
      expect(state.actions.primary?.enabled, isTrue);
      expect(
        state.issues.map((i) => i.id),
        contains(const IssueId('ratings')),
      );
    });

    test('ratings come from snap', () {
      const summary = RatingsSummary(
        band: RatingsBand.good,
        totalVotes: 12,
      );
      final state = _compose(
        snap: _snap(),
        deb: _deb(_installed),
        ratings: const AsyncData(summary),
      ).state;
      expect(state.app.ratings.valueOrNull, summary);
    });
  });

  group('release', () {
    test('uninstalled shows install candidate', () {
      final release = _compose(snap: _snap()).state.release;
      expect(release.kind, ReleaseKind.installCandidate);
      expect(release.version.valueOrNull, '2.0');
      expect(release.size.valueOrNull?.kind, SizeKind.download);
    });

    test('installed shows installed release and install date', () {
      final state = _compose(snap: _snap(_installed)).state;
      expect(state.release.kind, ReleaseKind.installed);
      expect(state.release.size.valueOrNull?.kind, SizeKind.installed);
      expect(state.footer.installDate.valueOrNull, DateTime(2026, 2, 3));
    });

    test('update candidate is shown without installed size', () {
      final deb =
          createSourceSnapshot(
            testDebKey,
            installState: _installed,
            withUpdate: true,
          ).copyWith(
            updateCandidate: testDebUpdate.copyWith(
              size: FieldState<ByteSize>.unavailable(),
            ),
          );
      final release = _compose(deb: deb).state.release;
      expect(release.kind, ReleaseKind.update);
      expect(release.version.valueOrNull, '1.1-1');
      expect(release.size, isA<FieldUnavailable<ByteSize>>());
    });

    test('channel of displayed release is separate from installed one', () {
      final state = _compose(
        snap: _snap(_installed),
        operations: [
          _operation(
            testSnapKey,
            OperationKind.switchChannel,
            targetId: 'latest/beta',
            candidate: testSnapBeta,
          ),
        ],
      ).state;
      expect(state.activePackage.channel, 'latest/beta');
      expect(state.activePackage.installedChannel, 'latest/stable');
      expect(state.release.version.valueOrNull, '4.0-beta');
      expect(
        state.activePackage.confinement.valueOrNull,
        AppConfinement.classic,
      );
    });
  });

  group('install intent', () {
    test('deb install alongside snap displays deb immediately', () {
      final state = _compose(
        snap: _snap(_installed),
        deb: _deb(),
        operations: [
          _operation(
            testDebKey,
            OperationKind.install,
            targetId: 'test-app',
            candidate: testDebCandidate,
          ),
        ],
      ).state;

      expect(state.activePackage.format, PackageFormat.deb);
      expect(state.activePackage.reason, ActiveReason.installIntent);
      expect(state.activePackage.installState, _notInstalled);
      expect(state.activePackage.publisher.valueOrNull?.name, 'Deb Publisher');
      expect(state.release.kind, ReleaseKind.operationTarget);
      expect(state.release.version.valueOrNull, '1.0-1');
      expect(state.footer.installDate, isA<FieldUnavailable<DateTime>>());
      expect(state.app.name.valueOrNull, 'Snap App');
      expect(state.operation?.phase, OperationPhase.starting);
      expect(state.operation?.progress, isNull);
      expect(state.actions.secondary, isEmpty);
    });

    test('target metadata loading is not replaced by previous source', () {
      final state = _compose(
        identity: createResolvedIdentity(),
        snap: _snap(_installed),
        async: {testDebKey: const AsyncLoading()},
        operations: [
          _operation(testDebKey, OperationKind.install, targetId: 'test-app'),
        ],
      ).state;
      expect(state.activePackage.format, PackageFormat.deb);
      expect(state.activePackage.publisher, isA<FieldLoading<Publisher>>());
      expect(state.release.version, isA<FieldLoading<String>>());
    });

    test('terminal operation clears intent', () {
      final state = _compose(
        snap: _snap(_installed),
        deb: _deb(_installed),
        operations: [
          _operation(
            testDebKey,
            OperationKind.install,
            phase: OperationPhase.done,
            outcome: OperationOutcome.success,
          ),
        ],
      ).state;
      expect(state.activePackage.format, PackageFormat.snap);
      expect(state.operation, isNull);
    });

    test('removal does not create a display override', () {
      final state = _compose(
        snap: _snap(_installed),
        deb: _deb(_installed),
        operations: [_operation(testDebKey, OperationKind.remove)],
      ).state;
      expect(state.activePackage.format, PackageFormat.snap);
      expect(state.operation?.sourceId, testDebKey.value);
      expect(state.operation?.kind, OperationKind.remove);
    });
  });

  group('observed installation', () {
    const observedInstall = ObservedOperation(
      kind: OperationKind.install,
      targetId: 'test-app',
      progress: 0.4,
    );

    test('deb install is selected when snap is confirmed absent', () {
      final deb = createSourceSnapshot(
        testDebKey,
        activeOperation: observedInstall,
      );
      final state = _compose(snap: _snap(), deb: deb).state;

      expect(state.activePackage.format, PackageFormat.deb);
      expect(state.activePackage.reason, ActiveReason.observedInstall);
      expect(state.activePackage.installState, _notInstalled);
      expect(state.release.version.valueOrNull, '1.0-1');
      expect(state.operation?.progress, 0.4);
      expect(state.operation?.canCancel, isFalse);
      expect(state.app.name.valueOrNull, 'Snap App');
    });

    test('also applies without a snap source', () {
      final deb = createSourceSnapshot(
        testDebKey,
        activeOperation: observedInstall,
      );
      final state = _compose(deb: deb).state;
      expect(state.activePackage.reason, ActiveReason.observedInstall);
    });

    test('installed or unknown snap wins', () {
      final deb = createSourceSnapshot(
        testDebKey,
        activeOperation: observedInstall,
      );
      expect(
        _compose(snap: _snap(_installed), deb: deb).state.activePackage.format,
        PackageFormat.snap,
      );
      expect(
        _compose(
          snap: _snap(InstallState.unknown),
          deb: deb,
        ).state.activePackage.format,
        PackageFormat.snap,
      );
    });

    test('removal is not an observed installation', () {
      final deb = createSourceSnapshot(
        testDebKey,
        installState: _installed,
        activeOperation: const ObservedOperation(kind: OperationKind.remove),
      );
      final state = _compose(snap: _snap(), deb: deb).state;
      expect(state.activePackage.reason, ActiveReason.installedState);
      expect(state.activePackage.format, PackageFormat.deb);
      expect(state.operation?.kind, OperationKind.remove);
      expect(state.actions.secondary.every((a) => !a.enabled), isTrue);
    });

    test('unknown target metadata stays unavailable', () {
      final deb = createSourceSnapshot(
        testDebKey,
        activeOperation: const ObservedOperation(kind: OperationKind.install),
      );
      final state = _compose(snap: _snap(), deb: deb).state;
      expect(state.release.version, isA<FieldUnavailable<String>>());
    });
  });

  group('actions', () {
    PackageSourceSnapshot installedSnap({
      bool withUpdate = false,
      bool canLaunch = false,
      DisabledReason? updateBlocked,
      DisabledReason? removeBlocked,
    }) => createSourceSnapshot(
      testSnapKey,
      installState: _installed,
      withUpdate: withUpdate,
      canLaunch: canLaunch,
      updateBlocked: updateBlocked,
      removeBlocked: removeBlocked,
    );

    List<ActionKind> kinds(ActionsSection actions) => [
      for (final action in actions.secondary) action.kind,
    ];

    test('not installed offers install of the default target', () {
      final composition = _compose(snap: _snap());
      final primary = composition.state.actions.primary!;
      expect(primary.kind, ActionKind.install);
      final binding = composition.bindings[primary.id]!;
      expect(binding.command?.targetId, 'latest/stable');
      expect(binding.command?.candidateId, 'rev:2');
      expect(binding.targetCandidate, testSnapStable);
    });

    test('update is primary with open and uninstall available', () {
      final actions = _compose(
        snap: installedSnap(withUpdate: true, canLaunch: true),
      ).state.actions;
      expect(actions.primary?.kind, ActionKind.update);
      expect(kinds(actions), [ActionKind.open, ActionKind.uninstall]);
    });

    test('update binds the installed channel and exact candidate', () {
      final composition = _compose(snap: installedSnap(withUpdate: true));
      final binding =
          composition.bindings[composition.state.actions.primary!.id]!;
      expect(binding.command?.kind, OperationKind.update);
      expect(binding.command?.targetId, 'latest/stable');
      expect(binding.command?.candidateId, 'rev:3');
    });

    test('blocked update falls back to open', () {
      final actions = _compose(
        snap: installedSnap(
          withUpdate: true,
          canLaunch: true,
          updateBlocked: DisabledReason.appRunning,
        ),
      ).state.actions;
      expect(actions.primary?.kind, ActionKind.open);
      final update = actions.secondary.firstWhere(
        (a) => a.kind == ActionKind.update,
      );
      expect(update.enabled, isFalse);
      expect(update.disabledReason, DisabledReason.appRunning);
    });

    test('not launchable makes uninstall primary', () {
      final actions = _compose(snap: installedSnap()).state.actions;
      expect(actions.primary?.kind, ActionKind.uninstall);
      expect(actions.secondary, isEmpty);
    });

    test('protected removal is disabled', () {
      final actions = _compose(
        deb: createSourceSnapshot(
          testDebKey,
          installState: _installed,
          removeBlocked: DisabledReason.protectedPackage,
        ),
      ).state.actions;
      expect(actions.primary, isNull);
      expect(actions.secondary.single.kind, ActionKind.uninstall);
      expect(
        actions.secondary.single.disabledReason,
        DisabledReason.protectedPackage,
      );
    });

    test('owned operation offers cancel and disables mutations', () {
      final snap = installedSnap(withUpdate: true, canLaunch: true).copyWith(
        activeOperation: const ObservedOperation(
          kind: OperationKind.update,
          cancellable: true,
        ),
      );
      final state = _compose(
        snap: snap,
        operations: [
          _operation(
            testSnapKey,
            OperationKind.update,
          ),
        ],
      ).state;
      expect(state.actions.primary?.kind, ActionKind.cancel);
      expect(state.operation?.phase, OperationPhase.running);
      expect(state.operation?.canCancel, isTrue);
      final byKind = {for (final a in state.actions.secondary) a.kind: a};
      expect(byKind[ActionKind.open]?.enabled, isTrue);
      expect(byKind[ActionKind.update]?.disabledReason, DisabledReason.busy);
      expect(byKind[ActionKind.uninstall]?.disabledReason, DisabledReason.busy);
    });

    test('action IDs are stable across equal refreshes', () {
      final first = _compose(snap: installedSnap(withUpdate: true));
      final second = _compose(snap: installedSnap(withUpdate: true));
      expect(
        first.state.actions.primary!.id,
        second.state.actions.primary!.id,
      );
    });

    test('a changed candidate changes the action ID', () {
      final first = _compose(snap: installedSnap(withUpdate: true));
      final second = _compose(
        snap: installedSnap(withUpdate: true).copyWith(
          updateCandidate: testSnapUpdate.copyWith(candidateId: 'rev:5'),
        ),
      );
      expect(
        second.bindings.containsKey(first.state.actions.primary!.id),
        isFalse,
      );
    });
  });

  group('targets', () {
    test('only the installed snap channel is removable', () {
      final composition = _compose(snap: _snap(_installed), deb: _deb());
      final state = composition.state;
      final snapGroup = state.targets.firstWhere(
        (g) => g.format == PackageFormat.snap,
      );
      final debGroup = state.targets.firstWhere(
        (g) => g.format == PackageFormat.deb,
      );

      expect(snapGroup.options.map((o) => o.action?.kind), [
        ActionKind.uninstall,
        ActionKind.switchChannel,
      ]);
      expect(debGroup.options.single.action?.kind, ActionKind.install);
      expect(state.actions.hasMoreActions, isTrue);

      final beta = composition.bindings[snapGroup.options.last.action!.id]!;
      expect(beta.command?.kind, OperationKind.switchChannel);
      expect(beta.command?.targetId, 'latest/beta');
    });

    test('uninstall target shares the main uninstall action', () {
      final state = _compose(deb: _deb(_installed)).state;
      expect(
        state.targets.single.options.single.action?.id,
        state.actions.primary?.id,
      );
    });

    test('single target has no more actions', () {
      final snap = createSourceSnapshot(
        testSnapKey,
        channels: ['latest/stable'],
      );
      expect(_compose(snap: snap).state.actions.hasMoreActions, isFalse);
    });

    test('deb installed while snap active keeps deb removal available', () {
      final state = _compose(
        snap: _snap(_installed),
        deb: _deb(_installed),
      ).state;
      final debOption = state.targets
          .firstWhere((g) => g.format == PackageFormat.deb)
          .options
          .single;
      expect(state.activePackage.format, PackageFormat.snap);
      expect(debOption.action?.kind, ActionKind.uninstall);
      expect(debOption.action?.enabled, isTrue);
    });
  });

  group('issues', () {
    test('failed operations surface until acknowledged', () {
      final operation = _operation(
        testSnapKey,
        OperationKind.install,
        phase: OperationPhase.done,
        outcome: OperationOutcome.failed,
      );
      final composition = _compose(snap: _snap(), operations: [operation]);
      final issue = composition.state.issues.single;
      expect(issue.kind, IssueKind.operationFailed);
      expect(composition.operationIssues[issue.id], operation.id);

      final acknowledged = _compose(
        snap: _snap(),
        operations: [operation],
        acknowledged: {issue.id},
      );
      expect(acknowledged.state.issues, isEmpty);
    });

    test('cancelled operations are not failures', () {
      final state = _compose(
        snap: _snap(),
        operations: [
          _operation(
            testSnapKey,
            OperationKind.install,
            phase: OperationPhase.done,
            outcome: OperationOutcome.cancelled,
          ),
        ],
      ).state;
      expect(state.issues, isEmpty);
    });

    test('discovery failure is retryable', () {
      final state = _compose(
        identity: createResolvedIdentity(deb: false, discoveryFailed: true),
        snap: _snap(),
      ).state;
      expect(state.issues.single.scope, IssueScope.discovery);
      expect(state.issues.single.retryable, isTrue);
    });
  });
}
