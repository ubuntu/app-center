import 'dart:io';
import 'dart:ui';

import 'package:appstream/appstream.dart';
import 'package:collection/collection.dart';
import 'package:packagekit/packagekit.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

String? bestLanguageKey(Iterable<String> keys, {Locale? locale}) {
  locale ??= PlatformDispatcher.instance.locale;
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

int _sizeComparison(int? a, int? b) => a?.compareTo(b ?? 0) ?? 0;

extension Icons on AppstreamComponent {
  String? get icon {
    final cached = icons.whereType<AppstreamCachedIcon>().toList();
    cached.sort((a, b) => _sizeComparison(b.width, a.width));
    //for (final icon in cached) {
    //  XXX: we need the origin to determine if a cached icon exists on disk
    //  (https://github.com/canonical/appstream.dart/issues/25)
    //}

    final local = icons.whereType<AppstreamLocalIcon>().toList();
    local.sort((a, b) => _sizeComparison(b.width, a.width));
    for (final icon in local) {
      if (File(icon.filename).existsSync()) {
        return icon.filename;
      }
    }

    final stock = icons.whereType<AppstreamStockIcon>().firstOrNull;
    if (stock != null) {
      // TODO: check whether the stock icon exists on disk, and return it
    }

    final remote = icons.whereType<AppstreamRemoteIcon>().firstOrNull;
    return remote?.url;
  }
}
