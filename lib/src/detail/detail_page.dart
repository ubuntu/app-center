import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.snap});

  final Snap snap;

  @override
  Widget build(BuildContext context) {
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
                TableRow(children: [const Text('Summary'), Text(snap.summary)]),
                TableRow(children: [
                  const Text('Description'),
                  Text(snap.description),
                ]),
                TableRow(children: [const Text('Version'), Text(snap.version)]),
                if (snap.publisher != null)
                  TableRow(children: [
                    const Text('Publisher'),
                    Text(snap.publisher!.displayName)
                  ]),
                TableRow(children: [
                  const Text('Confinement'),
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
