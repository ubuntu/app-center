import 'package:flutter/material.dart';
import 'package:software/app/common/app_page/app_infos/app_info_fragment.dart';
import 'package:software/l10n/l10n.dart';

class AppSizeFragment extends StatelessWidget {
  const AppSizeFragment({super.key, required this.appSize});

  final String appSize;

  @override
  Widget build(BuildContext context) {
    return AppInfoFragment(
      header: context.l10n.size,
      child: Text(
        appSize,
        textAlign: TextAlign.center,
      ),
    );
  }
}
