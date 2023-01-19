import 'package:flutter/material.dart';
import 'package:software/app/common/app_data.dart';
import 'package:software/app/common/app_page/app_infos/app_info_fragment.dart';
import 'package:software/app/common/app_page/app_infos/install_date_info_fragment.dart';
import 'package:software/app/common/app_page/app_infos/license_info_fragment.dart';
import 'package:software/app/common/app_page/app_infos/publisher_info_fragment.dart';
import 'package:software/app/common/app_page/app_infos/released_at_info_fragment.dart';
import 'package:software/app/common/link.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

const headerStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);

class AdditionalInformation extends StatelessWidget {
  const AdditionalInformation({
    super.key,
    required this.appData,
  });

  final AppData appData;

  @override
  Widget build(BuildContext context) {
    return YaruExpandable(
      isExpanded: true,
      header: Text(
        context.l10n.additionalInformation,
        style: Theme.of(context).textTheme.headline6,
      ),
      child: SizedBox(
        height: 200,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: GridView(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisExtent: 100,
            ),
            children: [
              PublisherInfoFragment(
                publisherName: appData.publisherName ?? context.l10n.unknown,
                website: appData.website,
                verified: appData.verified,
                starDev: appData.starredDeveloper,
              ),
              ReleasedAtInfoFragment(releasedAt: appData.releasedAt),
              LicenseInfoFragment(
                headerStyle: headerStyle,
                license: appData.license,
              ),
              AppInfoFragment(
                crossAxisAlignment: CrossAxisAlignment.start,
                header: 'Category',
                tooltipMessage: '',
                child: Text(context.l10n.unknown),
              ),
              InstallDateInfoFragment(
                installDateIsoNorm:
                    appData.installDateIsoNorm ?? context.l10n.notInstalled,
                installDate: appData.installDate ?? context.l10n.notInstalled,
              ),
              AppInfoFragment(
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
                        linkText:
                            '${context.l10n.contact} ${appData.publisherName!}',
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
