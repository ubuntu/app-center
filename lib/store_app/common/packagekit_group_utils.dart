import 'package:flutter/widgets.dart';
import 'package:packagekit/packagekit.dart';
import 'package:yaru_icons/yaru_icons.dart';

final packagekitGroupToIcon = <PackageKitGroup, IconData>{
  PackageKitGroup.unknown: YaruIcons.question,
  PackageKitGroup.accessibility: YaruIcons.accessibility,
  PackageKitGroup.accessories: YaruIcons.utilities,
  PackageKitGroup.adminTools: YaruIcons.settings,
  PackageKitGroup.communication: YaruIcons.subtitles,
  PackageKitGroup.desktopGnome: YaruIcons.desktop,
  PackageKitGroup.desktopKde: YaruIcons.desktop,
  PackageKitGroup.desktopOther: YaruIcons.desktop,
  PackageKitGroup.desktopXfce: YaruIcons.desktop,
  PackageKitGroup.education: YaruIcons.education,
  PackageKitGroup.fonts: YaruIcons.font,
  PackageKitGroup.games: YaruIcons.games,
  PackageKitGroup.graphics: YaruIcons.template,
  PackageKitGroup.internet: YaruIcons.network,
  PackageKitGroup.legacy: YaruIcons.hourglass,
  PackageKitGroup.localization: YaruIcons.localization,
  PackageKitGroup.maps: YaruIcons.location,
  PackageKitGroup.multimedia: YaruIcons.multimedia_player,
  PackageKitGroup.network: YaruIcons.network,
  PackageKitGroup.office: YaruIcons.document,
  PackageKitGroup.other: YaruIcons.question,
  PackageKitGroup.powerManagement: YaruIcons.power,
  PackageKitGroup.programming: YaruIcons.wrench,
  PackageKitGroup.publishing: YaruIcons.book,
  PackageKitGroup.repos: YaruIcons.question,
  PackageKitGroup.security: YaruIcons.shield,
  PackageKitGroup.servers: YaruIcons.server,
  PackageKitGroup.system: YaruIcons.computer,
  PackageKitGroup.virtualization: YaruIcons.flatpak,
  PackageKitGroup.science: YaruIcons.beaker,
  PackageKitGroup.documentation: YaruIcons.question,
  PackageKitGroup.electronics: YaruIcons.chip,
  PackageKitGroup.collections: YaruIcons.question,
  PackageKitGroup.vendor: YaruIcons.ubuntu_logo,
  PackageKitGroup.newest: YaruIcons.star
};
