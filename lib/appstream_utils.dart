import 'dart:ui';

import 'package:appstream/appstream.dart';
import 'package:packagekit/packagekit.dart';
import 'package:software/services/package_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

String? bestLanguageKey(Iterable<String> keys, {Locale? locale}) {
  locale = locale ?? PlatformDispatcher.instance.locale;
  if (locale.toLanguageTag() != 'und') {
    var key = '${locale.languageCode}_${locale.countryCode}';
    if (keys.contains(key)) return key;
    key = locale.languageCode;
    if (keys.contains(key)) return key;
  }
  const fallback = 'C';
  if (keys.contains(fallback)) return fallback;
  return null;
}

extension LocalizedComponent on AppstreamComponent {
  String localizedName({Locale? locale}) =>
      name[bestLanguageKey(name.keys, locale: locale)] ?? '';
  String localizedSummary({Locale? locale}) =>
      summary[bestLanguageKey(summary.keys, locale: locale)] ?? '';
  String localizedDescription({Locale? locale}) =>
      description[bestLanguageKey(description.keys, locale: locale)] ?? '';
}

extension PackageKitId on AppstreamComponent {
  Future<PackageKitPackageId> get packageKitId =>
      getService<PackageService>().resolve(package ?? id);
}

extension Icons on AppstreamComponent {
  // Naive implementation, we probably want to favour locally-cached icons first,
  // which will require refactoring the AppIcon widget to accept local file paths.
  // See https://www.freedesktop.org/software/appstream/docs/sect-AppStream-IconCache.html
  String? get remoteIcon {
    for (final icon in icons) {
      if (icon is AppstreamRemoteIcon) {
        return icon.url;
      }
    }
    return null;
  }
}
