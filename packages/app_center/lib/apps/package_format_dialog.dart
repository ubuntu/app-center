import 'dart:async';

import 'package:app_center/apps/app_details_entry.dart';
import 'package:app_center/apps/app_details_labels.dart';
import 'package:app_center/apps/app_details_model.dart';
import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/constants.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:app_center/widgets/hyperlink_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

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
        if (option.installState == InstallState.installed)
          option.format.localize(l10n),
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
              title: Text(switch (installed) {
                [final format] => l10n.appDetailsInstalledAsFormat(format),
                [final first, final second] =>
                  l10n.appDetailsInstalledAsTwoFormats(first, second),
                _ => l10n.appDetailsInstalledAsMultipleFormats,
              }),
              subtitle: Text(
                l10n.appDetailsUninstallToChangeFormat(installed.length),
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
  Widget build(BuildContext context) => Scrollbar(
    controller: _controller,
    thumbVisibility: true,
    child: SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: kSpacing),
      child: widget.child,
    ),
  );
}

class _FormatTable extends ConsumerWidget {
  const _FormatTable({required this.entry, required this.state});

  final AppDetailsEntry entry;
  final AppDetailsViewState state;

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
    FormatOption option,
  ) {
    final operation = state.operation;
    if (operation != null && operation.sourceId == option.sourceId) {
      return OutlinedButton(
        onPressed: null,
        child: Text(operation.kind.localize(l10n)),
      );
    }
    final action = option.action;
    if (action == null) return const SizedBox.shrink();
    return OutlinedButton(
      onPressed: action.enabled
          ? () => unawaited(model.execute(action.id))
          : null,
      child: Text(action.kind.localize(l10n)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final model = ref.read(appDetailsModelProvider(entry).notifier);

    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(
        horizontalInside: BorderSide(color: theme.dividerColor),
      ),
      children: [
        TableRow(
          children: [
            _header(theme, l10n.appDetailsPackageFormatLabel),
            _header(theme, l10n.snapPagePublisherLabel),
            _header(theme, l10n.appDetailsPackageSourceLabel),
            _header(theme, l10n.snapPageChannelLabel),
            _header(theme, l10n.snapPageVersionLabel),
            _header(theme, l10n.snapPageConfinementLabel),
            _header(theme, l10n.snapPagePublishedLabel),
            _header(theme, l10n.snapPageDownloadSizeLabel),
            const SizedBox.shrink(),
          ],
        ),
        for (final option in state.formats)
          TableRow(
            key: ValueKey(option.sourceId),
            children: [
              _cell(
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
              _cell(_PublisherLabel(option.publisher.valueOrNull)),
              _text(switch (option.format) {
                PackageFormat.snap => l10n.appDetailsPackageSourceSnapStore,
                PackageFormat.deb => l10n.appDetailsPackageSourceUbuntuArchive,
              }),
              _text(option.channel),
              _cell(
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: Tooltip(
                    message: option.version.valueOrNull ?? '',
                    child: Text(
                      option.version.valueOrNull ?? kMissingValue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              _cell(
                switch (option.confinement.valueOrNull) {
                  final confinement? => ConfinementLabel(confinement),
                  null => const Text(kMissingValue),
                },
              ),
              _text(switch (option.releaseDate.valueOrNull) {
                final date? => formatAppDate(date),
                null => null,
              }),
              _text(switch (option.size.valueOrNull) {
                final size? => context.formatByteSize(size.bytes),
                null => null,
              }),
              _cell(_action(l10n, model, option)),
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
