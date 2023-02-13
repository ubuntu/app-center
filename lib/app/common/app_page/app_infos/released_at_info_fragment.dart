import 'package:flutter/material.dart';
import 'package:software/app/common/app_page/app_infos/app_info_fragment.dart';
import 'package:software/l10n/l10n.dart';

class ReleasedAtInfoFragment extends StatelessWidget {
  const ReleasedAtInfoFragment({super.key, required this.releasedAt});

  final String releasedAt;

  @override
  Widget build(BuildContext context) {
    return AppInfoFragment(
      crossAxisAlignment: CrossAxisAlignment.start,
      header: context.l10n.releasedAt,
      child: Text(
        releasedAt,
        textAlign: TextAlign.center,
      ),
    );
  }
}
