// Live playground for the unified app details page, backed by real snapd/PackageKit.
// Run: fvm flutter run -d linux -t test/playground/app_details_live.dart

import 'dart:async';
import 'dart:io';

import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/apps/app_details_model.dart';
import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/app_page.dart';
import 'package:app_center/apps/app_title_bar.dart';
import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/appstream/appstream.dart';
import 'package:app_center/config.dart';
import 'package:app_center/drivers/drivers.dart';
import 'package:app_center/error/error.dart';
import 'package:app_center/extensions/string_extensions.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/mapping/mapping.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:app_center/providers/error_stream_provider.dart';
import 'package:app_center/ratings/ratings.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/widgets/hyperlink_text.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github/github.dart';
import 'package:gtk/gtk.dart';
import 'package:intl/intl.dart';
import 'package:packagekit/packagekit.dart';
import 'package:snapcraft_launcher/snapcraft_launcher.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';

const _presets = <(String, AppDetailsEntry)>[
  ('VLC', AppDetailsEntry.snap('vlc')),
  ('GNOME Calculator', AppDetailsEntry.snap('gnome-calculator')),
  ('GIMP', AppDetailsEntry.snap('gimp')),
  ('Inkscape', AppDetailsEntry.snap('inkscape')),
  ('LibreOffice', AppDetailsEntry.snap('libreoffice')),
  ('Spotify (snap only)', AppDetailsEntry.snap('spotify')),
  ('VS Code (classic snap only)', AppDetailsEntry.snap('code')),
  ('Hello World (tiny snap)', AppDetailsEntry.snap('hello-world')),
  ('VLC, opened from Deb', AppDetailsEntry.debComponent('org.videolan.vlc')),
];

final _entryProvider = StateProvider<AppDetailsEntry>(
  (ref) => _presets.first.$2,
);

Future<void> main(List<String> args) async {
  final snapd = SnapdService();
  await snapd.loadAuthorization();
  registerServiceInstance(snapd);

  final launcher = PrivilegedDesktopLauncher();
  await launcher.connect();
  registerServiceInstance(launcher);

  final config = ConfigService()..load();
  registerServiceInstance(config);
  // Outside the snap the ratings config defaults to localhost.
  final ratingsClient = Platform.environment['RATINGS_SERVICE_URL'] == null
      ? RatingsClient('ratings.ubuntu.com', 443, true)
      : RatingsClient(
          config.ratingServiceUrl,
          config.ratingsServicePort,
          config.ratingsServiceUseTls,
        );
  registerServiceInstance(RatingsService(ratingsClient));

  registerService(GitHub.new);
  registerService(() => GtkApplicationNotifier(args));

  final appstream = AppstreamService();
  unawaited(appstream.init());
  registerServiceInstance(appstream);

  registerService(PackageKitClient.new);
  registerService(
    PackageKitService.new,
    dispose: (service) => service.dispose(),
  );
  registerService(
    () => DebPackageAdapter(
      appstream: getService<AppstreamService>(),
      packageKit: getService<PackageKitService>(),
    ),
  );
  registerService(() => SnapPackageAdapter(snapd: getService<SnapdService>()));
  registerService(
    () => PackageMappingService(
      adapters: [
        getService<DebPackageAdapter>(),
        getService<SnapPackageAdapter>(),
      ],
    ),
  );
  registerService(
    () => PackageRuntimeStateService(
      adapters: [
        getService<DebPackageAdapter>(),
        getService<SnapPackageAdapter>(),
      ],
    ),
  );
  registerService(
    DriversService.new,
    dispose: (service) => service.dispose(),
  );
  registerService(
    ErrorStreamController.new,
    dispose: (controller) => controller.close(),
  );

  await initDefaultLocale();
  await YaruWindowTitleBar.ensureInitialized();

  runApp(const ProviderScope(child: _LiveApp()));
}

class _LiveApp extends StatelessWidget {
  const _LiveApp();

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaru, child) => MaterialApp(
        theme: yaru.theme,
        darkTheme: yaru.darkTheme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        home: const _Home(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shell: app picker + debug drawer
// ---------------------------------------------------------------------------

class _Home extends ConsumerStatefulWidget {
  const _Home();

  @override
  ConsumerState<_Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<_Home> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String text) {
    final value = text.trim();
    if (value.isEmpty) return;
    ref.read(_entryProvider.notifier).state = value.startsWith('deb:')
        ? AppDetailsEntry.debComponent(value.substring(4).trim())
        : AppDetailsEntry.snap(value);
  }

  @override
  Widget build(BuildContext context) {
    final entry = ref.watch(_entryProvider);
    final isPreset = _presets.any((preset) => preset.$2 == entry);

    ref.listen(errorStreamProvider, (_, error) {
      if (!error.hasValue) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.value}')),
      );
    });

    return Scaffold(
      appBar: YaruWindowTitleBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<AppDetailsEntry>(
              value: isPreset ? entry : null,
              hint: Text('$entry'),
              underline: const SizedBox.shrink(),
              items: [
                for (final (label, presetEntry) in _presets)
                  DropdownMenuItem(value: presetEntry, child: Text(label)),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(_entryProvider.notifier).state = value;
                }
              },
            ),
            const SizedBox(width: kSpacing),
            SizedBox(
              width: 300,
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'snap name, or deb:<appstream id>',
                ),
                onSubmitted: _submit,
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => YaruIconButton(
              tooltip: 'Debug state',
              icon: const Icon(Icons.bug_report_outlined),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(width: 560, child: _DebugPanel(entry: entry)),
      body: _UnifiedAppPage(key: ValueKey(entry), entry: entry),
    );
  }
}

class _DebugPanel extends ConsumerWidget {
  const _DebugPanel({required this.entry});

  final AppDetailsEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identity = ref.watch(appDetailsIdentityProvider(entry));
    final state = ref.watch(appDetailsModelProvider(entry));
    const mono = TextStyle(fontFamily: 'monospace', fontSize: 12);

    return ListView(
      padding: const EdgeInsets.all(kSpacing),
      children: [
        Text('Entry', style: Theme.of(context).textTheme.titleMedium),
        SelectableText('$entry', style: mono),
        const Divider(height: kPagePadding),
        Text(
          'Resolved identity',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SelectableText('$identity', style: mono),
        const Divider(height: kPagePadding),
        Text(
          'AppDetailsViewState',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SelectableText('$state', style: mono),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Unified page
// ---------------------------------------------------------------------------

class _UnifiedAppPage extends ConsumerWidget {
  const _UnifiedAppPage({required this.entry, super.key});

  final AppDetailsEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(appDetailsModelProvider(entry));
    return async.when(
      data: (state) => _AppView(entry: entry, state: state),
      error: (error, _) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(appDetailsIdentityProvider(entry)),
      ),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _AppView extends ConsumerWidget {
  const _AppView({required this.entry, required this.state});

  final AppDetailsEntry entry;
  final AppDetailsViewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.read(appDetailsModelProvider(entry).notifier);
    final publisher = state.activePackage.publisher.valueOrNull;
    final icon = state.app.icon.valueOrNull;

    return AppPage(
      titleBar: AppTitleBar(
        iconUrl: icon?.mapOrNull(network: (ref) => ref.url),
        iconWidget: icon?.mapOrNull(
          file: (ref) => Image.file(File(ref.path), width: 96, height: 96),
        ),
        title: AppTitle(
          title: state.app.name.valueOrNull ?? state.app.appId,
          publisher: publisher?.name,
          verifiedPublisher:
              publisher?.validation == PublisherValidation.verified,
          starredPublisher:
              publisher?.validation == PublisherValidation.starred,
          large: true,
        ),
        banner: state.issues.isEmpty
            ? null
            : _IssuesBanner(issues: state.issues, model: model),
        actions: YaruIconButton(
          tooltip: 'Refresh (no automatic polling yet)',
          icon: const Icon(YaruIcons.refresh),
          onPressed: model.refresh,
        ),
      ),
      actionBar: _ActionBar(entry: entry, state: state),
      infoBar: _InfoBar(state: state),
      body: _Body(state: state),
    );
  }
}

class _IssuesBanner extends StatelessWidget {
  const _IssuesBanner({required this.issues, required this.model});

  final List<AppDetailsIssue> issues;
  final AppDetailsModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: kSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final issue in issues)
            Row(
              children: [
                Icon(
                  YaruIcons.warning,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: kSpacingSmall),
                Flexible(
                  child: Text(
                    '${issue.scope.name}: ${issue.kind.name}'
                    '${issue.sourceId == null ? '' : ' (${issue.sourceId})'}',
                  ),
                ),
                if (issue.retryable)
                  TextButton(
                    onPressed: () => model.retry(issue.id),
                    child: const Text('Retry'),
                  ),
                TextButton(
                  onPressed: () => model.acknowledge(issue.id),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Actions
// ---------------------------------------------------------------------------

String _actionLabel(AppLocalizations l10n, ActionKind kind) => switch (kind) {
  ActionKind.install => l10n.snapActionInstallLabel,
  ActionKind.update => l10n.snapActionUpdateLabel,
  ActionKind.open => l10n.snapActionOpenLabel,
  ActionKind.uninstall => l10n.snapActionRemoveLabel,
  ActionKind.switchChannel => l10n.snapActionSwitchChannelLabel,
  ActionKind.cancel => l10n.snapActionCancelLabel,
};

String _formatLabel(PackageFormat format) => switch (format) {
  PackageFormat.snap => 'Snap',
  PackageFormat.deb => 'Deb',
};

Future<void> _execute(
  BuildContext context,
  WidgetRef ref,
  AppDetailsEntry entry,
  ActionDescriptor action, {
  String? confirmTarget,
}) async {
  if (action.kind == ActionKind.uninstall) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${confirmTarget ?? 'this app'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
  }
  final receipt = await ref
      .read(appDetailsModelProvider(entry).notifier)
      .execute(action.id);
  if (receipt is RejectedCommand && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Rejected: ${receipt.reason.name}')),
    );
  }
}

class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.entry, required this.state});

  final AppDetailsEntry entry;
  final AppDetailsViewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final model = ref.read(appDetailsModelProvider(entry).notifier);
    final operation = state.operation;
    final primary = state.actions.primary;
    final activeLabel = _formatLabel(state.activePackage.format);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: kSpacing,
          runSpacing: kSpacing,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (operation != null)
              ActiveChangeStatus(
                key: ValueKey(operation.id),
                actionLabel:
                    '${operation.kind.name} ${_formatLabel(operation.format)} '
                    '${operation.targetLabel} (${operation.phase.name})',
                progress: operation.progress ?? 0,
                onCancelPressed: operation.canCancel
                    ? () => model.cancel(operation.id)
                    : null,
              )
            else if (primary != null)
              _ActionButton(
                entry: entry,
                action: primary,
                primary: true,
                target: activeLabel,
              ),
            for (final action in state.actions.secondary)
              if (action.kind != ActionKind.cancel)
                _ActionButton(
                  entry: entry,
                  action: action,
                  target: activeLabel,
                ),
            if (operation == null && primary == null)
              Text(
                'No actions (${state.activePackage.installState.name})',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        const SizedBox(height: kPagePadding),
        Text(
          'Available as',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: kSpacingSmall),
        Wrap(
          spacing: kSpacing,
          runSpacing: kSpacing,
          children: [
            for (final group in state.targets)
              _FormatCard(
                entry: entry,
                group: group,
                isActive: group.format == state.activePackage.format,
                busy: operation != null,
              ),
            if (state.targets.isEmpty) Text(l10n.appConfinementUnknown),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends ConsumerWidget {
  const _ActionButton({
    required this.entry,
    required this.action,
    required this.target,
    this.primary = false,
  });

  final AppDetailsEntry entry;
  final ActionDescriptor action;
  final String target;
  final bool primary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final onPressed = action.enabled
        ? () => _execute(context, ref, entry, action, confirmTarget: target)
        : null;
    final label = Text(_actionLabel(l10n, action.kind));
    final button = primary
        ? YaruSplitButton(onPressed: onPressed, child: label)
        : OutlinedButton(onPressed: onPressed, child: label);
    return action.disabledReason == null
        ? button
        : Tooltip(
            message: 'Disabled: ${action.disabledReason!.name}',
            child: button,
          );
  }
}

/// One package format with its install state and install/remove action.
class _FormatCard extends ConsumerWidget {
  const _FormatCard({
    required this.entry,
    required this.group,
    required this.isActive,
    required this.busy,
  });

  final AppDetailsEntry entry;
  final TargetGroup group;
  final bool isActive;
  final bool busy;

  TargetOption? get _option =>
      group.options.where((o) => o.isInstalled).firstOrNull ??
      group.options.where((o) => o.label == 'latest/stable').firstOrNull ??
      group.options.firstOrNull;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final option = _option;
    final action = option?.action;
    final format = _formatLabel(group.format);
    final isSnap = group.format == PackageFormat.snap;
    final installedChannels = group.options
        .where((o) => o.isInstalled)
        .map((o) => o.label)
        .join(', ');

    return Container(
      width: 280,
      padding: const EdgeInsets.all(kSpacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? theme.colorScheme.primary : theme.dividerColor,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(format, style: theme.textTheme.titleMedium),
              const Spacer(),
              if (isActive)
                Text(
                  'Shown',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: kSpacingSmall),
          Text(
            installedChannels.isNotEmpty
                ? isSnap
                      ? 'Installed from $installedChannels'
                      : 'Installed'
                : 'Not installed',
          ),
          if (option != null) ...[
            if (isSnap) Text('Channel: ${option.label}'),
            Text(
              '${l10n.snapPageVersionLabel}: '
              '${option.version.valueOrNull ?? '-'}',
            ),
          ] else
            const Text('No releases available'),
          const SizedBox(height: kSpacingSmall),
          if (action != null)
            Tooltip(
              message: action.disabledReason == null
                  ? ''
                  : 'Disabled: ${action.disabledReason!.name}',
              child: OutlinedButton(
                onPressed: action.enabled
                    ? () => _execute(
                        context,
                        ref,
                        entry,
                        action,
                        confirmTarget: 'the $format',
                      )
                    : null,
                child: Text(
                  action.kind == ActionKind.uninstall
                      ? '${l10n.snapActionRemoveLabel} $format'
                      : isActive
                      ? '${_actionLabel(l10n, action.kind)} $format'
                      : 'Switch to $format (${_actionLabel(l10n, action.kind)})',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info bar and body
// ---------------------------------------------------------------------------

String _text<T>(FieldState<T> field, [String Function(T value)? format]) {
  String show(T value) => format?.call(value) ?? '$value';
  return field.map(
    loading: (_) => '...',
    value: (f) => '${show(f.value)}${f.stale ? ' (stale)' : ''}',
    unavailable: (_) => '-',
    failed: (f) => f.lastKnown == null
        ? 'Failed to load'
        : '${show(f.lastKnown as T)} (stale)',
  );
}

class _InfoBar extends StatelessWidget {
  const _InfoBar({required this.state});

  final AppDetailsViewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = state.activePackage;
    final release = state.release;
    final footer = state.footer;
    final ratings = state.app.ratings.valueOrNull;
    final links = footer.links.valueOrNull ?? const {};
    String date(DateTime d) => DateFormat.yMMMd().format(d);

    return Wrap(
      spacing: kPagePadding,
      runSpacing: 32,
      children: [
        if (ratings != null)
          _InfoItem(
            label: Text(
              ratings.band.localize(l10n),
              style: TextStyle(
                color: ratings.band.getColor(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            value: Text(l10n.snapRatingsVotes(ratings.totalVotes)),
          ),
        _InfoItem.text(
          'Package',
          '${_formatLabel(active.format)} (${active.reason.name})',
        ),
        if (active.channel != null)
          _InfoItem.text(
            'Channel',
            active.installedChannel == null ||
                    active.installedChannel == active.channel
                ? active.channel!
                : '${active.channel} (installed: ${active.installedChannel})',
          ),
        _InfoItem.text(
          release.size.valueOrNull?.kind == SizeKind.installed
              ? 'Installed size'
              : l10n.snapPageDownloadSizeLabel,
          _text(release.size, (s) => context.formatByteSize(s.bytes)),
        ),
        _InfoItem(
          label: Text(l10n.snapPageConfinementLabel),
          value: Tooltip(
            message:
                active.confinement.valueOrNull?.localizeTooltip(l10n) ?? '',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (active.confinement.valueOrNull ==
                    AppConfinement.strict) ...const [
                  Icon(YaruIcons.shield, size: 12),
                  SizedBox(width: 2),
                ],
                Text(_text(active.confinement, (c) => c.localize(l10n))),
              ],
            ),
          ),
        ),
        _InfoItem.text(
          l10n.snapPageVersionLabel,
          '${_text(release.version)}'
          '${release.kind == null ? '' : ' (${release.kind!.name})'}',
        ),
        _InfoItem.text(
          l10n.snapPagePublishedLabel,
          _text(release.releaseDate, date),
        ),
        _InfoItem.text(
          l10n.snapPageLicenseLabel,
          footer.license.valueOrNull ?? l10n.appLicenseUnknown,
        ),
        _InfoItem.text(
          'Categories',
          _text(
            active.categories,
            (c) => c.map((e) => e.localize(l10n)).join(', '),
          ),
        ),
        if (footer.ageRating.valueOrNull case final rating?)
          _InfoItem.text('Age rating', rating.name),
        if (footer.installDate.valueOrNull case final installed?)
          _InfoItem.text('Installed on', date(installed)),
        if (footer.languages.valueOrNull case final languages?)
          _InfoItem.text('Languages', languages.join(', ')),
        if (links.isNotEmpty)
          _InfoItem(
            label: Text(l10n.snapPageLinksLabel),
            value: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final MapEntry(key: type, value: url) in links.entries)
                  HyperlinkText(
                    text: switch (type) {
                      AppLink.homepage => l10n.appUrlTypeHomepage,
                      AppLink.contact => l10n.appUrlTypeContact(
                        footer.publisher.valueOrNull?.name ?? '',
                      ),
                      AppLink.unknown => l10n.appUrlTypeUnknown,
                    },
                    link: url,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});

  _InfoItem.text(String label, String value)
    : this(label: Text(label), value: Text(value));

  final Widget label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveLayout.of(context);
    return SizedBox(
      width:
          (layout.totalWidth -
              (layout.snapInfoColumnCount - 1) * kPagePadding) /
          layout.snapInfoColumnCount,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label,
          DefaultTextStyle.merge(
            style: const TextStyle(fontWeight: FontWeight.w500),
            child: value,
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final AppDetailsViewState state;

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveLayout.of(context);
    final screenshots = state.app.screenshots.valueOrNull ?? const [];
    final description = state.app.description.valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (screenshots.isNotEmpty) ...[
          ScreenshotGallery(
            title: state.app.name.valueOrNull ?? '',
            urls: screenshots,
            height: layout.totalWidth / 2,
          ),
          const SizedBox(height: kSectionSpacing),
        ],
        Text(
          _text(state.app.summary),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: kPagePadding),
        if (description != null)
          switch (description.type) {
            RichContentType.markdown => MarkdownBody(
              selectable: true,
              data: description.text.escapedMarkdown(),
            ),
            RichContentType.html => Html(
              data: description.text,
              style: {
                'body': Style(margin: Margins.zero, padding: HtmlPaddings.zero),
              },
            ),
            RichContentType.plain => SelectableText(description.text),
          }
        else
          Text(_text(state.app.description)),
      ],
    );
  }
}
