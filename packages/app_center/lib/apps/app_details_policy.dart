import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/package_details_backend.dart';
import 'package:app_center/apps/package_operation_coordinator.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The ViewModel-private binding of an [ActionId] to its fixed target.
class ActionBinding {
  const ActionBinding({
    required this.source,
    required this.kind,
    required this.targetLabel,
    this.command,
    this.operationId,
    this.targetCandidate,
    this.disabledReason,
  });

  final SourceKey source;
  final ActionKind kind;
  final String targetLabel;
  final PackageCommand? command;
  final OperationId? operationId;
  final PackageRelease? targetCandidate;
  final DisabledReason? disabledReason;
}

class AppDetailsPolicyInput {
  const AppDetailsPolicyInput({
    required this.identity,
    required this.snapshots,
    this.operations = const [],
    this.ratings,
    this.acknowledgedIssues = const {},
  });

  final ResolvedAppIdentity identity;
  final Map<SourceKey, AsyncValue<PackageSourceSnapshot>> snapshots;
  final List<TrackedOperation> operations;
  // Null when no ratings are known for the app-metadata owner.
  final AsyncValue<RatingsSummary?>? ratings;
  final Set<IssueId> acknowledgedIssues;
}

class AppDetailsComposition {
  const AppDetailsComposition({
    required this.state,
    required this.bindings,
    required this.operationIssues,
  });

  final AppDetailsViewState state;
  final Map<ActionId, ActionBinding> bindings;
  final Map<IssueId, OperationId> operationIssues;
}

/// Pure rules turning source snapshots and operations into page state.
class AppDetailsPolicy {
  const AppDetailsPolicy();

  AppDetailsComposition compose(AppDetailsPolicyInput input) =>
      _Composer(input).compose();
}

class _Composer {
  _Composer(this.input) : keys = input.identity.sourceKeys, bindings = {} {
    snapKey = keys.firstWhereOrNull((k) => k.format == PackageFormat.snap);
    debKey = keys.firstWhereOrNull((k) => k.format == PackageFormat.deb);
    operations = input.operations
        .where((op) => keys.contains(op.source))
        .toList();
    ownedActive = operations.firstWhereOrNull((op) => op.isActive);
  }

  final AppDetailsPolicyInput input;
  final List<SourceKey> keys;
  final Map<ActionId, ActionBinding> bindings;
  late final SourceKey? snapKey;
  late final SourceKey? debKey;
  late final List<TrackedOperation> operations;
  late final TrackedOperation? ownedActive;

  AsyncValue<PackageSourceSnapshot>? _async(SourceKey? key) =>
      key == null ? null : input.snapshots[key];

  PackageSourceSnapshot? _snapshot(SourceKey? key) => _async(key)?.valueOrNull;

  InstallState _installState(SourceKey? key) =>
      _snapshot(key)?.installState ?? InstallState.unknown;

  (SourceKey, ObservedOperation)? get _observed {
    for (final key in keys) {
      final op = _snapshot(key)?.activeOperation;
      if (op != null) return (key, op);
    }
    return null;
  }

  bool get _busy => ownedActive != null || _observed != null;

  AppDetailsComposition compose() {
    final (activeKey, reason) = _selectActive();
    final active = _async(activeKey);
    final snapshot = active?.valueOrNull;
    final installState = _installState(activeKey);
    final (release, releaseKind) = _displayedRelease(
      activeKey,
      reason,
      snapshot,
    );

    final releaseSection = ReleaseSection(
      kind: releaseKind,
      version: _releaseField(
        active,
        release,
        (r) => r.version == null
            ? FieldState<String>.unavailable()
            : FieldState<String>.value(r.version!),
      ),
      size: _releaseField(active, release, (r) => r.size),
      releaseDate: _releaseField(active, release, (r) => r.releaseDate),
    );
    final publisher = _field(active, (s) => s.publisher);

    final state = AppDetailsViewState(
      app: _appSection(),
      activePackage: ActivePackageSection(
        sourceId: activeKey.value,
        format: activeKey.format,
        installState: installState,
        reason: reason,
        publisher: publisher,
        categories: _field(active, (s) => s.categories),
        confinement: release?.confinement != null
            ? FieldState.value(release!.confinement!)
            : _field(active, (s) => s.confinement),
        channel: release?.channel,
        installedChannel: snapshot?.installed?.channel,
      ),
      release: releaseSection,
      footer: FooterSection(
        publisher: publisher,
        lastUpdated: releaseSection.releaseDate,
        license: _field(active, (s) => s.license),
        ageRating: _field(active, (s) => s.ageRating),
        languages: _field(active, (s) => s.languages),
        links: _field(active, (s) => s.links),
        terms: _field(active, (s) => s.terms),
        installDate: installState == InstallState.installed
            ? _field(active, (s) => s.installDate)
            : FieldState<DateTime>.unavailable(),
      ),
      actions: _actions(activeKey, snapshot),
      targets: _targets(),
      operation: _operation(),
      issues: [],
    );

    final (issues, operationIssues) = _issues();
    return AppDetailsComposition(
      state: state.copyWith(issues: issues),
      bindings: Map.unmodifiable(bindings),
      operationIssues: operationIssues,
    );
  }

  (SourceKey, ActiveReason) _selectActive() {
    final intent = operations.firstWhereOrNull((op) => op.isInstallIntent);
    if (intent != null) return (intent.source, ActiveReason.installIntent);

    final snapState = snapKey == null
        ? InstallState.notInstalled
        : _installState(snapKey);
    if (debKey != null &&
        snapState == InstallState.notInstalled &&
        _snapshot(debKey)?.activeOperation?.kind == OperationKind.install) {
      return (debKey!, ActiveReason.observedInstall);
    }

    if (snapKey == null) return (debKey!, ActiveReason.installedState);
    if (debKey == null) return (snapKey!, ActiveReason.installedState);
    if (_installState(debKey) == InstallState.installed &&
        snapState == InstallState.notInstalled) {
      return (debKey!, ActiveReason.installedState);
    }
    return (snapKey!, ActiveReason.installedState);
  }

  (PackageRelease?, ReleaseKind?) _displayedRelease(
    SourceKey key,
    ActiveReason reason,
    PackageSourceSnapshot? snapshot,
  ) {
    switch (reason) {
      case ActiveReason.installIntent:
        final intent = operations.firstWhere((op) => op.isInstallIntent);
        return (intent.targetCandidate, ReleaseKind.operationTarget);
      case ActiveReason.observedInstall:
        final targetId = snapshot?.activeOperation?.targetId;
        return (
          targetId == null ? null : snapshot?.target(targetId)?.candidate,
          ReleaseKind.operationTarget,
        );
      case ActiveReason.installedState:
        if (snapshot == null) return (null, null);
        return switch (snapshot.installState) {
          InstallState.installed when snapshot.updateCandidate != null => (
            snapshot.updateCandidate,
            ReleaseKind.update,
          ),
          InstallState.installed => (snapshot.installed, ReleaseKind.installed),
          InstallState.notInstalled => (
            snapshot.installCandidate,
            ReleaseKind.installCandidate,
          ),
          InstallState.unknown => (null, null),
        };
    }
  }

  FieldState<T> _releaseField<T>(
    AsyncValue<PackageSourceSnapshot>? source,
    PackageRelease? release,
    FieldState<T> Function(PackageRelease release) pick,
  ) {
    if (release != null) return pick(release);
    if (source == null) return FieldState<T>.unavailable();
    if (!source.hasValue) {
      return source.hasError ? FieldState<T>.failed() : FieldState<T>.loading();
    }
    return source.value!.installState == InstallState.unknown
        ? FieldState<T>.loading()
        : FieldState<T>.unavailable();
  }

  FieldState<T> _field<T>(
    AsyncValue<PackageSourceSnapshot>? source,
    FieldState<T> Function(PackageSourceSnapshot snapshot) pick,
  ) {
    if (source == null) return FieldState<T>.unavailable();
    final snapshot = source.valueOrNull;
    if (snapshot != null) {
      final field = pick(snapshot);
      return source.hasError ? field.asStale() : field;
    }
    return source.hasError ? FieldState<T>.failed() : FieldState<T>.loading();
  }

  AppSection _appSection() {
    // Snap owns app-wide metadata whenever a Snap source is known.
    final owner = _async(snapKey ?? debKey);
    return AppSection(
      appId: input.identity.identity.unifiedId,
      name: _field(owner, (s) => s.appName),
      icon: _field(owner, (s) => s.icon),
      summary: _field(owner, (s) => s.summary),
      description: _field(owner, (s) => s.description),
      screenshots: _field(owner, (s) => s.screenshots),
      ratings: _ratings(),
    );
  }

  FieldState<RatingsSummary> _ratings() {
    final ratings = input.ratings;
    if (snapKey == null || ratings == null) {
      return FieldState<RatingsSummary>.unavailable();
    }
    final value = ratings.valueOrNull;
    if (value != null) {
      return ratings.hasError
          ? FieldState.value(value, stale: true)
          : FieldState.value(value);
    }
    if (ratings.hasError) return FieldState<RatingsSummary>.failed();
    if (ratings.isLoading) return FieldState<RatingsSummary>.loading();
    return FieldState<RatingsSummary>.unavailable();
  }

  ActionDescriptor _bind(ActionBinding binding) {
    final command = binding.command;
    final id = ActionId(
      switch (binding.kind) {
        ActionKind.cancel => ['cancel', binding.operationId!.value],
        ActionKind.open => [
          'open',
          binding.source.value,
          binding.targetCandidate?.candidateId ?? '',
        ],
        _ => [
          binding.kind.name,
          binding.source.value,
          command?.targetId ?? '',
          command?.candidateId ?? '',
        ],
      }.join('|'),
    );
    bindings[id] = binding;
    return ActionDescriptor(
      id: id,
      kind: binding.kind,
      enabled: binding.disabledReason == null,
      disabledReason: binding.disabledReason,
    );
  }

  String _installedLabel(SourceKey key, PackageSourceSnapshot snapshot) =>
      snapshot.targets.firstWhereOrNull((t) => t.isInstalled)?.label ??
      snapshot.installed?.channel ??
      key.id;

  ActionDescriptor _uninstall(SourceKey key, PackageSourceSnapshot snapshot) =>
      _bind(
        ActionBinding(
          source: key,
          kind: ActionKind.uninstall,
          targetLabel: _installedLabel(key, snapshot),
          command: PackageCommand(
            kind: OperationKind.remove,
            targetId: snapshot.installed?.channel,
          ),
          disabledReason: _busy
              ? DisabledReason.busy
              : snapshot.capabilities.removeBlocked,
        ),
      );

  ActionDescriptor _install(
    SourceKey key,
    PackageSourceSnapshot snapshot,
    PackageTarget? target,
  ) {
    final candidate = target?.candidate;
    final installed = snapshot.installState == InstallState.installed;
    return _bind(
      ActionBinding(
        source: key,
        kind: installed ? ActionKind.switchChannel : ActionKind.install,
        targetLabel: target?.label ?? key.id,
        targetCandidate: candidate,
        command: PackageCommand(
          kind: installed ? OperationKind.switchChannel : OperationKind.install,
          targetId: target?.id,
          candidateId: candidate?.candidateId,
        ),
        disabledReason: switch (snapshot.installState) {
          _ when _busy => DisabledReason.busy,
          InstallState.unknown => DisabledReason.installStateUnknown,
          _ when candidate == null => DisabledReason.targetUnavailable,
          _ => null,
        },
      ),
    );
  }

  ActionsSection _actions(SourceKey key, PackageSourceSnapshot? snapshot) {
    final hasMoreActions =
        keys.map((k) => _snapshot(k)?.targets.length ?? 0).sum > 1;
    if (snapshot == null) return ActionsSection(hasMoreActions: hasMoreActions);

    final cancel = _cancelAction();
    final installed = snapshot.installState == InstallState.installed;
    final open = installed && snapshot.capabilities.canLaunch
        ? _bind(
            ActionBinding(
              source: key,
              kind: ActionKind.open,
              targetLabel: _installedLabel(key, snapshot),
              targetCandidate: snapshot.installed,
            ),
          )
        : null;
    final update = installed && snapshot.updateCandidate != null
        ? _bind(
            ActionBinding(
              source: key,
              kind: ActionKind.update,
              targetLabel: _installedLabel(key, snapshot),
              targetCandidate: snapshot.updateCandidate,
              command: PackageCommand(
                kind: OperationKind.update,
                targetId: snapshot.installed?.channel,
                candidateId: snapshot.updateCandidate!.candidateId,
              ),
              disabledReason: _busy
                  ? DisabledReason.busy
                  : snapshot.capabilities.updateBlocked,
            ),
          )
        : null;
    final uninstall = installed ? _uninstall(key, snapshot) : null;

    if (_busy) {
      return ActionsSection(
        primary: cancel,
        secondary: [?open, ?update, ?uninstall],
        hasMoreActions: hasMoreActions,
      );
    }

    switch (snapshot.installState) {
      case InstallState.unknown:
        return ActionsSection(hasMoreActions: hasMoreActions);
      case InstallState.notInstalled:
        final candidate = snapshot.installCandidate;
        final target = snapshot.targets.firstWhereOrNull(
          (t) => candidate != null && t.candidate == candidate,
        );
        return ActionsSection(
          primary: _install(key, snapshot, target),
          hasMoreActions: hasMoreActions,
        );
      case InstallState.installed:
        final primary = (update?.enabled ?? false)
            ? update
            : open ?? ((uninstall?.enabled ?? false) ? uninstall : null);
        return ActionsSection(
          primary: primary,
          secondary: [
            for (final action in [open, update, uninstall])
              if (action != null && action != primary) action,
          ],
          hasMoreActions: hasMoreActions,
        );
    }
  }

  ActionDescriptor? _cancelAction() {
    final op = ownedActive;
    if (op == null) return null;
    final observed = _snapshot(op.source)?.activeOperation;
    final cancellable =
        (op.phase == OperationPhase.starting ||
            op.phase == OperationPhase.running) &&
        (observed?.cancellable ?? false);
    if (!cancellable) return null;
    return _bind(
      ActionBinding(
        source: op.source,
        kind: ActionKind.cancel,
        targetLabel: op.targetLabel,
        operationId: op.id,
      ),
    );
  }

  List<TargetGroup> _targets() => [
    for (final key in keys)
      if (_snapshot(key) case final snapshot?)
        TargetGroup(
          sourceId: key.value,
          format: key.format,
          options: [
            for (final target in snapshot.targets)
              TargetOption(
                label: target.label,
                isInstalled: target.isInstalled,
                version: FieldState.fromNullable(target.candidate?.version),
                action: target.isInstalled
                    ? _uninstall(key, snapshot)
                    : _install(key, snapshot, target),
              ),
          ],
        ),
  ];

  OperationView? _operation() {
    final owned = ownedActive;
    if (owned != null) {
      final observed = _snapshot(owned.source)?.activeOperation;
      return OperationView(
        id: owned.id,
        sourceId: owned.source.value,
        format: owned.source.format,
        targetLabel: owned.targetLabel,
        kind: owned.command.kind,
        phase: owned.phase == OperationPhase.starting && observed != null
            ? OperationPhase.running
            : owned.phase,
        progress: observed?.progress,
        canCancel: _cancelAction() != null,
      );
    }
    final (key, observed) = _observed ?? (null, null);
    if (key == null || observed == null) return null;
    return OperationView(
      id: OperationId('observed:${key.value}'),
      sourceId: key.value,
      format: key.format,
      targetLabel: _snapshot(key)?.target(observed.targetId)?.label ?? key.id,
      kind: observed.kind,
      phase: OperationPhase.running,
      progress: observed.progress,
    );
  }

  (List<AppDetailsIssue>, Map<IssueId, OperationId>) _issues() {
    final issues = <AppDetailsIssue>[
      if (input.identity.discoveryFailed)
        const AppDetailsIssue(
          id: IssueId('discovery'),
          scope: IssueScope.discovery,
          kind: IssueKind.lookupFailed,
          retryable: true,
        ),
      for (final key in keys)
        if (_async(key) case final source? when source.hasError)
          AppDetailsIssue(
            id: IssueId('source:${key.value}'),
            scope: IssueScope.source,
            kind: source.hasValue
                ? IssueKind.loadFailed
                : IssueKind.sourceUnavailable,
            retryable: true,
            sourceId: key.value,
          ),
      if (snapKey != null && (input.ratings?.hasError ?? false))
        const AppDetailsIssue(
          id: IssueId('ratings'),
          scope: IssueScope.ratings,
          kind: IssueKind.loadFailed,
          retryable: true,
        ),
    ];
    final operationIssues = <IssueId, OperationId>{};
    for (final op in operations) {
      if (op.isActive || op.outcome != OperationOutcome.failed) continue;
      final id = IssueId('operation:${op.id.value}');
      operationIssues[id] = op.id;
      issues.add(
        AppDetailsIssue(
          id: id,
          scope: IssueScope.operation,
          kind: IssueKind.operationFailed,
          sourceId: op.source.value,
        ),
      );
    }
    return (
      issues
          .where((issue) => !input.acknowledgedIssues.contains(issue.id))
          .toList(),
      operationIssues,
    );
  }
}
