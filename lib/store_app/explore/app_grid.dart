import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/color_scheme.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/apps_model.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:software/store_app/explore/app_card.dart';
import 'package:software/store_app/common/app_dialog.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AppGrid extends StatefulWidget {
  const AppGrid({
    Key? key,
    required this.name,
    this.headline,
    required this.findByQuery,
    this.snapAmount = 20,
    this.appendBottomDivier = false,
  }) : super(key: key);

  final String name;
  final String? headline;
  final bool findByQuery;
  final int snapAmount;
  final bool appendBottomDivier;

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
        appendBottomDivider: widget.appendBottomDivier,
        snapAmount: widget.snapAmount,
        headline: widget.headline,
        snaps: snaps ?? [],
      );
    }

    return FutureBuilder<List<Snap>>(
      future: model.findSnapsByQuery(),
      builder: (context, snapshot) => snapshot.hasData
          ? _Grid(
              appendBottomDivider: widget.appendBottomDivier,
              snapAmount: widget.snapAmount,
              headline: widget.headline,
              snaps: snapshot.data!,
            )
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
    required this.headline,
    required this.snaps,
    required this.snapAmount,
    required this.appendBottomDivider,
  }) : super(key: key);

  final String? headline;
  final List<Snap> snaps;
  final int snapAmount;
  final bool appendBottomDivider;

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
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          if (widget.headline != null)
            Row(
              children: [
                Text(
                  widget.headline!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 20,
                ),
                TextButton(
                  onPressed: () => setState(
                    () => amount =
                        amount == widget.snapAmount ? 100 : widget.snapAmount,
                  ),
                  child: Text(
                    amount == widget.snapAmount
                        ? context.l10n.showMore
                        : context.l10n.showLess,
                  ),
                )
              ],
            ),
          if (widget.headline != null)
            const SizedBox(
              height: 15,
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
                      barrierColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Theme.of(context).colorScheme.barrierColorLight
                              : Theme.of(context).colorScheme.barrierColorDark,
                      context: context,
                      builder: (context) => ChangeNotifierProvider<SnapModel>(
                        create: (context) => SnapModel(
                          huskSnapName: snap.name,
                        ),
                        child: const AppDialog(),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          if (widget.appendBottomDivider)
            const SizedBox(
              height: 20,
            ),
          if (widget.appendBottomDivider)
            const Divider(
              height: 40,
            )
        ],
      ),
    );
  }
}
