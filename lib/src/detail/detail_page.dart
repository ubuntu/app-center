import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/l10n.dart';
import '/layout.dart';
import '/search.dart';
import '/snapd.dart';
import '/widgets.dart';

typedef SnapInfo = ({String label, String value});

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

    final channelInfo = model.selectedChannel != null
        ? model.storeSnap?.channels[model.selectedChannel]
        : null;

    // TODO: move logic into view model, once app page UI is settled
    final snapInfos = <SnapInfo>[
      (
        label: l10n.detailPageVersionLabel,
        value: channelInfo?.version ??
            model.storeSnap?.version ??
            model.localSnap?.version ??
            '',
      ),
      (
        label: l10n.detailPageConfinementLabel,
        value: channelInfo?.confinement.name ??
            model.storeSnap?.confinement.name ??
            model.localSnap?.confinement.name ??
            '',
      ),
      if (model.storeSnap?.downloadSize != null)
        (
          label: l10n.detailPageDownloadSizeLabel,
          value: context.formatByteSize(
              channelInfo?.size ?? model.storeSnap!.downloadSize!)
        ),
      (
        label: l10n.detailPageLastUpdatedLabel,
        value: channelInfo != null
            ? DateFormat.yMd().format(channelInfo.releasedAt)
            : '',
      ),
      (
        label: l10n.detailPageLicenseLabel,
        value: model.storeSnap?.license ?? model.localSnap?.license ?? '',
      ),
      (
        label: l10n.detailPageWebsiteLabel,
        value: model.storeSnap?.website ?? model.localSnap?.website ?? '',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: LayoutBuilder(builder: (context, constraints) {
        final layout = ResponsiveLayout.fromConstraints(constraints);
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
                    Text(
                      info.label,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(info.value),
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
    final snapLauncher = model.localSnap != null
        ? ref.watch(launchProvider(model.localSnap!))
        : null;
    final refreshableSnaps = ref.watch(refreshProvider);
    final canRefresh = model.localSnap == null
        ? false
        : refreshableSnaps.whenOrNull(
                    data: (snaps) => snaps.singleWhereOrNull(
                        (snap) => snap.name == model.localSnap!.name)) !=
                null ||
            model.selectedChannel != model.localSnap!.trackingChannel;

    final installRemoveButton = PushButton.elevated(
      onPressed: model.activeChanges.isNotEmpty
          ? null
          : model.localSnap != null
              ? model.remove
              : () => model.install(),
      child: model.activeChanges.isNotEmpty
          ? Center(
              child: SizedBox.square(
                dimension: IconTheme.of(context).size,
                child: const YaruCircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),
            )
          : Text(
              model.localSnap != null
                  ? l10n.detailPageRemoveLabel
                  : l10n.detailPageInstallLabel,
            ),
    );
    final refreshButton = canRefresh
        ? PushButton.elevated(
            onPressed: () => model.refresh(),
            child: Text(l10n.detailPageUpdateLabel),
          )
        : null;
    final launchButton = snapLauncher?.isLaunchable ?? false
        ? PushButton.outlined(
            onPressed: snapLauncher!.open,
            child: Text(l10n.managePageOpenLabel),
          )
        : null;

    return ButtonBar(
      overflowButtonSpacing: 8,
      children: [
        installRemoveButton,
        refreshButton,
        launchButton,
      ].whereNotNull().toList(),
    );
  }
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
                    enabled: model.activeChanges.isEmpty,
                  ),
                ],
              ),
            Flexible(child: _SnapActionButtons(model: model))
          ],
        ),
        const SizedBox(height: 42),
        const Divider(),
      ],
    );
  }
}
