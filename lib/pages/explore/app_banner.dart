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
    Widget image = Icon(
      YaruIcons.package_snap,
      size: 65,
    );
    for (var i = 0; i < snap.media.length; i++) {
      if (snap.media[i].type == 'icon') {
        image = Image.network(
          snap.media[i].url,
          fit: BoxFit.fitHeight,
        );
      }
      break;
    }
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Card(
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
              child: image,
            ),
          ),
        ),
      ),
    );
  }
}
