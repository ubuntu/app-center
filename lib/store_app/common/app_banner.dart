import 'package:flutter/material.dart';
import 'package:software/store_app/common/safe_image.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_icons/yaru_icons.dart';

class AppBanner extends StatelessWidget {
  const AppBanner({
    Key? key,
    this.onTap,
    this.surfaceTintColor,
    this.watermark = false,
    required this.name,
    this.summary,
    this.url,
    this.isSnap = true,
  }) : super(key: key);

  final String name;
  final String? summary;
  final String? url;
  final Function()? onTap;
  final Color? surfaceTintColor;
  final bool watermark;
  final bool isSnap;

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
                _Banner(
                  borderRadius: borderRadius,
                  color: surfaceTintColor!,
                  title: name,
                  summary: summary,
                  elevation: light ? 4 : 6,
                  icon: SafeImage(
                    url: url,
                    fallBackIconData:
                        isSnap ? YaruIcons.package_snap : YaruIcons.package_deb,
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
                            fallBackIconData: isSnap
                                ? YaruIcons.package_snap
                                : YaruIcons.package_deb,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : _Banner(
              borderRadius: borderRadius,
              color: light
                  ? YaruColors.warmGrey.shade900
                  : Theme.of(context).colorScheme.onBackground,
              elevation: light ? 2 : 1,
              icon: SafeImage(
                url: url,
                fallBackIconData:
                    isSnap ? YaruIcons.package_snap : YaruIcons.package_deb,
                iconSize: 50,
              ),
              title: name,
              summary: summary,
              textOverflow: TextOverflow.ellipsis,
            ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    Key? key,
    required this.color,
    required this.title,
    this.summary,
    required this.elevation,
    required this.icon,
    required this.borderRadius,
    required this.textOverflow,
  }) : super(key: key);

  final Color color;
  final String title;
  final String? summary;
  final double elevation;
  final Widget icon;
  final BorderRadius borderRadius;
  final TextOverflow textOverflow;

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: color,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 370,
          child: ListTile(
            mouseCursor: SystemMouseCursors.click,
            subtitle: summary != null && summary!.isNotEmpty
                ? Text(summary!, overflow: textOverflow)
                : null,
            title: Text(
              title,
              style: const TextStyle(fontSize: 20),
            ),
            leading: SizedBox(
              width: 60,
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}
