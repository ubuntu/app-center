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
    final size = MediaQuery.of(context).size;
    final double titleFontSize = size.width / 25 > 30 ? 30 : size.width / 25;
    Widget image = Icon(
      YaruIcons.package_snap,
      size: 65,
    );
    for (var i = 0; i < snap.media.length; i++) {
      if (snap.media[i].type == 'icon' &&
          (snap.media[i].url.endsWith('.png') ||
              snap.media[i].url.endsWith('.jpg') ||
              snap.media[i].url.endsWith('.jpeg'))) {
        image = Image.network(
          snap.media[i].url,
          fit: BoxFit.fitHeight,
        );
        break;
      }
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Align(
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
