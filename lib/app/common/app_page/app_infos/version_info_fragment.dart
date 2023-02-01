import 'package:flutter/material.dart';
import 'package:software/app/common/app_page/app_infos/app_info_fragment.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/l10n/l10n.dart';

class VersionInfoFragment extends StatelessWidget {
  const VersionInfoFragment({
    Key? key,
    required this.version,
    this.versionChanged,
  }) : super(key: key);

  final String version;
  final bool? versionChanged;

  @override
  Widget build(BuildContext context) {
    return AppInfoFragment(
      header: context.l10n.version,
      tooltipMessage: version,
      child: Text(
        version,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: headerStyle.copyWith(
          fontWeight: FontWeight.normal,
          color: versionChanged == true
              ? Theme.of(context).brightness == Brightness.light
                  ? kGreenLight
                  : kGreenDark
              : null,
        ),
      ),
    );
  }
}
