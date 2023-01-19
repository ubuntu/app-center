import 'package:flutter/material.dart';
import 'package:software/app/common/app_data.dart';
import 'package:software/app/common/app_page/app_infos/app_info_fragment.dart';
import 'package:software/app/common/link.dart';
import 'package:software/l10n/l10n.dart';

class LinksInfoFragment extends StatelessWidget {
  const LinksInfoFragment({super.key, required this.appData});

  final AppData appData;

  @override
  Widget build(BuildContext context) {
    return AppInfoFragment(
      crossAxisAlignment: CrossAxisAlignment.start,
      header: context.l10n.links,
      tooltipMessage: context.l10n.links,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Link(url: appData.website, linkText: context.l10n.website),
          if (appData.contact != null)
            Link(
              url: appData.contact!,
              linkText: '${context.l10n.contact} ${appData.publisherName!}',
            )
        ],
      ),
    );
  }
}
