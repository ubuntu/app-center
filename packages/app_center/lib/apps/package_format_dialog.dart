import 'dart:async';

import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/apps/app_details_labels.dart';
import 'package:app_center/apps/app_details_model.dart';
import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/apps/uninstall_dependents_dialog.dart';
import 'package:app_center/constants.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center/widgets/active_change_content.dart';
import 'package:app_center/widgets/channel_dropdown.dart';
import 'package:app_center/widgets/hyperlink_text.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:yaru/yaru.dart';

const _kChannelDropdownWidth = 220.0;
const _kDialogMaxWidth = 1040.0;

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
    final state = ref.watch(appDetailsModelProvider(entry)).value;
    final operation = state?.operation;
    // A format being uninstalled still counts until the removal finishes.
    final installed = [
      for (final option in state?.formats ?? const <FormatOption>[])
        if (option.installState == InstallState.installed ||
            (operation?.kind == OperationKind.remove &&
                operation?.sourceId == option.sourceId))
          option.format.localize(l10n),
    ];

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kDialogMaxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            YaruDialogTitleBar(
              title: Text(l10n.appDetailsChoosePackageFormatTitle),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: kDialogContentPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state == null)
                      const Center(child: YaruCircularProgressIndicator())
                    else ...[
                      if (installed.isNotEmpty && state.formats.length > 1) ...[
                        YaruInfoBox(
                          yaruInfoType: YaruInfoType.warning,
                          title: Text(switch (installed) {
                            [final format] => l10n.appDetailsInstalledAsFormat(
                              format,
                            ),
                            [final first, final second] =>
                              l10n.appDetailsInstalledAsTwoFormats(
                                first,
                                second,
                              ),
                            _ => l10n.appDetailsInstalledAsMultipleFormats,
                          }),
                          subtitle: Text(
                            l10n.appDetailsUninstallToChangeFormat(
                              installed.length,
                            ),
                          ),
                        ),
                        const SizedBox(height: kSpacing),
                      ],
                      _HorizontalScrollView(
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalScrollView extends StatefulWidget {
  const _HorizontalScrollView({required this.child});

  final Widget child;

  @override
  State<_HorizontalScrollView> createState() => _HorizontalScrollViewState();
}

class _HorizontalScrollViewState extends State<_HorizontalScrollView> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Material only adds automatic scrollbars to vertical scroll views.
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(bottom: kSpacing),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: widget.child,
        ),
      ),
    ),
  );
}

class _FormatTable extends ConsumerStatefulWidget {
  const _FormatTable({required this.entry, required this.state});

  final AppDetailsEntry entry;
  final AppDetailsViewState state;

  @override
  ConsumerState<_FormatTable> createState() => _FormatTableState();
}

class _FormatTableState extends ConsumerState<_FormatTable> {
  final _selectedChannels = <String, String>{};

  Widget _cell(Widget child) =>
      Padding(padding: const EdgeInsets.all(kSpacing), child: child);

  Widget _header(ThemeData theme, String label) => _cell(
    Text(
      label,
      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
    ),
  );

  Widget _text(String? value) => _cell(Text(value ?? kMissingValue));

  Widget _action(
    AppLocalizations l10n,
    AppDetailsModel model,
    String sourceId,
    ActionDescriptor? action,
  ) {
    final operation = widget.state.operation;
    if (operation != null && operation.sourceId == sourceId) {
      return ActiveChangeStatus(
        key: ValueKey(operation.id),
        actionLabel: operation.kind.localize(l10n),
        progress: operation.progress,
        onCancelPressed: operation.canCancel
            ? () => unawaited(model.cancel(operation.id))
            : null,
      );
    }
    if (action == null) return const SizedBox.shrink();
    return OutlinedButton(
      onPressed: action.enabled
          ? () => unawaited(
              model.execute(
                action.id,
                confirmUninstall: (dependents) =>
                    confirmUninstallWithDependents(
                      context,
                      appName:
                          widget.state.app.name.valueOrNull ??
                          widget.state.app.appId,
                      dependents: dependents,
                    ),
              ),
            )
          : null,
      child: Text(action.kind.localize(l10n)),
    );
  }

  Widget _channel(FormatOption option, List<TargetOption> channels) {
    if (option.format != PackageFormat.snap || channels.length < 2) {
      return _text(option.channel);
    }
    final selected = _selectedChannels[option.sourceId] ?? option.channel;
    return _cell(
      ChannelDropdown(
        width: _kChannelDropdownWidth,
        channels: [
          for (final channel in channels)
            ChannelDropdownItem(
              name: channel.label,
              version: channel.version.valueOrNull,
              releasedAt: channel.releaseDate.valueOrNull,
            ),
        ],
        selected: selected,
        label: selected ?? kMissingValue,
        onSelected: (value) =>
            setState(() => _selectedChannels[option.sourceId] = value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final model = ref.read(appDetailsModelProvider(widget.entry).notifier);
    final widths = _ColumnWidths.of(context);
    const divider = Divider(height: 1);

    // Rows lay out their columns separately, so all take the widest row's width.
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: widths.format,
                child: _header(theme, l10n.appDetailsPackageFormatLabel),
              ),
              SizedBox(
                width: widths.publisher,
                child: _header(theme, l10n.snapPagePublisherLabel),
              ),
              SizedBox(
                width: _ColumnWidths.channel,
                child: _header(theme, l10n.snapPageChannelLabel),
              ),
              SizedBox(
                width: widths.version,
                child: _header(theme, l10n.snapPageVersionLabel),
              ),
              SizedBox(
                width: widths.permissions,
                child: _header(theme, l10n.snapPageConfinementLabel),
              ),
            ],
          ),
          for (final option in widget.state.formats) ...[
            divider,
            _row(l10n, theme, model, widths, option),
          ],
          divider,
        ],
      ),
    );
  }

  Widget _row(
    AppLocalizations l10n,
    ThemeData theme,
    AppDetailsModel model,
    _ColumnWidths widths,
    FormatOption option,
  ) {
    final channels =
        widget.state.targets
            .firstWhereOrNull((group) => group.sourceId == option.sourceId)
            ?.options ??
        const <TargetOption>[];
    final selected = _selectedChannels[option.sourceId];
    // Rows show the default release until another channel is picked.
    final target = selected == null || selected == option.channel
        ? null
        : channels.firstWhereOrNull((channel) => channel.label == selected);
    final version = (target?.version ?? option.version).valueOrNull;
    final confinement = target != null
        ? target.confinement
        : option.confinement.valueOrNull;

    return YaruExpandable(
      key: ValueKey(option.sourceId),
      expandIconSemanticLabel: l10n.appDetailsPackageDetailsLabel,
      header: Row(
        children: [
          SizedBox(
            width: widths.format,
            child: _cell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    option.format.localize(l10n),
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
          ),
          SizedBox(
            width: widths.publisher,
            child: _cell(_PublisherLabel(option.publisher.valueOrNull)),
          ),
          SizedBox(
            width: _ColumnWidths.channel,
            child: _channel(option, channels),
          ),
          SizedBox(
            width: widths.version,
            child: _cell(
              Tooltip(
                message: version ?? '',
                child: Text(
                  version ?? kMissingValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          SizedBox(
            width: widths.permissions,
            child: _cell(
              switch (confinement) {
                final confinement? => ConfinementLabel(confinement),
                null => const Text(kMissingValue),
              },
            ),
          ),
          _cell(
            _action(
              l10n,
              model,
              option.sourceId,
              target != null ? target.action : option.action,
            ),
          ),
        ],
      ),
      child: _PackageDetails(
        option: option,
        width: widths.detail,
        version: version,
        confinement: confinement,
        releaseDate: (target?.releaseDate ?? option.releaseDate).valueOrNull,
        size: (target?.size ?? option.size).valueOrNull,
      ),
    );
  }
}

class _ColumnWidths {
  _ColumnWidths.of(BuildContext context)
    : this._(MediaQuery.textScalerOf(context));

  _ColumnWidths._(TextScaler scaler)
    : format = scaler.scale(130),
      publisher = scaler.scale(170),
      version = scaler.scale(140),
      permissions = scaler.scale(120),
      detail = scaler.scale(240);

  static const channel = _kChannelDropdownWidth + 2 * kSpacing;

  final double format;
  final double publisher;
  final double version;
  final double permissions;
  final double detail;
}

class _PackageDetails extends StatelessWidget {
  const _PackageDetails({
    required this.option,
    required this.width,
    required this.version,
    required this.confinement,
    required this.releaseDate,
    required this.size,
  });

  final FormatOption option;
  final double width;
  final String? version;
  final AppConfinement? confinement;
  final DateTime? releaseDate;
  final ByteSize? size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final packageName = option.packageName;
    final source = switch (option.format) {
      PackageFormat.snap => l10n.appDetailsPackageSourceSnapStore,
      PackageFormat.deb => l10n.appDetailsPackageSourceUbuntuArchive,
    };
    final link = switch ((option.format, packageName)) {
      (_, null) => null,
      (PackageFormat.snap, final name?) => '$snapStoreBaseUrl/$name',
      (PackageFormat.deb, final name?) => Uri.https(
        ubuntuPackagesHost,
        '/search',
        {'keywords': name, 'searchon': 'names', 'exact': '1'},
      ).toString(),
    };
    final access = switch (confinement) {
      null || AppConfinement.unknown => null,
      AppConfinement.strict => l10n.appDetailsLimitedAccess,
      _ => l10n.appDetailsFullAccess,
    };

    Widget item(String label, Widget value) => SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
          value,
        ],
      ),
    );

    return YaruBorderContainer(
      margin: const EdgeInsets.only(bottom: kSpacing),
      padding: const EdgeInsets.all(kSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              item(
                l10n.appDetailsPackageSourceLabel,
                link == null
                    ? Text(source)
                    : HyperlinkText(text: source, link: link),
              ),
              item(l10n.snapPageVersionLabel, Text(version ?? kMissingValue)),
              item(
                l10n.appDetailsPackageNameLabel,
                Text(packageName ?? kMissingValue),
              ),
            ],
          ),
          const SizedBox(height: kSpacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              item(
                size?.kind == SizeKind.installed
                    ? l10n.appDetailsInstalledSizeLabel
                    : l10n.snapPageDownloadSizeLabel,
                Text(switch (size) {
                  final size? => context.formatByteSize(size.bytes),
                  null => kMissingValue,
                }),
              ),
              item(
                l10n.snapPagePublishedLabel,
                Text(switch (releaseDate) {
                  final date? => formatAppDate(date),
                  null => kMissingValue,
                }),
              ),
            ],
          ),
          if (access != null) ...[
            const SizedBox(height: kSpacing),
            Text(access),
          ],
        ],
      ),
    );
  }
}

class _PublisherLabel extends StatelessWidget {
  const _PublisherLabel(this.publisher);

  final Publisher? publisher;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final validation = publisher?.validation ?? PublisherValidation.none;
    final name = publisher?.name ?? l10n.unknownPublisher;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Tooltip(
              message: name,
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (validation != PublisherValidation.none)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 4),
              child: PublisherBadge(validation, size: 14, focusable: true),
            ),
        ],
      ),
    );
  }
}
