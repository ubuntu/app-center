import 'package:flutter/material.dart';
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/app_format_popup.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/snap/snap_section.dart';
import 'package:software/app/common/snap/snap_section_popup.dart';

class ExploreHeader extends StatelessWidget {
  const ExploreHeader({
    super.key,
    required this.selectedAppFormats,
    required this.enabledAppFormats,
    this.selectedSection,
    required this.setSelectedSection,
    required this.handleAppFormat,
  });

  final Set<AppFormat> selectedAppFormats;
  final Set<AppFormat> enabledAppFormats;
  final SnapSection? selectedSection;
  final void Function(SnapSection? value) setSelectedSection;
  final void Function(AppFormat appFormat) handleAppFormat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: kPagePadding,
        left: kPagePadding,
        bottom: kPagePadding - 5,
      ),
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
              selectedAppFormats: selectedAppFormats,
              enabledAppFormats: enabledAppFormats,
              onTap: handleAppFormat,
            ),
            if (selectedAppFormats.contains(AppFormat.snap))
              SnapSectionPopup(
                value: selectedSection,
                onSelected: setSelectedSection,
              ),
          ],
        ),
      ),
    );
  }
}
