import 'package:flutter/material.dart';
import 'package:software/store_app/common/safe_image.dart';
import 'package:yaru_icons/yaru_icons.dart';

class SnapIcon extends StatelessWidget {
  const SnapIcon(
    this.url, {
    Key? key,
  }) : super(key: key);

  final String? url;

  @override
  Widget build(BuildContext context) {
    return SafeImage(
      url: url,
      fallBackIconData: YaruIcons.package_snap,
    );
  }
}
