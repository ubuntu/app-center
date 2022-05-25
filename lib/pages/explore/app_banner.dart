import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_icons/yaru_icons.dart';

class AppBanner extends StatelessWidget {
  const AppBanner({
    Key? key,
    required this.snap,
    this.onTap,
    this.surfaceTint = true,
  }) : super(key: key);

  final Snap snap;
  final Function()? onTap;
  final bool surfaceTint;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10);
    int? iconIndex;
    for (var i = 0; i < snap.media.length; i++) {
      if (snap.media[i].type == 'icon') {
        iconIndex = i;
      }
      break;
    }

    bool light = Theme.of(context).brightness == Brightness.light;

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: surfaceTint && iconIndex != null
          ? FutureBuilder<Color>(
              future:
                  getSurfaceTintColor(NetworkImage(snap.media[iconIndex].url)),
              builder: (context, snapshot) => _Card(
                  borderRadius: borderRadius,
                  color: snapshot.data ?? Colors.transparent,
                  title: snap.title,
                  summary: snap.summary,
                  elevation: 4,
                  icon: Image.network(
                    snap.media[iconIndex!].url,
                    fit: BoxFit.fitHeight,
                    filterQuality: FilterQuality.medium,
                  )),
            )
          : _Card(
              borderRadius: borderRadius,
              color: light
                  ? YaruColors.warmGrey.shade900
                  : Theme.of(context).colorScheme.onBackground,
              elevation: light ? 2 : 1,
              icon: iconIndex != null
                  ? Image.network(
                      snap.media[iconIndex].url,
                      fit: BoxFit.fitHeight,
                      filterQuality: FilterQuality.medium,
                    )
                  : _FallbackIcon(),
              title: snap.title,
              summary: snap.summary,
            ),
    );
  }

  Future<Color> getSurfaceTintColor(ImageProvider imageProvider) async {
    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      imageProvider,
    );
    return paletteGenerator.paletteColors.first.color;
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      YaruIcons.package_snap,
      size: 65,
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
  }) : super(key: key);

  final Color color;
  final String title;
  final String summary;
  final double elevation;
  final Widget icon;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: color,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: Align(
        alignment: Alignment.center,
        child: ListTile(
          subtitle: Text(summary, overflow: TextOverflow.ellipsis),
          title: Text(
            title,
            style: TextStyle(fontSize: 20),
          ),
          leading: SizedBox(
            width: 60,
            child: icon,
          ),
        ),
      ),
    );
  }
}
