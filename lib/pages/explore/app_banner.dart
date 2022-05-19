import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_icons/yaru_icons.dart';

class AppBanner extends StatelessWidget {
  const AppBanner({
    Key? key,
    required this.snap,
    this.onTap,
  }) : super(key: key);

  final Snap snap;
  final Function()? onTap;

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
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: FutureBuilder<Color>(
        future: getSurfaceTintColor(NetworkImage(snap.media[iconIndex!].url)),
        builder: (context, snapshot) => Card(
          surfaceTintColor: snapshot.data,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
          child: Align(
            alignment: Alignment.center,
            child: ListTile(
              subtitle: Text(snap.summary),
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
                      )
                    : fallBackIcon,
              ),
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
