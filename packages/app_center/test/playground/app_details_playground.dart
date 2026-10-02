// Standalone playground for the unified app details ViewModel, driven by fakes.
// Run: fvm flutter run -d linux -t test/playground/app_details_playground.dart

import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/apps/app_details_model.dart';
import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/package_details_backend.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../test_utils.dart';

const _entry = AppDetailsEntry.snap('testsnap');
const _sourceKeys = [testSnapKey, testDebKey];
const _snapChannels = ['latest/stable', 'latest/beta'];

final _backend = FakePackageDetailsBackend();

final _identityProvider = StateProvider<ResolvedAppIdentity>(
  (ref) => createResolvedIdentity(),
);

final _ratingsProvider = StateProvider<AsyncValue<RatingsSummary?>>(
  (ref) => const AsyncData(
    RatingsSummary(band: RatingsBand.veryGood, totalVotes: 42),
  ),
);

/// Commands the fake backend has started but not yet finished.
final _pendingProvider = StateProvider<Map<SourceKey, PackageCommand>>(
  (ref) => const {},
);

final _logProvider = StateProvider<List<String>>((ref) => const []);

void _log(StateController<List<String>> log, String message) {
  final time = TimeOfDay.now();
  final stamp =
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
  log.update((entries) => [...entries, '$stamp $message']);
}

void main() {
  _backend.onExecute = (ref, key, command) {
    ref
        .read(_pendingProvider.notifier)
        .update((pending) => {...pending, key: command});
    _log(
      ref.read(_logProvider.notifier),
      'backend.execute ${key.value}: ${command.kind.name} '
      '(target: ${command.targetId}, candidate: ${command.candidateId})',
    );
  };

  runApp(
    ProviderScope(
      overrides: [
        packageDetailsBackendsProvider.overrideWithValue({
          PackageFormat.snap: _backend,
          PackageFormat.deb: _backend,
        }),
        appDetailsIdentityProvider(
          _entry,
        ).overrideWith((ref) async => ref.watch(_identityProvider)),
        appDetailsRatingsProvider(
          'testsnap',
        ).overrideWith((ref) => ref.watch(_ratingsProvider)),
        for (final key in _sourceKeys)
          fakeSnapshotProvider(
            key,
          ).overrideWith((ref) => AsyncData(createSourceSnapshot(key))),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.orange),
        home: const _Playground(),
      ),
    ),
  );
}

class _Playground extends StatelessWidget {
  const _Playground();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unified app details playground')),
      body: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 380, child: _ScenarioPanel()),
          VerticalDivider(width: 1),
          Expanded(child: _DetailsView()),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scenario controls
// ---------------------------------------------------------------------------

typedef _Preset = (
  String label,
  AsyncValue<PackageSourceSnapshot> Function(SourceKey key),
);

String _defaultTarget(SourceKey key) =>
    key.format == PackageFormat.snap ? 'latest/stable' : 'test-app';

final _presets = <_Preset>[
  ('Not installed', (k) => AsyncData(createSourceSnapshot(k))),
  (
    'Installed',
    (k) => AsyncData(
      createSourceSnapshot(k, installState: InstallState.installed),
    ),
  ),
  (
    'Installed from latest/beta',
    (k) => AsyncData(
      createSourceSnapshot(
        k,
        installState: InstallState.installed,
        installedChannel: 'latest/beta',
      ),
    ),
  ),
  (
    'Installed, launchable',
    (k) => AsyncData(
      createSourceSnapshot(
        k,
        installState: InstallState.installed,
        canLaunch: true,
      ),
    ),
  ),
  (
    'Installed, update available',
    (k) => AsyncData(
      createSourceSnapshot(
        k,
        installState: InstallState.installed,
        withUpdate: true,
        canLaunch: true,
      ),
    ),
  ),
  (
    'Update available, app running',
    (k) => AsyncData(
      createSourceSnapshot(
        k,
        installState: InstallState.installed,
        withUpdate: true,
        updateBlocked: DisabledReason.appRunning,
      ),
    ),
  ),
  (
    'Installed, protected (no remove)',
    (k) => AsyncData(
      createSourceSnapshot(
        k,
        installState: InstallState.installed,
        removeBlocked: DisabledReason.protectedPackage,
      ),
    ),
  ),
  (
    'Install state unknown',
    (k) =>
        AsyncData(createSourceSnapshot(k, installState: InstallState.unknown)),
  ),
  (
    'External install running (40%)',
    (k) => AsyncData(
      createSourceSnapshot(
        k,
        activeOperation: ObservedOperation(
          kind: OperationKind.install,
          targetId: _defaultTarget(k),
          progress: 0.4,
          cancellable: true,
        ),
      ),
    ),
  ),
  (
    'External removal running',
    (k) => AsyncData(
      createSourceSnapshot(
        k,
        installState: InstallState.installed,
        activeOperation: ObservedOperation(
          kind: OperationKind.remove,
          targetId: _defaultTarget(k),
        ),
      ),
    ),
  ),
  ('Loading', (k) => const AsyncLoading()),
  (
    'Backend error',
    (k) => AsyncError(Exception('backend unavailable'), StackTrace.current),
  ),
];

final _identityPresets = <(String, ResolvedAppIdentity)>[
  ('Snap + Deb', createResolvedIdentity()),
  ('Snap only', createResolvedIdentity(deb: false)),
  ('Deb only', createResolvedIdentity(snap: false)),
  (
    'Snap only, discovery failed',
    createResolvedIdentity(deb: false, discoveryFailed: true),
  ),
];

final _ratingsPresets = <(String, AsyncValue<RatingsSummary?>)>[
  (
    'Very good (42)',
    const AsyncData(RatingsSummary(band: RatingsBand.veryGood, totalVotes: 42)),
  ),
  (
    'Poor (7)',
    const AsyncData(RatingsSummary(band: RatingsBand.poor, totalVotes: 7)),
  ),
  ('No rating', const AsyncData(null)),
  ('Loading', const AsyncLoading()),
  (
    'Error',
    AsyncError(Exception('ratings unavailable'), StackTrace.current),
  ),
];

PackageSourceSnapshot _afterSuccess(
  SourceKey key,
  PackageCommand command,
  PackageSourceSnapshot? current,
) {
  final isSnap = key.format == PackageFormat.snap;
  final currentChannel = current?.installed?.channel ?? 'latest/stable';
  return switch (command.kind) {
    OperationKind.remove => createSourceSnapshot(key),
    OperationKind.update => createSourceSnapshot(
      key,
      installState: InstallState.installed,
      installedChannel: currentChannel,
      canLaunch: isSnap,
    ),
    OperationKind.install ||
    OperationKind.switchChannel => createSourceSnapshot(
      key,
      installState: InstallState.installed,
      installedChannel: isSnap && _snapChannels.contains(command.targetId)
          ? command.targetId!
          : 'latest/stable',
      canLaunch: isSnap,
    ),
  };
}

class _ScenarioPanel extends ConsumerWidget {
  const _ScenarioPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(_pendingProvider);
    final log = ref.watch(_logProvider);
    final logger = ref.read(_logProvider.notifier);

    void setSnapshot(SourceKey key, _Preset preset) {
      ref.read(fakeSnapshotProvider(key).notifier).state = preset.$2(key);
      _log(logger, 'snapshot ${key.value} := ${preset.$1}');
    }

    void keepLastValueWithError(SourceKey key) {
      final controller = ref.read(fakeSnapshotProvider(key).notifier);
      final current = controller.state;
      controller.state = AsyncError<PackageSourceSnapshot>(
        Exception('refresh failed'),
        StackTrace.current,
      ).copyWithPrevious(current);
      _log(logger, 'snapshot ${key.value} := error (keeping last value)');
    }

    void finish(SourceKey key, OperationOutcome outcome) {
      final command = ref.read(_pendingProvider)[key];
      if (command == null) return;
      if (outcome == OperationOutcome.success) {
        final current = ref.read(fakeSnapshotProvider(key)).valueOrNull;
        _backend.afterReconcile[key] = _afterSuccess(key, command, current);
      }
      ref.read(_pendingProvider.notifier).update((p) => {...p}..remove(key));
      _backend.complete(key, outcome);
      _log(logger, 'backend finished ${key.value}: ${outcome.name}');
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('Identity', style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final (label, identity) in _identityPresets)
              ActionChip(
                label: Text(label),
                onPressed: () {
                  ref.read(_identityProvider.notifier).state = identity;
                  _log(logger, 'identity := $label');
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Ratings', style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final (label, ratings) in _ratingsPresets)
              ActionChip(
                label: Text(label),
                onPressed: () {
                  ref.read(_ratingsProvider.notifier).state = ratings;
                  _log(logger, 'ratings := $label');
                },
              ),
          ],
        ),
        for (final key in _sourceKeys) ...[
          const Divider(height: 24),
          Text(
            'Source ${key.value}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          _SnapshotSummary(sourceKey: key),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final preset in _presets)
                ActionChip(
                  label: Text(preset.$1),
                  onPressed: () => setSnapshot(key, preset),
                ),
              ActionChip(
                label: const Text('Error, keep last value'),
                onPressed: () => keepLastValueWithError(key),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (pending[key] case final command?) ...[
            Text(
              'Pending backend command: ${command.kind.name} '
              '-> ${command.targetId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                FilledButton.tonal(
                  onPressed: () => finish(key, OperationOutcome.success),
                  child: const Text('Finish: success'),
                ),
                FilledButton.tonal(
                  onPressed: () => finish(key, OperationOutcome.failed),
                  child: const Text('Finish: failed'),
                ),
                FilledButton.tonal(
                  onPressed: () => finish(key, OperationOutcome.cancelled),
                  child: const Text('Finish: cancelled'),
                ),
              ],
            ),
          ] else
            const Text(
              'No pending backend command',
              style: TextStyle(color: Colors.grey),
            ),
        ],
        const Divider(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                'Event log',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton(
              onPressed: () => logger.state = const [],
              child: const Text('Clear'),
            ),
          ],
        ),
        for (final entry in log.reversed.take(50))
          Text(entry, style: const TextStyle(fontFamily: 'monospace')),
      ],
    );
  }
}

class _SnapshotSummary extends ConsumerWidget {
  const _SnapshotSummary({required this.sourceKey});

  final SourceKey sourceKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(fakeSnapshotProvider(sourceKey));
    final value = snapshot.valueOrNull;
    final parts = [
      if (snapshot.isLoading) 'loading',
      if (snapshot.hasError) 'error',
      if (value != null) ...[
        value.installState.name,
        if (value.installed?.channel case final channel?) 'on $channel',
        if (value.updateCandidate != null) 'update available',
        if (value.capabilities.canLaunch) 'launchable',
        if (value.activeOperation case final op?) 'external ${op.kind.name}',
      ],
    ];
    return Text(
      'Backend state: ${parts.join(', ')}',
      style: const TextStyle(color: Colors.grey),
    );
  }
}

// ---------------------------------------------------------------------------
// ViewModel output
// ---------------------------------------------------------------------------

String _field<T>(FieldState<T> field, [String Function(T value)? format]) {
  String show(T value) => format?.call(value) ?? '$value';
  return field.map(
    loading: (_) => '(loading)',
    value: (f) => '${show(f.value)}${f.stale ? '  [stale]' : ''}',
    unavailable: (_) => '(unavailable)',
    failed: (f) => f.lastKnown == null
        ? '(failed)'
        : '(failed, last known: ${show(f.lastKnown as T)})',
  );
}

String _size(ByteSize size) => '${size.bytes} B (${size.kind.name})';

String _date(DateTime date) => date.toIso8601String().split('T').first;

class _DetailsView extends ConsumerWidget {
  const _DetailsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(appDetailsModelProvider(_entry));
    final model = ref.read(appDetailsModelProvider(_entry).notifier);
    final state = async.valueOrNull;

    Future<void> run(ActionDescriptor action, String label) async {
      final receipt = await model.execute(action.id);
      _log(ref.read(_logProvider.notifier), 'execute $label -> $receipt');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$label: $receipt')));
    }

    Widget actionButton(
      ActionDescriptor action, {
      String? label,
      bool primary = false,
    }) {
      final text =
          '${label ?? action.kind.name}'
          '${action.disabledReason == null ? '' : ' (${action.disabledReason!.name})'}';
      final onPressed = action.enabled
          ? () => run(action, label ?? action.kind.name)
          : null;
      return primary
          ? FilledButton(onPressed: onPressed, child: Text(text))
          : OutlinedButton(onPressed: onPressed, child: Text(text));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Section(
          title: 'Provider state',
          children: [
            _Row(
              'AsyncValue',
              '${async.runtimeType}'
                  '${async.isLoading ? ' (loading)' : ''}',
            ),
            if (async.hasError) _Row('Error', '${async.error}'),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: model.refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('model.refresh()'),
              ),
            ),
          ],
        ),
        if (state != null) ...[
          _Section(
            title: 'Header',
            children: [
              _Row('Name', _field(state.app.name)),
              _Row('Summary', _field(state.app.summary)),
              _Row(
                'Publisher',
                _field(
                  state.activePackage.publisher,
                  (p) => '${p.name} (${p.validation.name})',
                ),
              ),
              _Row(
                'Ratings',
                _field(
                  state.app.ratings,
                  (r) => '${r.band.name}, ${r.totalVotes} votes',
                ),
              ),
              _Row('Icon', _field(state.app.icon)),
            ],
          ),
          _Section(
            title: 'Actions',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (state.actions.primary case final primary?)
                    actionButton(primary, primary: true)
                  else
                    const Text('(no primary action)'),
                  for (final action in state.actions.secondary)
                    actionButton(action),
                ],
              ),
              _Row('hasMoreActions', '${state.actions.hasMoreActions}'),
            ],
          ),
          _Section(
            title: 'Operation',
            children: [
              if (state.operation case final op?) ...[
                LinearProgressIndicator(value: op.progress),
                const SizedBox(height: 8),
                _Row('Kind', op.kind.name),
                _Row('Phase', op.phase.name),
                _Row('Target', '${op.format.name} ${op.targetLabel}'),
                _Row('Source', op.sourceId),
                _Row('Progress', '${op.progress ?? 'indeterminate'}'),
                _Row('Id', op.id.value),
                if (op.canCancel)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => model.cancel(op.id),
                      child: const Text('model.cancel()'),
                    ),
                  ),
              ] else
                const Text('(none)'),
            ],
          ),
          _Section(
            title: 'Active package',
            children: [
              _Row('Format', state.activePackage.format.name),
              _Row('Source', state.activePackage.sourceId),
              _Row('Install state', state.activePackage.installState.name),
              _Row('Reason', state.activePackage.reason.name),
              _Row('Channel', '${state.activePackage.channel}'),
              _Row(
                'Installed channel',
                '${state.activePackage.installedChannel}',
              ),
              _Row(
                'Confinement',
                _field(state.activePackage.confinement, (c) => c.name),
              ),
              _Row(
                'Categories',
                _field(
                  state.activePackage.categories,
                  (c) => c.map((e) => e.name).join(', '),
                ),
              ),
            ],
          ),
          _Section(
            title: 'Release',
            children: [
              _Row('Kind', '${state.release.kind?.name}'),
              _Row('Version', _field(state.release.version)),
              _Row('Size', _field(state.release.size, _size)),
              _Row('Release date', _field(state.release.releaseDate, _date)),
            ],
          ),
          _Section(
            title: 'Targets (format / channel picker)',
            children: [
              if (state.targets.isEmpty) const Text('(none)'),
              for (final group in state.targets) ...[
                Text(
                  '${group.format.name} (${group.sourceId})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in group.options)
                      if (option.action case final action?)
                        actionButton(
                          action,
                          label:
                              '${action.kind.name} ${option.label} '
                              '${_field(option.version)}'
                              '${option.isInstalled ? ' [installed]' : ''}',
                        )
                      else
                        Chip(
                          label: Text(
                            '${option.label} ${_field(option.version)}'
                            '${option.isInstalled ? ' [installed]' : ''}',
                          ),
                        ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
          _Section(
            title: 'Issues',
            children: [
              if (state.issues.isEmpty) const Text('(none)'),
              for (final issue in state.issues)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${issue.scope.name} / ${issue.kind.name}'
                        '${issue.sourceId == null ? '' : ' (${issue.sourceId})'}'
                        '  id=${issue.id.value}',
                      ),
                    ),
                    if (issue.retryable)
                      TextButton(
                        onPressed: () => model.retry(issue.id),
                        child: const Text('retry'),
                      ),
                    TextButton(
                      onPressed: () => model.acknowledge(issue.id),
                      child: const Text('acknowledge'),
                    ),
                  ],
                ),
            ],
          ),
          _Section(
            title: 'Description & media',
            children: [
              _Row(
                'Description',
                _field(
                  state.app.description,
                  (d) => '[${d.type.name}] ${d.text}',
                ),
              ),
              _Row(
                'Screenshots',
                _field(state.app.screenshots, (s) => s.join('\n')),
              ),
            ],
          ),
          _Section(
            title: 'Footer',
            children: [
              _Row(
                'Publisher',
                _field(state.footer.publisher, (p) => p.name),
              ),
              _Row('Last updated', _field(state.footer.lastUpdated, _date)),
              _Row('License', _field(state.footer.license)),
              _Row(
                'Age rating',
                _field(state.footer.ageRating, (a) => a.name),
              ),
              _Row(
                'Languages',
                _field(state.footer.languages, (l) => l.join(', ')),
              ),
              _Row(
                'Links',
                _field(
                  state.footer.links,
                  (l) => l.entries
                      .map((e) => '${e.key.name}: ${e.value}')
                      .join('\n'),
                ),
              ),
              _Row('Terms', _field(state.footer.terms)),
              _Row('Install date', _field(state.footer.installDate, _date)),
            ],
          ),
          Card(
            child: ExpansionTile(
              title: const Text('Raw AppDetailsViewState'),
              childrenPadding: const EdgeInsets.all(12),
              children: [
                SelectableText(
                  '$state',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
