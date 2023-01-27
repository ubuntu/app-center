import 'package:flutter/material.dart';
import 'package:software/app/common/app_data.dart';
import 'package:software/app/common/app_page/app_infos/app_info_fragment.dart';
import 'package:software/app/common/link.dart';
import 'package:software/l10n/l10n.dart';

class LinksInfoFragment extends StatelessWidget {
  const LinksInfoFragment({
    Key? key,
    required this.appData,
  }) : super(key: key);

  final AppData appData;

  @override
  Widget build(BuildContext context) {
    return AppInfoFragment(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      header: context.l10n.links,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (appData.website == context.l10n.unknown)
            Text(appData.website)
          else
            Tooltip(
              message: appData.website,
              child: Link(
                url: appData.website,
                linkText: context.l10n.website,
              ),
            ),
        ],
      ),
    );
  }
}
