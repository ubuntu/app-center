import 'package:flutter/material.dart';
import 'package:software/app/common/app_data.dart';
import 'package:software/app/common/app_page/app_infos/app_info_fragment.dart';
import 'package:software/app/common/link.dart';
import 'package:software/l10n/l10n.dart';

class LinksInfoFragment extends StatelessWidget {
  const LinksInfoFragment({
    super.key,
    required this.appData,
  });

  final AppData appData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: AppInfoFragment(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        header: context.l10n.links,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Tooltip(
              message: appData.website,
              child: Link(
                url: appData.website,
                linkText: context.l10n.website,
              ),
            ),
            if (appData.contact != null)
              Tooltip(
                message: '${context.l10n.contact}: ${appData.publisherName!}',
                child: Link(
                  url: appData.contact!,
                  linkText:
                      '${context.l10n.contact}: ${appData.publisherName!}',
                ),
              )
          ],
        ),
      ),
    );
  }
}
