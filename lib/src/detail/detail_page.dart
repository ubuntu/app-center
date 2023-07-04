import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/l10n.dart';
import '/snapx.dart';
import '/widgets.dart';
import 'detail_provider.dart';

typedef SnapInfo = ({String label, String value});

class DetailPage extends ConsumerWidget {
  const DetailPage({super.key, required this.snap});

  final Snap snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(detailModelProvider(snap));
    return state.when(
      data: (localSnap) => _SnapView(snap: snap, localSnap: localSnap),
      error: (_, __) => _SnapView(snap: snap),
      loading: () => _SnapView(snap: snap, busy: true),
    );
  }
}

class _SnapView extends ConsumerWidget {
  const _SnapView({
    required this.snap,
    this.localSnap,
    this.busy = false,
  });

  final Snap snap;
  final Snap? localSnap;
  final bool busy;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(detailModelProvider(snap).notifier);
    final l10n = AppLocalizations.of(context);
    final snapInfos = <SnapInfo>[
      (label: l10n.detailPageVersionLabel, value: snap.version),
      (label: l10n.detailPageConfinementLabel, value: snap.confinement.name),
      (
        label: l10n.detailPageDownloadSizeLabel,
        value: snap.downloadSize.toString()
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
              !busy
                  ? ElevatedButton(
                      onPressed:
                          localSnap != null ? model.remove : model.install,
                      child: Text(localSnap != null ? 'Remove' : 'Install'),
                    )
                  : const YaruCircularProgressIndicator(),
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
            header: const Text('Description'),
            child: SizedBox(
              width: double.infinity,
              child: MarkdownBody(
                data: snap.description,
              ),
            ),
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
