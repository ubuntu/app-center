import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/store_app/common/snap_section.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:software/store_app/explore/snap_banner.dart';

class SectionBannerGrid extends StatefulWidget {
  const SectionBannerGrid({
    Key? key,
    required this.snapSection,
    this.amount = 20,
  }) : super(key: key);

  final SnapSection snapSection;
  final int amount;

  @override
  State<SectionBannerGrid> createState() => _SectionBannerGridState();
}

class _SectionBannerGridState extends State<SectionBannerGrid> {
  @override
  void initState() {
    super.initState();
    context.read<ExploreModel>().loadSection(widget.snapSection.title);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    final sections = model.sectionNameToSnapsMap[widget.snapSection.title];
    if (sections == null || sections.isEmpty) {
      return const SizedBox();
    } else {
      return GridView(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          mainAxisExtent: 110,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          maxCrossAxisExtent: 500,
        ),
        children: sections.take(widget.amount).map((snap) {
          return SnapBanner.create(context, snap);
        }).toList(),
      );
    }
  }
}
