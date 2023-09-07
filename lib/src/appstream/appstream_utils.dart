import 'dart:ui';

import 'package:appstream/appstream.dart';

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
    final List<String> mediaTypes = [];

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

    for (final String candidate in candidates) {
      if (keys.contains(candidate)) return candidate;
    }

    return null;
  }
}
