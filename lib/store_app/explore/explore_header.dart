import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/store_app/common/app_format.dart';
import 'package:software/store_app/common/app_format_popup.dart';
import 'package:software/store_app/common/packagekit/packagekit_filter_button.dart';
import 'package:software/store_app/common/snap/snap_section_popup.dart';
import 'package:software/store_app/explore/explore_model.dart';

class ExploreHeader extends StatelessWidget {
  const ExploreHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();

    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 25, bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          runAlignment: WrapAlignment.start,
          spacing: 10,
          runSpacing: 10,
          children: [
            AppFormatPopup(
              appFormat: model.appFormat,
              onSelected: model.setAppFormat,
            ),
            if (model.appFormat == AppFormat.snap)
              SnapSectionPopup(
                value: model.selectedSection,
                onSelected: (v) => model.selectedSection = v,
              ),
            if (model.appFormat == AppFormat.packageKit)
              PackageKitFilterButton(
                onTap: model.handleFilter,
                filters: model.packageKitFilters,
              ),
            // TODO: wait for packagekit.dart to implement PackageKitGroup
            // in searchNames https://github.com/canonical/packagekit.dart/issues/24
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
