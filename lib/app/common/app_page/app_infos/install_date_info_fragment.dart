import 'package:flutter/material.dart';
import 'package:software/app/common/app_page/app_infos/app_info_fragment.dart';
import 'package:software/l10n/l10n.dart';

class InstallDateInfoFragment extends StatelessWidget {
  const InstallDateInfoFragment({
    super.key,
    required this.installDateIsoNorm,
    required this.installDate,
  });

  final String installDateIsoNorm;
  final String installDate;

  @override
  Widget build(BuildContext context) {
    return AppInfoFragment(
      crossAxisAlignment: CrossAxisAlignment.start,
      header: context.l10n.installDate,
      tooltipMessage: installDateIsoNorm,
      child: Text(
        installDate.isNotEmpty ? installDate : context.l10n.notInstalled,
        maxLines: 1,
        overflow: TextOverflow.visible,
        textAlign: TextAlign.center,
      ),
    );
  }
}
