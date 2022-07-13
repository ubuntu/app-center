import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/snapx.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/snap_dialog.dart';
import 'package:software/store_app/common/snap_section.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

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
    context.read<ExploreModel>().loadSection(widget.snapSection);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    final sections =
        model.sectionNameToSnapsMap[widget.snapSection.title] ?? [];
    if (sections.isEmpty) return const SizedBox();
    return GridView(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      shrinkWrap: true,
      gridDelegate: kGridDelegate,
      children: sections.take(widget.amount).map((snap) {
        return YaruBanner(
          name: snap.name,
          summary: snap.summary,
          url: snap.iconUrl,
          fallbackIconData: YaruIcons.package_snap,
          onTap: () => showDialog(
            context: context,
            builder: (context) => SnapDialog.create(
              context: context,
              huskSnapName: snap.name,
            ),
          ),
        );
      }).toList(),
    );
  }
}
