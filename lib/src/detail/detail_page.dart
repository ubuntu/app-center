import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/l10n.dart';
import '/snapx.dart';
import '/widgets.dart';
import 'detail_provider.dart';

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
        final localNotifier = ref.watch(localSnapProvider(snapName).notifier);
        return localState.when(
          data: (localSnap) => _SnapView(
            snap: storeSnap,
            localSnap: localSnap,
            onRemove: localNotifier.remove,
          ),
          error: (error, __) => _SnapView(
            snap: storeSnap,
            onInstall: localNotifier.install,
          ),
          loading: () => _SnapView(snap: storeSnap, busy: true),
        );
      },
      error: (error, stackTrace) => ErrorWidget(error),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _SnapView extends ConsumerWidget {
  const _SnapView({
    required this.snap,
    this.localSnap,
    this.busy = false,
    this.onInstall,
    this.onRemove,
  });

  final Snap snap;
  final Snap? localSnap;
  final bool busy;
  final VoidCallback? onInstall;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snapInfos = <SnapInfo>[
      (label: l10n.detailPageVersionLabel, value: snap.version),
      (label: l10n.detailPageConfinementLabel, value: snap.confinement.name),
      if (snap.downloadSize != null)
        (
          label: l10n.detailPageDownloadSizeLabel,
          value: context.formatByteSize(snap.downloadSize!)
        ),
      (label: l10n.detailPageLicenseLabel, value: snap.license ?? ''),
      (label: l10n.detailPageWebsiteLabel, value: snap.website ?? ''),
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
          _Header(snap: snap),
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
              PushButton.elevated(
                onPressed: busy
                    ? null
                    : localSnap != null
                        ? onRemove
                        : onInstall,
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
                data: snap.description,
              ),
            ),
          ),
          _Section(
            header: const Text('Gallery'),
            child: SnapScreenshotGallery(snap: snap),
          ),
        ],
      ),
    );
  }
}

class _Section extends YaruExpandable {
  const _Section({required super.header, required super.child})
      : super(expandButtonPosition: YaruExpandableButtonPosition.start);
}

class _Header extends StatelessWidget {
  const _Header({required this.snap});

  final Snap snap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SnapIcon(iconUrl: snap.iconUrl, size: 96),
        const SizedBox(width: 16),
        SnapTitle.large(snap: snap),
        const Spacer(),
        if (snap.website != null)
          YaruIconButton(
            icon: const Icon(YaruIcons.share),
            onPressed: () {
              // TODO show snackbar
              Clipboard.setData(ClipboardData(text: snap.website!));
            },
          ),
      ],
    );
  }
}
