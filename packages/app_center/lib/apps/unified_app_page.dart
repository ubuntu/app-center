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
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center/ratings/ratings_l10n.dart';
import 'package:app_center/snapd/snap_report.dart';
import 'package:app_center/store/store_app.dart';
import 'package:app_center/widgets/hyperlink_text.dart';
import 'package:app_center/widgets/shimmer_placeholder.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
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
    final layout = ResponsiveLayout.of(context);
    final app = state.app;
    final name = app.name.valueOrNull ?? app.appId;
    final publisher = state.activePackage.publisher.valueOrNull;
    final icon = app.icon.valueOrNull;
    final screenshots = app.screenshots.valueOrNull ?? const <String>[];
    final description = app.description.valueOrNull;
    final snapName = entry.mapOrNull(snap: (entry) => entry.snapName);

    return AppPage(
      titleBar: AppTitleBar(
        iconUrl: icon?.mapOrNull(network: (icon) => icon.url),
        iconWidget: icon?.mapOrNull(
          file: (icon) => Image.file(File(icon.path), width: 96, height: 96),
        ),
        title: AppTitle(
          title: name,
          publisher: publisher?.name,
          verifiedPublisher:
              publisher?.validation == PublisherValidation.verified,
          starredPublisher:
              publisher?.validation == PublisherValidation.starred,
          large: true,
        ),
        actions: snapName == null
            ? null
            : _IconRow(snapName: snapName, title: name),
      ),
      actionBar: _ActionBar(entry: entry, state: state),
      infoBar: _InfoBar(state: state),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (screenshots.isNotEmpty) ...[
            ScreenshotGallery(
              title: name,
              urls: screenshots,
              height: layout.totalWidth / 2,
            ),
            const SizedBox(height: kSectionSpacing),
          ],
          Text(
            app.summary.valueOrNull ?? '',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: kPagePadding),
          if (description != null) _Description(description: description),
        ],
      ),
    );
  }
}

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
    final footer = state.footer;
    final size = release.size.valueOrNull;
    final confinement = active.confinement.valueOrNull;
    final published = release.releaseDate.valueOrNull;
    final links = footer.links.valueOrNull ?? const {};

    return Wrap(
      spacing: kPagePadding,
      runSpacing: 32,
      children: [
        ?_ratingsItem(context, l10n),
        _InfoItem(
          label: Text(
            size?.kind == SizeKind.installed
                ? l10n.snapPageSizeLabel
                : l10n.snapPageDownloadSizeLabel,
          ),
          value: Text(size == null ? '' : context.formatByteSize(size.bytes)),
        ),
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
          value: Text(release.version.valueOrNull ?? ''),
        ),
        if (active.channel != null)
          _InfoItem(
            label: Text(l10n.snapPageChannelLabel),
            value: Text(active.channel!),
          ),
        _InfoItem(
          label: Text(l10n.snapPagePublishedLabel),
          value: Text(
            published != null
                ? DateFormat.yMMMd().format(published)
                : l10n.appPublishedUnknown,
          ),
        ),
        _InfoItem(
          label: Text(l10n.snapPageLicenseLabel),
          value: Text(footer.license.valueOrNull ?? l10n.appLicenseUnknown),
        ),
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

class _IconRow extends ConsumerWidget {
  const _IconRow({required this.snapName, required this.title});

  final String snapName;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        YaruIconButton(
          icon: Icon(
            YaruIcons.share,
            semanticLabel: l10n.snapPageShareSemanticLabel,
          ),
          onPressed: () {
            final navigationKey = ref.read(materialAppNavigatorKeyProvider);
            final context = navigationKey.currentContext!;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.snapPageShareLinkCopiedMessage)),
            );
            SemanticsService.sendAnnouncement(
              View.of(context),
              l10n.snapPageShareLinkCopiedMessage,
              Directionality.of(context),
            );
            unawaited(
              Clipboard.setData(
                ClipboardData(text: '$snapStoreBaseUrl/$snapName'),
              ),
            );
          },
        ),
        YaruIconButton(
          icon: Icon(
            YaruIcons.flag,
            semanticLabel: l10n.snapPageReportSemanticLabel,
          ),
          onPressed: () => showDialog<void>(
            context: context,
            builder: (context) => ResponsiveLayoutBuilder(
              builder: (context) => SnapReport(name: title, snapName: snapName),
            ),
          ),
        ),
      ],
    );
  }
}
