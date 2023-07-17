import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/l10n.dart';
import '/snapd.dart';
import '/widgets.dart';

typedef SnapInfo = ({String label, String value});

class DetailPage extends ConsumerWidget {
  const DetailPage({super.key, required this.snapName});

  final String snapName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeState = ref.watch(storeSnapProvider(snapName));
    return storeState.when(
      data: (storeSnap) {
        final localState = ref.watch(localSnapProvider(snapName));
        return localState.when(
          data: (localSnap) => _SnapView(
            storeSnap: storeSnap,
            localSnap: localSnap,
          ),
          error: (error, __) => _SnapView(
            storeSnap: storeSnap,
          ),
          loading: () => _SnapView(storeSnap: storeSnap, busy: true),
        );
      },
      error: (error, stackTrace) => ErrorWidget(error),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _SnapView extends ConsumerWidget {
  const _SnapView({
    this.storeSnap,
    this.localSnap,
    this.busy = false,
  });

  final Snap? storeSnap;
  final Snap? localSnap;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snapInfos = <SnapInfo>[
      (
        label: l10n.detailPageVersionLabel,
        value: storeSnap?.version ?? localSnap?.version ?? '',
      ),
      (
        label: l10n.detailPageConfinementLabel,
        value: storeSnap?.confinement.name ?? localSnap?.confinement.name ?? '',
      ),
      if (storeSnap?.downloadSize != null)
        (
          label: l10n.detailPageDownloadSizeLabel,
          value: context.formatByteSize(storeSnap!.downloadSize!)
        ),
      (
        label: l10n.detailPageLicenseLabel,
        value: storeSnap?.license ?? localSnap?.license ?? '',
      ),
      (
        label: l10n.detailPageWebsiteLabel,
        value: storeSnap?.website ?? localSnap?.website ?? '',
      ),
    ];

    final dummyChannels = [
      'latest/stable',
      'latest/candidate',
      'lastest/beta',
      'lastest/edge',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(kYaruPagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const YaruBackButton(),
          _Header(snap: storeSnap ?? localSnap),
          const SizedBox(height: kYaruPagePadding),
          Row(
            children: [
              Text(
                l10n.detailPageSelectChannelLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(width: 16),
              YaruPopupMenuButton(
                child: Text(dummyChannels.first),
                itemBuilder: (_) => dummyChannels
                    .map((e) => PopupMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),
              const SizedBox(width: 16),
              _SnapActionButtons(
                busy: busy,
                localSnap: localSnap,
                storeSnap: storeSnap,
              )
            ],
          ),
          const SizedBox(height: kYaruPagePadding),
          Wrap(
            spacing: 48,
            runSpacing: 8,
            children: snapInfos
                .map((info) => Column(
                      children: [
                        Text(
                          info.label,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(info.value),
                      ],
                    ))
                .toList(),
          ),
          _Section(
            header: Text(l10n.detailPageDescriptionLabel),
            child: SizedBox(
              width: double.infinity,
              child: MarkdownBody(
                data: storeSnap?.description ?? localSnap?.description ?? '',
              ),
            ),
          ),
          if (storeSnap != null)
            _Section(
              header: const Text('Gallery'),
              child: SnapScreenshotGallery(snap: storeSnap!),
            ),
        ],
      ),
    );
  }
}

class _SnapActionButtons extends ConsumerWidget {
  const _SnapActionButtons({
    required this.busy,
    this.localSnap,
    this.storeSnap,
  }) : assert(localSnap != null || storeSnap != null);

  final bool busy;
  final Snap? localSnap;
  final Snap? storeSnap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final localSnapNotifier = ref
        .read(localSnapProvider(storeSnap?.name ?? localSnap!.name).notifier);
    final snapLauncher =
        localSnap != null ? ref.watch(launchProvider(localSnap!)) : null;

    return ButtonBar(
      children: [
        PushButton.elevated(
          onPressed: busy
              ? null
              : localSnap != null
                  ? localSnapNotifier.remove
                  : localSnapNotifier.install,
          child: busy
              ? Center(
                  child: SizedBox.square(
                    dimension: IconTheme.of(context).size,
                    child: const YaruCircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                )
              : Text(
                  localSnap != null
                      ? l10n.detailPageRemoveLabel
                      : l10n.detailPageInstallLabel,
                ),
        ),
        if (snapLauncher?.isLaunchable ?? false) ...[
          const SizedBox(width: 16),
          PushButton.outlined(
            onPressed: snapLauncher!.open,
            child: Text(l10n.managePageOpenLabel),
          ),
        ]
      ],
    );
  }
}

class _Section extends YaruExpandable {
  const _Section({required super.header, required super.child})
      : super(expandButtonPosition: YaruExpandableButtonPosition.start);
}

class _Header extends StatelessWidget {
  const _Header({required this.snap});

  final Snap? snap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SnapIcon(iconUrl: snap?.iconUrl, size: 96),
        const SizedBox(width: 16),
        Expanded(
          child: snap != null
              ? SnapTitle.large(snap: snap!)
              : const SizedBox.shrink(),
        ),
        if (snap?.website != null)
          YaruIconButton(
            icon: const Icon(YaruIcons.share),
            onPressed: () {
              // TODO show snackbar
              Clipboard.setData(ClipboardData(text: snap!.website!));
            },
          ),
      ],
    );
  }
}
