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
    final moreActions = state.actions.secondary
        .where(
          (action) =>
              action.kind != ActionKind.uninstall &&
              action.kind != ActionKind.cancel,
        )
        .toList();
    final otherFormats = [
      for (final group in state.targets)
        if (group.format != state.activePackage.format)
          if (_formatAction(group) case final action?) (group.format, action),
    ];

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
            progress: operation.progress ?? 0,
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
        if (uninstall != null)
          OutlinedButton(
            onPressed: run(uninstall),
            child: Text(l10n.snapActionRemoveLabel),
          ),
        if (moreActions.isNotEmpty || otherFormats.isNotEmpty)
          YaruPopupMenuButton<void>(
            showArrow: false,
            semanticLabel: l10n.appMoreActionsSemanticLabel,
            childPadding: const EdgeInsets.symmetric(horizontal: 2),
            itemBuilder: (context) => [
              for (final action in moreActions)
                _menuItem(
                  _actionLabel(l10n, action.kind),
                  enabled: action.enabled,
                  onTap: run(action),
                ),
              for (final (format, action) in otherFormats)
                _menuItem(
                  '${_actionLabel(l10n, action.kind)} '
                  '${_formatLabel(l10n, format)}',
                  enabled: action.enabled,
                  onTap: run(action),
                ),
            ],
            child: const Icon(YaruIcons.view_more),
          ),
      ],
    );
  }

  /// Uninstalls the installed target, otherwise installs the default one.
  ActionDescriptor? _formatAction(TargetGroup group) {
    // No channel picker yet, so a Snap installs from latest/stable.
    final option =
        group.options.firstWhereOrNull((o) => o.isInstalled) ??
        group.options.firstWhereOrNull((o) => o.label == 'latest/stable') ??
        group.options.firstWhereOrNull((o) => o.action?.enabled ?? false);
    return option?.action;
  }

  PopupMenuItem<void> _menuItem(
    String label, {
    VoidCallback? onTap,
    bool enabled = true,
  }) => PopupMenuItem<void>(
    enabled: enabled,
    onTap: onTap,
    child: IntrinsicWidth(
      child: ListTile(
        mouseCursor: SystemMouseCursors.click,
        title: Text(label),
      ),
    ),
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
            value: Tooltip(
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
            ),
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
          value: Text(switch (active.format) {
            PackageFormat.snap => l10n.managePagePackageTypeSnap,
            PackageFormat.deb => l10n.managePagePackageTypeDeb,
          }),
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
    final languages = footer.languages.valueOrNull ?? const [];

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
            // Pending a decision on mapping OARS levels to ages.
            item(l10n.appDetailsAgeRatingLabel, notAvailable),
            item(
              l10n.appDetailsInstallDateLabel,
              installDate != null
                  ? _formatDate(installDate)
                  : active.installState == InstallState.installed
                  ? notAvailable
                  : l10n.appDetailsNotInstalled,
            ),
            item(
              l10n.appDetailsLanguagesLabel,
              languages.isEmpty ? notAvailable : languages.join(', '),
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
            item(
              l10n.appDetailsTermsLabel,
              footer.terms.valueOrNull ?? notAvailable,
            ),
          ],
        ),
      ],
    );
  }
}
