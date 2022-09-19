import 'package:flutter/material.dart';
import 'package:software/store_app/common/app_infos.dart';
import 'package:software/store_app/common/app_website.dart';
import 'package:software/store_app/common/snap_controls.dart';

const headerStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);

class TwoColumnAppHeader extends StatelessWidget {
  final Widget? icon;
  final String title;
  final String summary;
  final bool strict;
  final String confinementName;
  final String version;
  final String license;
  final String installDate;
  final String installDateIsoNorm;
  final bool verified;
  final String publisherName;
  final String website;

  const TwoColumnAppHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.summary,
    required this.version,
    required this.strict,
    required this.confinementName,
    required this.license,
    required this.installDate,
    required this.installDateIsoNorm,
    required this.verified,
    required this.publisherName,
    required this.website,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          children: [
            SizedBox(
              height: 180,
              child: icon,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.headline3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            AppWebsite(
              website: website,
              verified: verified,
              publisherName: publisherName,
            ),
          ],
        ),
        const SnapControls(
          direction: Axis.vertical,
        ),
        AppInfos(
          strict: strict,
          confinementName: confinementName,
          license: license,
          installDate: installDate,
          installDateIsoNorm: installDateIsoNorm,
          version: version,
        ),
        Text(
          summary,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
