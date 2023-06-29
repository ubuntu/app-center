import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'detail_provider.dart';

class DetailPage extends ConsumerWidget {
  const DetailPage({super.key, required this.snap});

  final Snap snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(detailModelProvider(snap));
    return Scaffold(
      appBar: const YaruWindowTitleBar(leading: YaruBackButton()),
      body: state.when(
        data: (localSnap) => _SnapView(snap: snap, localSnap: localSnap),
        error: (_, __) => _SnapView(snap: snap),
        loading: () => _SnapView(snap: snap, busy: true),
      ),
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
    final lang = AppLocalizations.of(context);
    final model = ref.watch(detailModelProvider(snap).notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(kYaruPagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(snap.name, style: Theme.of(context).textTheme.headlineMedium),
          if (localSnap != null) const Text('installed'),
          const SizedBox(height: kYaruPagePadding),
          !busy
              ? ElevatedButton(
                  onPressed: localSnap != null ? model.remove : model.install,
                  child: Text(localSnap != null ? 'Remove' : 'Install'),
                )
              : const YaruCircularProgressIndicator(),
          const SizedBox(height: kYaruPagePadding),
          Table(
            columnWidths: const {1: FlexColumnWidth(5)},
            children: [
              TableRow(children: [
                Text(lang.detailPageSummaryLabel),
                Text(snap.summary)
              ]),
              TableRow(children: [
                Text(lang.detailPageDescriptionLabel),
                Text(snap.description),
              ]),
              TableRow(children: [
                Text(lang.detailPageVersionLabel),
                Text(snap.version)
              ]),
              if (snap.publisher != null)
                TableRow(children: [
                  Text(lang.detailPagePublisherLabel),
                  Text(snap.publisher!.displayName)
                ]),
              TableRow(children: [
                Text(lang.detailPageConfinementLabel),
                Text(snap.confinement.toString()),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
