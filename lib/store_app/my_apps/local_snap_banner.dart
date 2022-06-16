import 'package:flutter/material.dart';
import 'package:software/store_app/common/app_banner.dart';
import 'package:software/store_app/common/safe_image.dart';
import 'package:software/store_app/common/snap_dialog.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_icons/yaru_icons.dart';

class LocalSnapBanner extends StatelessWidget {
  final String snapName;
  final String summary;
  final String? url;

  const LocalSnapBanner({
    Key? key,
    required this.snapName,
    required this.summary,
    required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10);
    bool light = Theme.of(context).brightness == Brightness.light;
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (context) =>
            SnapDialog.create(context: context, huskSnapName: snapName),
      ),
      borderRadius: borderRadius,
      child: AppBanner(
        borderRadius: borderRadius,
        color: light
            ? YaruColors.warmGrey.shade900
            : Theme.of(context).colorScheme.onBackground,
        elevation: light ? 2 : 1,
        icon: SafeImage(
          url: url,
          fallBackIconData: YaruIcons.package_snap,
        ),
        title: snapName,
        summary: summary,
        textOverflow: TextOverflow.ellipsis,
      ),
    );
  }
}
