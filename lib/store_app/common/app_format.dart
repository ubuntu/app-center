import 'package:flutter/material.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';

enum AppFormat {
  snap,
  packageKit;

  String localize(AppLocalizations l10n) {
    switch (this) {
      case AppFormat.snap:
        return l10n.snapPackages;
      case AppFormat.packageKit:
        return l10n.debianPackages;
      default:
        return '';
    }
  }
}

final Map<AppFormat, IconData> appFormatToIconData = {
  AppFormat.snap: YaruIcons.snapcraft,
  AppFormat.packageKit: YaruIcons.debian,
};
