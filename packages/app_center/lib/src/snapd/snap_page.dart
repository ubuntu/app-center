import 'dart:async';

import 'package:app_center/constants.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/ratings.dart';
import 'package:app_center/snapd.dart';
import 'package:app_center/src/snapd/snap_report.dart';
import 'package:app_center/src/store/store_app.dart';
import 'package:app_center/widgets.dart';
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
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

const _kPrimaryButtonMaxWidth = 136.0;
const _kChannelDropdownWidth = 220.0;

typedef SnapInfo = ({String label, Widget value});

class SnapPage extends ConsumerStatefulWidget {
  const SnapPage({required this.snapName, super.key});

  final String snapName;

  @override
  ConsumerState<SnapPage> createState() => _SnapPageState();
}

class _SnapPageState extends ConsumerState<SnapPage> {
  StreamSubscription<SnapdException>? _errorSubscription;

  @override
  void initState() {
    super.initState();

    _errorSubscription = ref
        .read(snapModelProvider(widget.snapName))
        .errorStream
        .listen(showError);
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    _errorSubscription = null;
    super.dispose();
  }

  Future<void> showError(SnapdException e) => showErrorDialog(
        context: context,
        title: e.kind ?? 'Unknown Snapd Exception',
        message: e.message,
      );

  @override
  Widget build(BuildContext context) {
    final snapModel = ref.watch(snapModelProvider(widget.snapName));
    final updatesModel = ref.watch(updatesModelProvider);
    return snapModel.state.when(
      data: (_) => ResponsiveLayoutBuilder(
        builder: (_) => _SnapView(
          snapModel: snapModel,
          updatesModel: updatesModel,
        ),
      ),
      error: (error, stackTrace) => ErrorWidget(error),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _SnapView extends ConsumerWidget {
  const _SnapView({required this.snapModel, required this.updatesModel});

  final SnapModel snapModel;
  final UpdatesModel updatesModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final snapInfos = <SnapInfo>[
      (
        label: l10n.snapPageConfinementLabel,
        value: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              snapModel.channelInfo?.confinement.localize(l10n) ??
                  snapModel.snap.confinement.localize(l10n),
            ),
            if ((snapModel.channelInfo?.confinement ??
                    snapModel.snap.confinement) ==
                SnapConfinement.strict) ...const [
              SizedBox(width: 2),
              Icon(YaruIcons.shield, size: 12),
            ],
          ],
        ),
      ),
      (
        label: l10n.snapPageDownloadSizeLabel,
        value: Text(
          snapModel.channelInfo != null
              ? context.formatByteSize(snapModel.channelInfo!.size)
              : '',
        ),
      ),
      (
        label: l10n.snapPageLicenseLabel,
        value: Text(snapModel.snap.license ?? ''),
      ),
      (
        label: l10n.snapPageVersionLabel,
        value: Text(snapModel.channelInfo?.version ?? snapModel.snap.version),
      ),
      (
        label: l10n.snapPagePublishedLabel,
        value: Text(
          snapModel.channelInfo != null
              ? DateFormat.yMMMd().format(snapModel.channelInfo!.releasedAt)
              : '',
        ),
      ),
      (
        label: l10n.snapPageLinksLabel,
        value: Column(
          children: [
            if (snapModel.snap.website != null)
              '<a href="${snapModel.snap.website}">${l10n.snapPageDeveloperWebsiteLabel}</a>',
            if (snapModel.snap.contact != null &&
                snapModel.snap.publisher != null)
              '<a href="${snapModel.snap.contact}">${l10n.snapPageContactPublisherLabel(snapModel.snap.publisher!.displayName)}</a>'
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

    final layout = ResponsiveLayout.of(context);

    return Column(
      children: [
        SizedBox(
          width: layout.totalWidth,
          child: Padding(
            padding: const EdgeInsets.only(top: kPagePadding),
            child: _Header(snapModel: snapModel),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Center(
              child: SizedBox(
                width: layout.totalWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppIcon(iconUrl: snapModel.snap.iconUrl, size: 96),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTitle.fromSnap(snapModel.snap, large: true),
                        ),
                      ],
                    ),
                    const SizedBox(height: kPagePadding),
                    Row(
                      children: [
                        if (snapModel.availableChannels != null &&
                            snapModel.selectedChannel != null) ...[
                          _ChannelDropdown(model: snapModel),
                          const SizedBox(width: 16),
                        ],
                        Flexible(
                          child: _SnapActionButtons(snapModel: snapModel),
                        )
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: _SnapInfoBar(
                        snapInfos: snapInfos,
                        snap: snapModel.snap,
                        layout: layout,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 48),
                    if (snapModel.hasGallery) ...[
                      _Section(
                        header: Text(
                          l10n.snapPageGalleryLabel,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 48),
                          child: ScreenshotGallery(
                            title: snapModel.storeSnap!.titleOrName,
                            urls: snapModel.storeSnap!.screenshotUrls,
                            height: layout.totalWidth / 2,
                          ),
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 48),
                    ],
                    _Section(
                      header: Text(
                        l10n.snapPageDescriptionLabel,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              snapModel.snap.summary,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: kPagePadding),
                            MarkdownBody(
                              selectable: true,
                              onTapLink: (text, href, title) =>
                                  launchUrlString(href!),
                              data: snapModel.snap.description,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: kPagePadding),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SnapInfoBar extends ConsumerWidget {
  const _SnapInfoBar({
    required this.snapInfos,
    required this.snap,
    required this.layout,
  });

  final List<SnapInfo> snapInfos;
  final ResponsiveLayout layout;
  final Snap snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ratingsModel = ref.watch(ratingsModelProvider(snap));

    final ratings = ratingsModel.state.whenOrNull(
      data: (_) => (
        label: l10n.snapRatingsVotes(ratingsModel.snapRating?.totalVotes ?? 0),
        value: Text(
          ratingsModel.snapRating?.ratingsBand.localize(l10n) ?? '',
          style: TextStyle(
              color: ratingsModel.snapRating?.ratingsBand.getColor(context)),
        ),
      ),
    );

    return AppInfoBar(
      appInfos: [if (ratings != null) ratings, ...snapInfos],
      layout: layout,
    );
  }
}

class _SnapActionButtons extends ConsumerWidget {
  const _SnapActionButtons({required this.snapModel});

  final SnapModel snapModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localSnap = snapModel.localSnap;
    final snapLauncher = snapModel.isInstalled && localSnap != null
        ? ref.watch(launchProvider(localSnap))
        : null;
    final updatesModel = ref.watch(updatesModelProvider);

    final primaryAction = snapModel.isInstalled
        ? snapModel.selectedChannel == snapModel.localSnap!.trackingChannel
            ? SnapAction.open
            : SnapAction.switchChannel
        : SnapAction.install;
    final primaryActionButton = SizedBox(
      width: _kPrimaryButtonMaxWidth,
      child: PushButton.elevated(
        onPressed: snapModel.activeChangeId != null
            ? null
            : primaryAction.callback(snapModel, snapLauncher),
        child: snapModel.activeChangeId != null
            ? Consumer(
                builder: (context, ref, child) {
                  final change = ref
                      .watch(changeProvider(snapModel.activeChangeId))
                      .whenOrNull(data: (data) => data);
                  return Row(
                    children: [
                      SizedBox.square(
                        dimension: kCircularProgressIndicatorHeight,
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
                            maxLines: 1,
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
      if (updatesModel.hasUpdate(snapModel.snapName)) SnapAction.update,
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
              mouseCursor: SystemMouseCursors.click,
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
          onPressed: () => action.callback(snapModel)?.call(),
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

    final cancelButton = OutlinedButton(
      onPressed: SnapAction.cancel.callback(snapModel),
      child: Text(SnapAction.cancel.label(l10n)),
    );

    return ButtonBar(
      mainAxisSize: MainAxisSize.min,
      overflowButtonSpacing: 8,
      children: [
        primaryActionButton,
        if (snapModel.activeChangeId != null)
          cancelButton
        else if (snapModel.isInstalled)
          secondaryActionsButton,
        if (snapModel.isInstalled) ...[
          const SizedBox(width: 8),
          _RatingsActionButtons(
            snap: snapModel.snap,
          ),
        ]
      ].whereNotNull().toList(),
    );
  }
}

class _RatingsActionButtons extends ConsumerWidget {
  const _RatingsActionButtons({required this.snap});

  final Snap snap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsModel = ref.watch(ratingsModelProvider(snap));

    return ratingsModel.state.when(
      data: (_) {
        return IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                ),
                onTap: () {
                  ratingsModel.castVote(VoteStatus.up);
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Theme.of(context).dividerColor),
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                      left: BorderSide(color: Theme.of(context).dividerColor),
                      right: BorderSide(
                          color: Theme.of(context).dividerColor, width: 0.5),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                  ),
                  child: YaruIconButton(
                    mouseCursor: SystemMouseCursors.click,
                    icon: Icon(
                      ratingsModel.vote == VoteStatus.up
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
              ),
              InkWell(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
                onTap: () {
                  ratingsModel.castVote(VoteStatus.down);
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Theme.of(context).dividerColor),
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                      left: BorderSide(
                          color: Theme.of(context).dividerColor, width: 0.5),
                      right: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                  child: YaruIconButton(
                    mouseCursor: SystemMouseCursors.click,
                    icon: Icon(
                      ratingsModel.vote == VoteStatus.down
                          ? Icons.thumb_down
                          : Icons.thumb_down_outlined,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
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
        install => model.storeSnap != null ? model.install : null,
        open => launcher?.isLaunchable ?? false ? launcher!.open : null,
        remove => model.remove,
        switchChannel => model.storeSnap != null ? model.refresh : null,
        update => model.storeSnap != null ? model.refresh : null,
      };
}

class _Section extends YaruExpandable {
  const _Section({required super.header, required super.child})
      : super(
          expandButtonPosition: YaruExpandableButtonPosition.start,
          isExpanded: true,
          gapHeight: 24,
        );
}

class _Header extends ConsumerWidget {
  const _Header({required this.snapModel});

  final SnapModel snapModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = snapModel.storeSnap ?? snapModel.localSnap!;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const YaruBackButton(),
            const Spacer(),
            if (snap.website != null)
              YaruIconButton(
                icon: const Icon(YaruIcons.share),
                onPressed: () {
                  final navigationKey =
                      ref.watch(materialAppNavigatorKeyProvider);

                  ScaffoldMessenger.of(navigationKey.currentContext!)
                      .showSnackBar(
                    SnackBar(
                      content: Text(l10n.snapPageShareLinkCopiedMessage),
                    ),
                  );
                  Clipboard.setData(ClipboardData(text: snap.website!));
                },
              ),
            YaruIconButton(
              icon: const Icon(YaruIcons.flag),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return ResponsiveLayoutBuilder(
                      builder: (context) =>
                          SnapReport(name: snapModel.snap.titleOrName),
                    );
                  },
                );
              },
            ),
          ],
        ),
        const SizedBox(height: kPagePadding),
      ],
    );
  }
}

class _ChannelDropdown extends StatelessWidget {
  const _ChannelDropdown({required this.model});

  final SnapModel model;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.snapPageChannelLabel,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: _kChannelDropdownWidth,
          child: MenuButtonBuilder(
            entries: model.availableChannels!.entries
                .map(
              (channelEntry) => MenuButtonEntry(
                value: channelEntry.key,
                child: _ChannelDropdownEntry(channelEntry: channelEntry),
              ),
            )
                .fold(
              <MenuButtonEntry<String>>[],
              (p, e) =>
                  [...p, e, const MenuButtonEntry(value: '', isDivider: true)],
            )..removeLast(),
            itemBuilder: (context, value, child) => Text(value),
            selected: model.selectedChannel,
            onSelected: (value) => model.selectedChannel = value,
            menuPosition: PopupMenuPosition.under,
            menuStyle: const MenuStyle(
              minimumSize:
                  MaterialStatePropertyAll(Size(_kChannelDropdownWidth, 0)),
              maximumSize:
                  MaterialStatePropertyAll(Size(_kChannelDropdownWidth, 200)),
              visualDensity: VisualDensity.standard,
            ),
            itemStyle: MenuItemButton.styleFrom(
              maximumSize: const Size.fromHeight(100),
            ),
            child: Text(
              '${model.selectedChannel} ${model.availableChannels![model.selectedChannel]!.version}',
            ),
          ),
        ),
      ],
    );
  }
}

class _ChannelDropdownEntry extends StatelessWidget {
  const _ChannelDropdownEntry({required this.channelEntry});

  final MapEntry<String, SnapChannel> channelEntry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              overflow: TextOverflow.ellipsis,
            ),
        child: SizedBox(
          width: _kChannelDropdownWidth - 24,
          child: Row(
            children: [
              DefaultTextStyle.merge(
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.snapPageChannelLabel),
                    Text(l10n.snapPageVersionLabel),
                    Text(l10n.snapPagePublishedLabel),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    channelEntry.key,
                    channelEntry.value.version,
                    DateFormat.yMd().format(channelEntry.value.releasedAt),
                  ].map((e) => Text(e, maxLines: 1)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
