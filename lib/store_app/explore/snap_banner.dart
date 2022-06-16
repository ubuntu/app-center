import 'package:flutter/material.dart';
import 'package:software/store_app/common/app_banner.dart';
import 'package:software/store_app/common/safe_image.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_icons/yaru_icons.dart';

class SnapBanner extends StatelessWidget {
  const SnapBanner({
    Key? key,
    this.onTap,
    this.surfaceTintColor,
    this.watermark = false,
    required this.name,
    required this.summary,
    this.url,
  }) : super(key: key);

  final String name;
  final String summary;
  final String? url;
  final Function()? onTap;
  final Color? surfaceTintColor;
  final bool watermark;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10);

    bool light = Theme.of(context).brightness == Brightness.light;
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: surfaceTintColor != null
          ? Stack(
              children: [
                AppBanner(
                  borderRadius: borderRadius,
                  color: surfaceTintColor!,
                  title: name,
                  summary: summary,
                  elevation: light ? 4 : 6,
                  icon: SafeImage(
                    url: url,
                    fallBackIconData: YaruIcons.package_snap,
                  ),
                  textOverflow: TextOverflow.fade,
                ),
                if (watermark == true)
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: 0.1,
                        child: SizedBox(
                          height: 130,
                          child: SafeImage(
                            url: url,
                            fallBackIconData: YaruIcons.package_snap,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : AppBanner(
              borderRadius: borderRadius,
              color: light
                  ? YaruColors.warmGrey.shade900
                  : Theme.of(context).colorScheme.onBackground,
              elevation: light ? 2 : 1,
              icon: SafeImage(
                url: url,
                fallBackIconData: YaruIcons.package_snap,
              ),
              title: name,
              summary: summary,
              textOverflow: TextOverflow.ellipsis,
            ),
    );
  }
}
