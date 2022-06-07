import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/snapx.dart';
import 'package:software/store_app/common/snap_dialog.dart';
import 'package:software/store_app/common/app_tile.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapTileGrid extends StatefulWidget {
  const SnapTileGrid({
    Key? key,
    required this.name,
    this.headline,
    required this.findByQuery,
    this.itemCount = 20,
    this.appendBottomDivier = false,
  }) : super(key: key);

  final String name;
  final String? headline;
  final bool findByQuery;
  final int itemCount;
  final bool appendBottomDivier;

  @override
  State<SnapTileGrid> createState() => _SnapTileGridState();
}

class _SnapTileGridState extends State<SnapTileGrid> {
  @override
  void initState() {
    super.initState();
    if (!widget.findByQuery) {
      context.read<ExploreModel>().loadSection(widget.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.read<ExploreModel>();

    if (!widget.findByQuery) {
      final snaps = model.sectionNameToSnapsMap[widget.name];
      return _Grid(
        appendBottomDivider: widget.appendBottomDivier,
        snapAmount: widget.itemCount,
        headline: widget.headline,
        snaps: snaps ?? [],
      );
    }

    return FutureBuilder<List<Snap>>(
      future: model.findSnapsByQuery(),
      builder: (context, snapshot) => snapshot.hasData
          ? _Grid(
              appendBottomDivider: widget.appendBottomDivier,
              snapAmount: widget.itemCount,
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
                  (snap) => AppTile(
                    icon: snap.iconUrl != null
                        ? Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.network(
                              snap.iconUrl!,
                              filterQuality: FilterQuality.medium,
                            ),
                          )
                        : const Icon(
                            YaruIcons.snapcraft,
                            size: 50,
                          ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => SnapDialog.create(
                        context: context,
                        huskSnapName: snap.name,
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
