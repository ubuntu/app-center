import 'package:app_center/apps/apps_utils.dart';
import 'package:appstream/appstream.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

extension _GetOrDefault<K, V> on Map<K, V> {
  V getOrDefault(K? key, V fallback) {
    if (key == null) {
      return fallback;
    }

    return this[key] ?? fallback;
  }
}

extension LocalizedComponent on AppstreamComponent {
  String getId() => id.toLowerCase();
  String getPackage() => package?.toLowerCase() ?? '';

  String getLocalizedName() {
    final key = bestLanguageKey(name);
    return name.getOrDefault(key, '');
  }

  String getLocalizedDeveloperName() {
    final key = bestLanguageKey(name);
    return developerName.getOrDefault(key, '');
  }

  List<String> getLocalizedKeywords() {
    final key = bestLanguageKey(keywords);
    return keywords.getOrDefault(key, []);
  }

  String getLocalizedSummary() {
    final key = bestLanguageKey(summary);
    return summary.getOrDefault(key, '');
  }

  String getLocalizedDescription() {
    final key = bestLanguageKey(description);
    return description.getOrDefault(key, '');
  }

  List<String> getLocalizedMediaTypes() {
    final mediaTypes = <String>[];

    for (final provider in provides) {
      if (provider is AppstreamProvidesMediatype) {
        mediaTypes.add(provider.mediaType.toLowerCase());
      }
    }

    return mediaTypes;
  }

  String? bestLanguageKey<T>(Map<String, T> keyedByLanguage) {
    final locale = PlatformDispatcher.instance.locale;

    if (locale.toLanguageTag() == 'und') return null;

    final countryCode = locale.countryCode;
    final languageCode = locale.languageCode;
    final fullLocale = '${languageCode}_$countryCode';
    const fallback = 'C';
    final candidates = [fullLocale, languageCode, fallback];
    final keys = keyedByLanguage.keys;

    for (final candidate in candidates) {
      if (keys.contains(candidate)) return candidate;
    }

    return null;
  }
}

extension Metadata on AppstreamComponent {
  /// Returns true if this component is marked compulsory for any desktop in
  /// [desktops].
  bool isCompulsoryFor(Iterable<String> desktops) {
    final running = desktops.map((d) => d.toLowerCase()).toSet();
    return compulsoryForDesktops.any(
      (d) => running.contains(d.toLowerCase()),
    );
  }

  /// The stock icon name from the Appstream metadata (e.g. `org.gnome.Nautilus`),
  /// or `null` if this component has no stock icon.
  String? get iconName {
    final stockIcon = icons.whereType<AppstreamStockIcon>().firstOrNull;
    return stockIcon?.name;
  }

  /// Resolves the local themed icon path off, falling back to [remoteIconUrl].
  Future<String?> get iconAsync async {
    final stockName = iconName;
    if (stockName != null) {
      final localPath = await lookupThemedIcon(stockName);
      if (localPath != null) return localPath;
    }
    return remoteIconUrl;
  }

  /// The remote icon URL from Appstream metadata, or `null` if not present.
  String? get remoteIconUrl {
    final remoteIcon = icons.whereType<AppstreamRemoteIcon>().firstOrNull;
    return remoteIcon?.url;
  }

  String? get website {
    return urls
        .firstWhereOrNull((url) => url.type == AppstreamUrlType.homepage)
        ?.url;
  }

  List<String> get screenshotUrls => screenshots
      .map(
        (screenshot) => screenshot.images
            .where((image) => image.type == AppstreamImageType.source)
            .map((image) => image.url),
      )
      .expand((images) => images)
      .toList();
}
