import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.snap});

  final Snap snap;

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: const YaruWindowTitleBar(leading: YaruBackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kYaruPagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(snap.name, style: Theme.of(context).textTheme.headlineMedium),
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
      ),
    );
  }
}
