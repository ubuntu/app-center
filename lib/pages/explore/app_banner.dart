import 'package:flutter/material.dart';
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
    final size = MediaQuery.of(context).size;
    final double titleFontSize =
        size.width > 1200 && size.height > 1000 ? 50 : 20;
    Widget image = Icon(
      YaruIcons.package_snap,
      size: 65,
    );
    Widget? banner;
    for (var i = 0; i < snap.media.length; i++) {
      if (snap.media[i].type == 'banner') {
        banner = ClipRRect(
          borderRadius: borderRadius,
          child: Image.network(
            snap.media[i].url,
            fit: BoxFit.fitHeight,
          ),
        );
        break;
      }
      if (snap.media[i].type == 'icon') {
        image = Image.network(
          snap.media[i].url,
          fit: BoxFit.fitHeight,
        );
      }
    }
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        child: banner != null
            ? banner
            : Align(
                alignment: Alignment.center,
                child: ListTile(
                  subtitle: Text(snap.summary),
                  title: Text(
                    snap.title,
                    style: TextStyle(fontSize: titleFontSize),
                  ),
                  leading: SizedBox(
                    width: size.height / 10,
                    child: image,
                  ),
                ),
              ),
      ),
    );
  }
}
