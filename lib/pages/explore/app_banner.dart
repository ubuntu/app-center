import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';
import 'package:software/snapx.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_icons/yaru_icons.dart';

class AppBanner extends StatelessWidget {
  const AppBanner({
    Key? key,
    required this.snap,
    this.onTap,
    this.surfaceTintColor,
    this.watermark = false,
  }) : super(key: key);

  final Snap snap;
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
                _Card(
                  borderRadius: borderRadius,
                  color: surfaceTintColor!,
                  title: snap.title ?? '',
                  summary: snap.summary,
                  elevation: 4,
                  icon: _SnapIcon(snap),
                  textOverflow: TextOverflow.visible,
                ),
                if (watermark == true)
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: 0.1,
                        child: SizedBox(height: 130, child: _SnapIcon(snap)),
                      ),
                    ),
                  ),
              ],
            )
          : _Card(
              borderRadius: borderRadius,
              color: light
                  ? YaruColors.warmGrey.shade900
                  : Theme.of(context).colorScheme.onBackground,
              elevation: light ? 2 : 1,
              icon: _SnapIcon(snap),
              title: snap.title ?? '',
              summary: snap.summary,
              textOverflow: TextOverflow.ellipsis,
            ),
    );
  }
}

class _SnapIcon extends StatelessWidget {
  const _SnapIcon(
    this.snap, {
    Key? key,
  }) : super(key: key);

  final Snap snap;

  @override
  Widget build(BuildContext context) {
    const fallbackIcon = Icon(YaruIcons.package_snap, size: 65);
    if (snap.iconUrl == null) return fallbackIcon;
    return Image.network(
      snap.iconUrl!,
      filterQuality: FilterQuality.medium,
      fit: BoxFit.fitHeight,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        return frame == null ? fallbackIcon : child;
      },
      errorBuilder: (context, error, stackTrace) => fallbackIcon,
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    Key? key,
    required this.color,
    required this.title,
    required this.summary,
    required this.elevation,
    required this.icon,
    required this.borderRadius,
    required this.textOverflow,
  }) : super(key: key);

  final Color color;
  final String title;
  final String summary;
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
            subtitle: Text(summary, overflow: textOverflow),
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
