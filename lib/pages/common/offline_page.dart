import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';

class OfflinePage extends StatelessWidget {
  const OfflinePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            YaruIcons.network_wireless_disabled,
            size: 200,
            color: Theme.of(context).disabledColor,
          ),
          Text(
            'Offline',
            style: Theme.of(context).textTheme.headline3,
          )
        ],
      ),
    );
  }
}
