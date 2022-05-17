import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_icons/yaru_icons.dart';

class AppCard extends StatelessWidget {
  const AppCard({Key? key, this.onTap, required this.snap}) : super(key: key);

  final Function()? onTap;
  final Snap snap;

  @override
  Widget build(BuildContext context) {
    Widget image = Icon(
      YaruIcons.snapcraft,
      size: 50,
    );
    for (var i = 0; i < snap.media.length; i++) {
      if (snap.media[i].type == 'icon') {
        image = Padding(
          padding: const EdgeInsets.all(15.0),
          child: Image.network(
            snap.media[i].url,
          ),
        );
        break;
      }
    }
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).cardColor
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: image,
      ),
    );
  }
}
