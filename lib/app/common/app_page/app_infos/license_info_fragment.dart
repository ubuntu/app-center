import 'package:flutter/material.dart';
import 'package:software/app/common/app_page/app_infos/app_info_fragment.dart';
import 'package:software/l10n/l10n.dart';

class LicenseInfoFragment extends StatelessWidget {
  const LicenseInfoFragment({
    super.key,
    required this.headerStyle,
    required this.license,
  });

  final TextStyle headerStyle;
  final String license;

  @override
  Widget build(BuildContext context) {
    return AppInfoFragment(
      crossAxisAlignment: CrossAxisAlignment.start,
      header: context.l10n.license,
      child: Text(
        license,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
