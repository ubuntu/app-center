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
    this.controller,
  }) : super(key: key);

  final SnapSection snapSection;
  final int amount;
  final ScrollController? controller;

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

    return GridView(
      controller: widget.controller,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        mainAxisExtent: 110,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        maxCrossAxisExtent: 450,
      ),
      children: sections != null && sections.isNotEmpty
          ? sections.take(widget.amount).map((snap) {
              return SnapBanner.create(context, snap);
            }).toList()
          : [],
    );
  }
}
