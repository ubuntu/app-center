import 'dart:async';
import 'dart:io';

import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/apps/app_details_model.dart';
import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/app_page.dart';
import 'package:app_center/apps/app_title_bar.dart';
import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/constants.dart';
import 'package:app_center/error/error.dart';
import 'package:app_center/extensions/string_extensions.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/local_snap_providers.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center/ratings/ratings_l10n.dart';
import 'package:app_center/widgets/hyperlink_text.dart';
import 'package:app_center/widgets/shimmer_placeholder.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yaru/yaru.dart';

/// Placeholder unified details page, laid out like the snap page.
class UnifiedAppPage extends ConsumerWidget {
  const UnifiedAppPage({required this.entry, super.key});

  final AppDetailsEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final details = ref.watch(appDetailsModelProvider(entry));

    if (details.error is AppNotFound) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && Navigator.canPop(context)) {
          ref.invalidate(filteredLocalSnapsProvider);
          Navigator.pop(context);
        }
      });
      return const Center(child: YaruCircularProgressIndicator());
    }

    return details.when(
      data: (state) => ResponsiveLayoutBuilder(
        builder: (_) => _UnifiedAppView(entry: entry, state: state),
      ),
      error: (error, stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(appDetailsIdentityProvider(entry)),
      ),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _UnifiedAppView extends StatelessWidget {
  const _UnifiedAppView({required this.entry, required this.state});

  final AppDetailsEntry entry;
  final AppDetailsViewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final layout = ResponsiveLayout.of(context);
    final app = state.app;
    final name = app.name.valueOrNull ?? app.appId;
    final publisher = state.activePackage.publisher.valueOrNull;
    final icon = app.icon.valueOrNull;
    final screenshots = app.screenshots.valueOrNull ?? const <String>[];
    final description = app.description.valueOrNull;
    final categories = _categoryLabels(l10n, state.activePackage.categories);

    return AppPage(
      titleBar: AppTitleBar(
        iconUrl: icon?.mapOrNull(network: (icon) => icon.url),
        iconWidget: icon?.mapOrNull(
          file: (icon) => Image.file(File(icon.path), width: 96, height: 96),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTitle(
              title: name,
              publisher: publisher?.name,
              verifiedPublisher:
                  publisher?.validation == PublisherValidation.verified,
              starredPublisher:
                  publisher?.validation == PublisherValidation.starred,
              large: true,
            ),
            if (categories.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                children: [
                  for (final (index, category) in categories.indexed) ...[
                    if (index > 0) const Text(', '),
                    // Category pages are not wired up yet.
                    HyperlinkText(text: category, onTap: () {}),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
      actionBar: _ActionBar(entry: entry, state: state),
      infoBar: _InfoBar(state: state),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            app.summary.valueOrNull ?? '',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: kPagePadding),
          if (screenshots.isNotEmpty) ...[
            ScreenshotGallery(
              title: name,
              urls: screenshots,
              height: layout.totalWidth / 2,
            ),
            const SizedBox(height: kSectionSpacing),
          ],
          if (description != null) ...[
            _Description(description: description),
            const SizedBox(height: kSectionSpacing),
          ],
          _AdditionalInfo(state: state),
        ],
      ),
    );
  }
}

List<String> _categoryLabels(
  AppLocalizations l10n,
  FieldState<List<AppCategory>> categories,
) => [
  for (final category in categories.valueOrNull ?? const <AppCategory>[])
    if (category != AppCategory.featured) category.localize(l10n),
];

String _formatDate(DateTime date) => DateFormat.yMMMd().format(date);

class _Description extends StatelessWidget {
  const _Description({required this.description});

  final RichContent description;

  @override
  Widget build(BuildContext context) => switch (description.type) {
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
  };
}

String _actionLabel(AppLocalizations l10n, ActionKind kind) => switch (kind) {
  ActionKind.install => l10n.snapActionInstallLabel,
  ActionKind.update => l10n.snapActionUpdateLabel,
  ActionKind.open => l10n.snapActionOpenLabel,
  ActionKind.uninstall => l10n.snapActionRemoveLabel,
  ActionKind.switchChannel => l10n.snapActionSwitchChannelLabel,
  ActionKind.cancel => l10n.snapActionCancelLabel,
};

String _operationLabel(AppLocalizations l10n, OperationKind kind) =>
    switch (kind) {
      OperationKind.install => l10n.snapActionInstallingLabel,
      OperationKind.update => l10n.snapActionUpdatingLabel,
      OperationKind.remove => l10n.snapActionRemovingLabel,
      OperationKind.switchChannel => l10n.snapActionSwitchChannelLabel,
    };

String _formatLabel(AppLocalizations l10n, PackageFormat format) =>
    switch (format) {
      PackageFormat.snap => l10n.managePagePackageTypeSnap,
      PackageFormat.deb => l10n.managePagePackageTypeDeb,
    };

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
    final uninstall = state.actions.secondary.firstWhereOrNull(
      (action) => action.kind == ActionKind.uninstall,
    );
    final otherActions = state.actions.secondary
        .where(
          (action) =>
              action.kind != ActionKind.uninstall &&
              action.kind != ActionKind.cancel,
        )
        .toList();

    VoidCallback? run(ActionDescriptor action) =>
        action.enabled ? () => unawaited(model.execute(action.id)) : null;

    return Wrap(
      runSpacing: kSpacing,
      spacing: kSpacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (operation != null)
          ActiveChangeStatus(
            key: ValueKey(operation.id),
            actionLabel: _operationLabel(l10n, operation.kind),
            progress: operation.progress,
            onCancelPressed: operation.canCancel
                ? () => unawaited(model.cancel(operation.id))
                : null,
          )
        else if (primary != null)
          YaruSplitButton(
            onPressed: run(primary),
            child: Text(
              _actionLabel(l10n, primary.kind),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        for (final action in otherActions)
          OutlinedButton(
            onPressed: run(action),
            child: Text(_actionLabel(l10n, action.kind)),
          ),
        if (uninstall != null)
          OutlinedButton(
            onPressed: run(uninstall),
            child: Text(l10n.snapActionRemoveLabel),
          ),
        if (state.formats.length > 1)
          YaruPopupMenuButton<void>(
            showArrow: false,
            semanticLabel: l10n.appMoreActionsSemanticLabel,
            childPadding: const EdgeInsets.symmetric(horizontal: 2),
            itemBuilder: (_) => [
              PopupMenuItem<void>(
                onTap: () => unawaited(showPackageFormatDialog(context, entry)),
                child: IntrinsicWidth(
                  child: ListTile(
                    mouseCursor: SystemMouseCursors.click,
                    title: Text(l10n.appDetailsChoosePackageFormatAction),
                  ),
                ),
              ),
            ],
            child: const Icon(YaruIcons.view_more),
          ),
      ],
    );
  }
}

class _InfoBar extends StatelessWidget {
  const _InfoBar({required this.state});

  final AppDetailsViewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = state.activePackage;
    final release = state.release;
    final size = release.size.valueOrNull;
    final confinement = active.confinement.valueOrNull;
    final version = release.version.valueOrNull ?? '';
    final channel = active.channel;
    final displayedVersion = channel == null || channel == 'latest/stable'
        ? version
        : '$channel $version';

    return Wrap(
      spacing: kPagePadding,
      runSpacing: 32,
      children: [
        ?_ratingsItem(context, l10n),
        if (confinement != null)
          _InfoItem(
            label: Text(l10n.snapPageConfinementLabel),
            value: _ConfinementLabel(confinement),
          ),
        _InfoItem(
          label: Text(l10n.snapPageVersionLabel),
          value: Tooltip(
            message: displayedVersion,
            child: Text(
              displayedVersion,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        _InfoItem(
          label: Text(
            size?.kind == SizeKind.installed
                ? l10n.snapPageSizeLabel
                : l10n.snapPageDownloadSizeLabel,
          ),
          value: Text(size == null ? '' : context.formatByteSize(size.bytes)),
        ),
        _InfoItem(
          label: Text(l10n.appDetailsPackageFormatLabel),
          value: Text(_formatLabel(l10n, active.format)),
        ),
      ],
    );
  }

  Widget? _ratingsItem(BuildContext context, AppLocalizations l10n) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    Widget shimmer(Widget child) => Shimmer.fromColors(
      baseColor: isLightTheme ? kShimmerBaseLight : kShimmerBaseDark,
      highlightColor: isLightTheme
          ? kShimmerHighLightLight
          : kShimmerHighLightDark,
      child: ShimmerPlaceholder(child: child),
    );

    return state.app.ratings.mapOrNull(
      loading: (_) => _InfoItem(
        label: shimmer(Text(RatingsBand.insufficientVotes.localize(l10n))),
        value: shimmer(Text(l10n.snapRatingsVotes(0))),
      ),
      value: (field) => _InfoItem(
        label: Text(
          field.value.band.localize(l10n),
          style: TextStyle(
            color: field.value.band.getColor(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        value: Text(l10n.snapRatingsVotes(field.value.totalVotes)),
      ),
    );
  }
}

class _ConfinementLabel extends StatelessWidget {
  const _ConfinementLabel(this.confinement);

  final AppConfinement confinement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Tooltip(
      constraints: const BoxConstraints(maxWidth: 200),
      message: confinement.localizeTooltip(l10n) ?? '',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (confinement == AppConfinement.strict) ...const [
            Icon(YaruIcons.shield, size: 12),
            SizedBox(width: 2),
          ],
          Text(confinement.localize(l10n)),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});

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
          SelectionArea(
            focusNode: FocusNode(canRequestFocus: false),
            child: DefaultTextStyle.merge(
              style: const TextStyle(fontWeight: FontWeight.w500),
              child: value,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdditionalInfo extends StatelessWidget {
  const _AdditionalInfo({required this.state});

  final AppDetailsViewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = state.activePackage;
    final footer = state.footer;
    final notAvailable = l10n.appDetailsNotAvailable;
    final categories = _categoryLabels(l10n, active.categories);
    final links = footer.links.valueOrNull ?? const {};
    final installDate = footer.installDate.valueOrNull;
    final releaseDate = state.release.releaseDate.valueOrNull;

    _InfoItem item(String label, String value) =>
        _InfoItem(label: Text(label), value: Text(value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.appDetailsAdditionalInfoLabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: kPagePadding),
        Wrap(
          spacing: kPagePadding,
          runSpacing: 32,
          children: [
            item(
              l10n.snapPagePublisherLabel,
              footer.publisher.valueOrNull?.name ?? notAvailable,
            ),
            item(
              l10n.snapPagePublishedLabel,
              releaseDate == null
                  ? l10n.appPublishedUnknown
                  : _formatDate(releaseDate),
            ),
            item(
              l10n.snapPageLicenseLabel,
              footer.license.valueOrNull ?? l10n.appLicenseUnknown,
            ),
            item(
              l10n.appDetailsCategoryLabel,
              categories.isEmpty ? notAvailable : categories.join(', '),
            ),
            item(
              l10n.appDetailsInstallDateLabel,
              installDate != null
                  ? _formatDate(installDate)
                  : active.installState == InstallState.installed
                  ? notAvailable
                  : l10n.appDetailsNotInstalled,
            ),
            _InfoItem(
              label: Text(l10n.snapPageLinksLabel),
              value: links.isEmpty
                  ? Text(notAvailable)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final MapEntry(key: type, value: url)
                            in links.entries)
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
        ),
      ],
    );
  }
}

Future<void> showPackageFormatDialog(
  BuildContext context,
  AppDetailsEntry entry,
) => showDialog(
  context: context,
  builder: (_) => PackageFormatDialog(entry: entry),
);

/// Compares the package formats of an app and installs or removes them.
class PackageFormatDialog extends ConsumerWidget {
  const PackageFormatDialog({required this.entry, super.key});

  final AppDetailsEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(appDetailsModelProvider(entry)).valueOrNull;
    final installed = [
      for (final option in state?.formats ?? const <FormatOption>[])
        if (option.installState == InstallState.installed) option.format,
    ];

    return SimpleDialog(
      contentPadding: kDialogContentPadding,
      titlePadding: EdgeInsets.zero,
      title: YaruDialogTitleBar(
        title: Text(l10n.appDetailsChoosePackageFormatTitle),
      ),
      children: [
        if (state == null)
          const Center(child: YaruCircularProgressIndicator())
        else ...[
          if (installed.isNotEmpty) ...[
            YaruInfoBox(
              yaruInfoType: YaruInfoType.warning,
              title: Text(
                installed.length == 1
                    ? l10n.appDetailsInstalledAsFormat(
                        _formatLabel(l10n, installed.single),
                      )
                    : l10n.appDetailsInstalledAsMultipleFormats,
              ),
              subtitle: Text(l10n.appDetailsPackageFormatDataNotShared),
            ),
            const SizedBox(height: kSpacing),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _FormatTable(entry: entry, state: state),
          ),
          const SizedBox(height: kPagePadding),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: HyperlinkText(
              text: l10n.appDetailsPackageFormatsLearnMore,
              link: packageFormatsDocsUrl,
            ),
          ),
        ],
      ],
    );
  }
}

class _FormatTable extends ConsumerWidget {
  const _FormatTable({required this.entry, required this.state});

  final AppDetailsEntry entry;
  final AppDetailsViewState state;

  static const _missing = '—';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final model = ref.read(appDetailsModelProvider(entry).notifier);
    final operation = state.operation;

    Widget cell(Widget child) =>
        Padding(padding: const EdgeInsets.all(kSpacing), child: child);
    Widget header(String label) => cell(
      Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
      ),
    );
    Widget text(String? value) => cell(Text(value ?? _missing));

    Widget action(FormatOption option) {
      if (operation != null && operation.sourceId == option.sourceId) {
        return OutlinedButton(
          onPressed: null,
          child: Text(_operationLabel(l10n, operation.kind)),
        );
      }
      final action = option.action;
      if (action == null) return const SizedBox.shrink();
      return OutlinedButton(
        onPressed: action.enabled
            ? () => unawaited(model.execute(action.id))
            : null,
        child: Text(_actionLabel(l10n, action.kind)),
      );
    }

    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(
        horizontalInside: BorderSide(color: theme.dividerColor),
      ),
      children: [
        TableRow(
          children: [
            header(l10n.appDetailsPackageFormatLabel),
            header(l10n.snapPagePublisherLabel),
            header(l10n.appDetailsPackageSourceLabel),
            header(l10n.snapPageChannelLabel),
            header(l10n.snapPageVersionLabel),
            header(l10n.snapPageConfinementLabel),
            header(l10n.snapPagePublishedLabel),
            header(l10n.snapPageSizeLabel),
            const SizedBox.shrink(),
          ],
        ),
        for (final option in state.formats)
          TableRow(
            key: ValueKey(option.sourceId),
            children: [
              cell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatLabel(l10n, option.format),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (option.installState == InstallState.installed)
                      Text(
                        l10n.snapActionInstalledLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.success,
                        ),
                      ),
                  ],
                ),
              ),
              cell(_PublisherLabel(option.publisher.valueOrNull)),
              text(switch (option.format) {
                PackageFormat.snap => l10n.appDetailsPackageSourceSnapStore,
                PackageFormat.deb => l10n.appDetailsPackageSourceUbuntuArchive,
              }),
              text(option.channel),
              cell(
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: Tooltip(
                    message: option.version.valueOrNull ?? '',
                    child: Text(
                      option.version.valueOrNull ?? _missing,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              cell(
                switch (option.confinement.valueOrNull) {
                  final confinement? => _ConfinementLabel(confinement),
                  null => const Text(_missing),
                },
              ),
              text(switch (option.releaseDate.valueOrNull) {
                final date? => _formatDate(date),
                null => null,
              }),
              text(switch (option.size.valueOrNull) {
                final size? => context.formatByteSize(size.bytes),
                null => null,
              }),
              cell(action(option)),
            ],
          ),
      ],
    );
  }
}

class _PublisherLabel extends StatelessWidget {
  const _PublisherLabel(this.publisher);

  final Publisher? publisher;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final validation = publisher?.validation ?? PublisherValidation.none;
    final verified = validation == PublisherValidation.verified;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              publisher?.name ?? l10n.unknownPublisher,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (validation != PublisherValidation.none)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 4),
              child: Icon(
                verified ? Icons.verified : Icons.stars,
                size: 14,
                color: MediaQuery.highContrastOf(context)
                    ? theme.hintColor
                    : verified
                    ? theme.colorScheme.success
                    : theme.colorScheme.warning,
              ),
            ),
        ],
      ),
    );
  }
}
