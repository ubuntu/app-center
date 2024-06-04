import 'dart:ui';

import 'package:app_center/l10n.dart';
import 'package:appstream/appstream.dart';
import 'package:collection/collection.dart';

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

extension AppstreamUrlTypeL10n on AppstreamUrlType {
  String localize(AppLocalizations l10n) {
    return switch (this) {
      AppstreamUrlType.bugtracker => l10n.appstreamUrlTypeBugtracker,
      AppstreamUrlType.contact => l10n.appstreamUrlTypeContact,
      AppstreamUrlType.donation => l10n.appstreamUrlTypeDonation,
      AppstreamUrlType.faq => l10n.appstreamUrlTypeFaq,
      AppstreamUrlType.help => l10n.appstreamUrlTypeHelp,
      AppstreamUrlType.homepage => l10n.appstreamUrlTypeHomepage,
      AppstreamUrlType.translate => l10n.appstreamUrlTypeTranslate,
      AppstreamUrlType.vcsBrowser => l10n.appstreamUrlTypeVcsBrowser,
      AppstreamUrlType.contribute => l10n.appstreamUrlTypeContribute,
    };
  }
}

extension Metadata on AppstreamComponent {
  String? get icon {
    final remoteIcon = icons.whereType<AppstreamRemoteIcon>().firstOrNull;
    return remoteIcon?.url;
  }

  String? get website {
    return urls
        .firstWhereOrNull((url) => url.type == AppstreamUrlType.homepage)
        ?.url;
  }

  List<String> get screenshotUrls => screenshots
      .map((screenshot) => screenshot.images
          .where((image) => image.type == AppstreamImageType.source)
          .map((image) => image.url))
      .expand((images) => images)
      .toList();
}
