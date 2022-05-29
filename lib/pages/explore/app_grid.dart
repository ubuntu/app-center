import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/common/apps_model.dart';
import 'package:software/pages/common/snap_model.dart';
import 'package:software/pages/explore/app_card.dart';
import 'package:software/pages/explore/app_dialog.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AppGrid extends StatefulWidget {
  const AppGrid({
    Key? key,
    required this.name,
    this.headline,
    this.topPadding = 50,
    required this.findByQuery,
    this.snapAmount = 20,
  }) : super(key: key);

  final String name;
  final String? headline;
  final double topPadding;
  final bool findByQuery;
  final int snapAmount;

  @override
  State<AppGrid> createState() => _AppGridState();
}

class _AppGridState extends State<AppGrid> {
  @override
  void initState() {
    super.initState();
    if (!widget.findByQuery) context.read<AppsModel>().loadSection(widget.name);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.read<AppsModel>();

    if (!widget.findByQuery) {
      final snaps = model.sectionNameToSnapsMap[widget.name];
      return _Grid(
          snapAmount: widget.snapAmount,
          topPadding: widget.topPadding,
          headline: widget.headline,
          snaps: snaps ?? []);
    }

    return FutureBuilder<List<Snap>>(
      future: model.findSnapsByQuery(),
      builder: (context, snapshot) => snapshot.hasData
          ? _Grid(
              snapAmount: widget.snapAmount,
              topPadding: widget.topPadding,
              headline: widget.headline,
              snaps: snapshot.data!)
          : const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: YaruCircularProgressIndicator(),
              ),
            ),
    );
  }
}

class _Grid extends StatefulWidget {
  const _Grid({
    Key? key,
    required this.topPadding,
    required this.headline,
    required this.snaps,
    required this.snapAmount,
  }) : super(key: key);

  final double topPadding;
  final String? headline;
  final List<Snap> snaps;
  final int snapAmount;

  @override
  State<_Grid> createState() => _GridState();
}

class _GridState extends State<_Grid> {
  int amount = 20;

  @override
  void initState() {
    super.initState();
    amount = widget.snapAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: widget.topPadding, left: 20, right: 20),
      child: Column(
        children: [
          if (widget.headline != null)
            Padding(
              padding: const EdgeInsets.only(
                bottom: 20,
              ),
              child: Row(
                children: [
                  Text(
                    widget.headline!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  TextButton(
                      onPressed: () => setState(() => amount =
                          amount == widget.snapAmount
                              ? 100
                              : widget.snapAmount),
                      child: Text(amount == widget.snapAmount
                          ? 'Show more'
                          : 'Show less'))
                ],
              ),
            ),
          GridView(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              crossAxisSpacing: 40,
              mainAxisSpacing: 40,
              maxCrossAxisExtent: 100,
            ),
            children: widget.snaps
                .take(amount)
                .map(
                  (snap) => AppCard(
                    snap: snap,
                    onTap: () => showDialog(
                      barrierColor: Colors.black.withOpacity(0.9),
                      context: context,
                      builder: (context) => ChangeNotifierProvider<SnapModel>(
                        create: (context) => SnapModel(
                            client: getService<SnapdClient>(),
                            huskSnapName: snap.name),
                        child: const AppDialog(),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
