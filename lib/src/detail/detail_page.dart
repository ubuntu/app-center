import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:yaru/yaru.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/l10n.dart';
import '/layout.dart';
import '/search.dart';
import '/snapd.dart';
import '/widgets.dart';

typedef SnapInfo = ({String label, Widget value});

class DetailPage extends ConsumerWidget {
  const DetailPage({super.key, required this.snapName});

  final String snapName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(snapModelProvider(snapName));
    return model.state.when(
      data: (_) => _SnapView(model: model),
      error: (error, stackTrace) => ErrorWidget(error),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _SnapView extends ConsumerWidget {
  const _SnapView({required this.model});

  final SnapModel model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final snapInfos = <SnapInfo>[
      (
        label: '123 Ratings',
        value: Text(
          'Positive',
          style: TextStyle(color: Theme.of(context).colorScheme.success),
        )
      ), // Placeholder
      (
        label: l10n.detailPageConfinementLabel,
        value: Text(
          model.channelInfo?.confinement.name ?? model.snap.confinement.name,
        ),
      ),
      (
        label: l10n.detailPageDownloadSizeLabel,
        value: Text(
          model.channelInfo != null
              ? context.formatByteSize(model.channelInfo!.size)
              : '',
        )
      ),
      (
        label: l10n.detailPageReleasedAtLabel,
        value: Text(
          model.channelInfo != null
              ? DateFormat.yMd().format(model.channelInfo!.releasedAt)
              : '',
        ),
      ),
      (
        label: l10n.detailPageLicenseLabel,
        value: Text(model.snap.license ?? ''),
      ),
      (
        label: l10n.detailPageLinksLabel,
        value: Column(
          children: [
            if (model.snap.website != null)
              '<a href="${model.snap.website}">${l10n.detailPageDeveloperWebsiteLabel}</a>',
            if (model.snap.contact != null && model.snap.publisher != null)
              '<a href="${model.snap.contact}">${l10n.detailPageContactPublisherLabel(model.snap.publisher!.displayName)}</a>'
          ]
              .map((link) => Html(
                    data: link,
                    style: {'body': Style(margin: Margins.zero)},
                    onLinkTap: (url, attributes, element) =>
                        launchUrlString(url!),
                  ))
              .toList(),
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: ResponsiveLayoutBuilder(builder: (context, layout) {
        return Column(
          children: [
            SizedBox(
              width: layout.totalWidth,
              child: _Header(model: model),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: layout.totalWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SnapInfos(snapInfos: snapInfos, layout: layout),
                        const Divider(),
                        if (model.storeSnap != null)
                          _Section(
                            header: Text(l10n.detailPageGalleryLabel),
                            child: SnapScreenshotGallery(
                              snap: model.storeSnap!,
                              height: layout.totalWidth / 2,
                            ),
                          ),
                        _Section(
                          header: Text(l10n.detailPageDescriptionLabel),
                          child: SizedBox(
                            width: double.infinity,
                            child: MarkdownBody(
                              data: model.storeSnap?.description ??
                                  model.localSnap?.description ??
                                  '',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SnapInfos extends StatelessWidget {
  const _SnapInfos({
    required this.snapInfos,
    required this.layout,
  });

  final List<SnapInfo> snapInfos;
  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: kPagePadding,
      runSpacing: 8,
      children: snapInfos
          .map((info) => SizedBox(
                width: (layout.totalWidth -
                        (layout.snapInfoColumnCount - 1) * kPagePadding) /
                    layout.snapInfoColumnCount,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.label),
                    DefaultTextStyle.merge(
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      child: info.value,
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _SnapActionButtons extends ConsumerWidget {
  const _SnapActionButtons({
    required this.model,
  });

  final SnapModel model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snapLauncher =
        model.isInstalled ? ref.watch(launchProvider(model.localSnap!)) : null;
    final refreshableSnaps = ref.watch(refreshProvider);
    final hasUpdate = model.localSnap == null
        ? false
        : refreshableSnaps.whenOrNull(
                data: (snaps) => snaps.singleWhereOrNull(
                    (snap) => snap.name == model.localSnap!.name)) !=
            null;

    final primaryAction = model.isInstalled
        ? model.selectedChannel == model.localSnap!.trackingChannel
            ? SnapAction.open
            : SnapAction.switchChannel
        : SnapAction.install;
    final primaryActionButton = SizedBox(
      width: kPrimaryActionButtonWidth,
      child: PushButton.elevated(
        onPressed: model.activeChangeId != null
            ? null
            : primaryAction.callback(model, snapLauncher),
        child: model.activeChangeId != null
            ? Consumer(
                builder: (context, ref, child) {
                  final change = ref
                      .watch(changeProvider(model.activeChangeId))
                      .whenOrNull(data: (data) => data);
                  return Row(
                    children: [
                      SizedBox.square(
                        dimension: 16,
                        child: YaruCircularProgressIndicator(
                          value: change?.progress,
                          strokeWidth: 2,
                        ),
                      ),
                      if (change != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            change.localize(l10n) ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]
                    ],
                  );
                },
              )
            : Text(primaryAction.label(l10n)),
      ),
    );

    final secondaryActions = [
      if (hasUpdate) SnapAction.update,
      SnapAction.remove,
    ];
    final secondaryActionsButton = MenuAnchor(
      menuChildren: secondaryActions.map((action) {
        final color = action == SnapAction.remove
            ? Theme.of(context).colorScheme.error
            : null;
        return MenuItemButton(
          child: IntrinsicWidth(
            child: ListTile(
              leading: action.icon != null
                  ? Icon(
                      action.icon,
                      color: color,
                    )
                  : null,
              title: Text(
                action.label(l10n),
                style: TextStyle(color: color),
              ),
            ),
          ),
          onPressed: () => action.callback(model)?.call(),
        );
      }).toList(),
      builder: (context, controller, child) => YaruOptionButton(
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
        child: const Icon(YaruIcons.view_more_horizontal),
      ),
    );

    final cancelButton = PushButton.outlined(
      onPressed: SnapAction.cancel.callback(model),
      child: Text(SnapAction.cancel.label(l10n)),
    );

    return ButtonBar(
      mainAxisSize: MainAxisSize.min,
      overflowButtonSpacing: 8,
      children: [
        primaryActionButton,
        if (model.activeChangeId != null)
          cancelButton
        else if (model.isInstalled)
          secondaryActionsButton,
      ].whereNotNull().toList(),
    );
  }
}

enum SnapAction {
  cancel,
  install,
  open,
  remove,
  switchChannel,
  update;

  String label(AppLocalizations l10n) => switch (this) {
        cancel => l10n.snapActionCancelLabel,
        install => l10n.snapActionInstallLabel,
        open => l10n.snapActionOpenLabel,
        remove => l10n.snapActionRemoveLabel,
        switchChannel => l10n.snapActionSwitchChannelLabel,
        update => l10n.snapActionUpdateLabel,
      };

  IconData? get icon => switch (this) {
        update => YaruIcons.refresh,
        remove => YaruIcons.trash,
        _ => null,
      };

  VoidCallback? callback(SnapModel model, [SnapLauncher? launcher]) =>
      switch (this) {
        cancel => model.cancel,
        install => model.install,
        open => launcher?.isLaunchable ?? false ? launcher!.open : null,
        remove => model.remove,
        switchChannel => model.refresh,
        update => model.refresh,
      };
}

class _ChannelDropdown extends YaruPopupMenuButton {
  _ChannelDropdown({
    super.enabled,
    super.onSelected,
    required Map<String, SnapChannel> channels,
    required String selectedChannel,
  }) : super(
          itemBuilder: (_) => channels.entries
              .map((e) => PopupMenuItem(
                    value: e.key,
                    child: Text("${e.key} ${e.value.version}"),
                  ))
              .toList(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              "$selectedChannel ${channels[selectedChannel]!.version}",
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
}

class _Section extends YaruExpandable {
  const _Section({required super.header, required super.child})
      : super(
          expandButtonPosition: YaruExpandableButtonPosition.start,
          isExpanded: true,
        );
}

class _Header extends StatelessWidget {
  const _Header({required this.model});

  final SnapModel model;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final snap = model.storeSnap ?? model.localSnap!;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const YaruBackButton(),
            if (snap.website != null)
              YaruIconButton(
                icon: const Icon(YaruIcons.share),
                onPressed: () {
                  // TODO show snackbar
                  Clipboard.setData(ClipboardData(text: snap.website!));
                },
              ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SnapIcon(iconUrl: snap.iconUrl, size: 96),
            const SizedBox(width: 16),
            Expanded(child: SnapTitle.large(snap: snap)),
          ],
        ),
        const SizedBox(height: kPagePadding),
        Row(
          children: [
            if (model.availableChannels != null &&
                model.selectedChannel != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.detailPageSelectChannelLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(width: 16),
                  _ChannelDropdown(
                    selectedChannel: model.selectedChannel!,
                    channels: model.availableChannels!,
                    onSelected: (value) => model.selectedChannel = value,
                    enabled: model.activeChangeId == null,
                  ),
                ],
              ),
            const SizedBox(width: 32),
            Flexible(child: _SnapActionButtons(model: model))
          ],
        ),
        const SizedBox(height: 42),
        const Divider(),
      ],
    );
  }
}

extension SnapdChangeL10n on SnapdChange {
  String? localize(AppLocalizations l10n) => switch (kind) {
        'install-snap' => 'Installing',
        'remove-snap' => 'Uninstalling',
        _ => null,
      };
}
