import 'package:flutter/material.dart';
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/app_page/app_format_toggle_buttons.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/snap/snap_section.dart';
import 'package:software/app/common/snap/snap_section_popup.dart';

class ExploreHeader extends StatelessWidget {
  const ExploreHeader({
    super.key,
    required this.enabledAppFormats,
    required this.appFormat,
    this.selectedSection,
    required this.setSelectedSection,
    required this.handleAppFormat,
  });

  final Set<AppFormat> enabledAppFormats;
  final AppFormat appFormat;
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
            if (enabledAppFormats.contains(AppFormat.packageKit))
              AppFormatToggleButtons(
                isSelected: [
                  appFormat == AppFormat.snap,
                  appFormat == AppFormat.packageKit
                ],
                onPressed: (index) => handleAppFormat(AppFormat.values[index]),
              ),
            if (appFormat == AppFormat.snap)
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
