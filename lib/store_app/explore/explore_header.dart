import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/app_format.dart';
import '../common/app_format_popup.dart';
import '../common/snap/snap_section_popup.dart';
import 'explore_model.dart';

class ExploreHeader extends StatelessWidget {
  const ExploreHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();

    return Padding(
      padding: const EdgeInsets.only(top: 25, left: 25, bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          runAlignment: WrapAlignment.start,
          spacing: 10,
          runSpacing: 10,
          children: [
            MultiAppFormatPopup(
              appFormats: model.appFormats,
              onTap: model.handleAppFormat,
            ),
            if (model.appFormats.contains(AppFormat.snap))
              SnapSectionPopup(
                value: model.selectedSection,
                onSelected: (v) => model.selectedSection = v,
              ),

            // TODO: wait for packagekit.dart to implement PackageKitGroup
            // in searchNames https://github.com/canonical/packagekit.dart/issues/24
            // then map and merge snapsections to packagekitgroups
            // if (model.appFormat == AppFormat.packageKit)
            //   PackageKitGroupButton(
            //     onSelected: (v) => model.setPackageKitGroup(v),
            //     value: model.packageKitGroup,
            //   )
          ],
        ),
      ),
    );
  }
}
