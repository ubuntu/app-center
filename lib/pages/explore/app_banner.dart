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
    Icon fallBackIcon = Icon(
      YaruIcons.package_snap,
      size: 65,
    );
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
      child: surfaceTint
          ? FutureBuilder<Color>(
              future: iconIndex != null
                  ? getSurfaceTintColor(NetworkImage(snap.media[iconIndex].url))
                  : Future(() => Theme.of(context).primaryColor),
              builder: (context, snapshot) => Card(
                surfaceTintColor: snapshot.data == null
                    ? light
                        ? YaruColors.warmGrey.shade900
                        : Theme.of(context).colorScheme.onBackground
                    : snapshot.data,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: ListTile(
                    subtitle:
                        Text(snap.summary, overflow: TextOverflow.ellipsis),
                    title: Text(
                      snap.title,
                      style: TextStyle(fontSize: 20),
                    ),
                    leading: SizedBox(
                      width: 60,
                      child: iconIndex != null
                          ? Image.network(
                              snap.media[iconIndex].url,
                              fit: BoxFit.fitHeight,
                              filterQuality: FilterQuality.medium,
                            )
                          : fallBackIcon,
                    ),
                  ),
                ),
              ),
            )
          : Card(
              surfaceTintColor: light
                  ? YaruColors.warmGrey.shade900
                  : Theme.of(context).colorScheme.onBackground,
              elevation: light ? 2 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius,
              ),
              child: Align(
                alignment: Alignment.center,
                child: ListTile(
                  subtitle: Text(snap.summary, overflow: TextOverflow.ellipsis),
                  title: Text(
                    snap.title,
                    style: TextStyle(fontSize: 20),
                  ),
                  leading: SizedBox(
                    width: 60,
                    child: iconIndex != null
                        ? Image.network(
                            snap.media[iconIndex].url,
                            fit: BoxFit.fitHeight,
                            filterQuality: FilterQuality.medium,
                          )
                        : fallBackIcon,
                  ),
                ),
              ),
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
