import 'dart:async';
import 'dart:collection';

import 'package:app_center/appstream/appstream_utils.dart';
import 'package:app_center/appstream/logger.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/mapping/identifier_normalization.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:snowball_stemmer/snowball_stemmer.dart';

@immutable
class _CachedComponent {
  const _CachedComponent(
    this.index,
    this.rawId,
    this.id,
    this.name,
    this.keywords,
    this.summary,
    this.description,
    this.origin,
    this.package,
    this.mediaTypes,
  );

  factory _CachedComponent.fromAppstream(
    int index,
    AppstreamComponent component,
    Map<String, String> sharedWords,
  ) {
    final id = component.getId();
    final name = component.getLocalizedName().toLowerCase();
    const origin = '';
    final package = component.getPackage();
    final mediaTypes = component.getLocalizedMediaTypes();

    // One copy of each word for all components; match() only tests membership.
    List<String> words(Iterable<String> all) => {
      for (final word in all) sharedWords[word] ??= word,
    }.toList(growable: false);

    final keywords = words(
      component.getLocalizedKeywords().map((e) => e.toLowerCase()),
    );

    final nonWordCharacters = RegExp('\\W');

    final summary = words(
      component.getLocalizedSummary().toLowerCase().split(nonWordCharacters),
    );

    final description = words(
      component.getLocalizedDescription().toLowerCase().split(
        nonWordCharacters,
      ),
    );

    return _CachedComponent(
      index,
      component.id,
      id,
      name,
      keywords,
      summary,
      description,
      origin,
      package,
      mediaTypes,
    );
  }

  // Holds the pool position, not the component, so the cache keeps no objects.
  final int index;
  final String rawId;
  final String id;
  final String name;
  final List<String> keywords;
  final List<String> summary;
  final List<String> description;
  final String origin;
  final String package;
  final List<String> mediaTypes;

  int match(List<String> tokens) {
    var score = _MatchScore.none.value;

    for (final token in tokens) {
      if (id.contains(token)) {
        score |= _MatchScore.id.value;
      }
      if (name.contains(token)) {
        score |= _MatchScore.name.value;
      }
      if (keywords.contains(token)) {
        score |= _MatchScore.keyword.value;
      }
      if (summary.contains(token)) {
        score |= _MatchScore.summary.value;
      }
      if (description.contains(token)) {
        score |= _MatchScore.description.value;
      }
      if (origin.contains(token)) {
        score |= _MatchScore.origin.value;
      }
      if (package.contains(token)) {
        score |= _MatchScore.pkgName.value;
      }
      if (mediaTypes.any((e) => e.contains(token))) {
        score |= _MatchScore.mediaType.value;
      }
      if (score == _MatchScore.all.value) break;
    }
    return score;
  }

  @override
  bool operator ==(Object other) =>
      other is _CachedComponent && rawId == other.rawId;

  @override
  int get hashCode => rawId.hashCode;
}

enum _MatchScore {
  none(0),
  mediaType(1 << 0),
  pkgName(1 << 1),
  origin(1 << 2),
  description(1 << 3),
  summary(1 << 4),
  keyword(1 << 5),
  name(1 << 6),
  id(1 << 7),
  all(1 << 0 | 1 << 1 | 1 << 2 | 1 << 3 | 1 << 4 | 1 << 5 | 1 << 6 | 1 << 7);

  const _MatchScore(this.value);

  final int value;
}

class _ScoredComponent {
  const _ScoredComponent(this.score, this.index);
  final int score;
  final int index;
}

/// Components by package name, read from the pool when asked for.
class _ComponentsByPackage
    extends UnmodifiableMapBase<String, AppstreamComponent> {
  _ComponentsByPackage(this._positions, this._components);

  final Map<String, int> _positions;
  final List<AppstreamComponent> _components;

  @override
  AppstreamComponent? operator [](Object? key) {
    final position = _positions[key];
    return position == null ? null : _components[position];
  }

  @override
  bool containsKey(Object? key) => _positions.containsKey(key);

  @override
  Iterable<String> get keys => _positions.keys;

  @override
  int get length => _positions.length;
}

class AppstreamService {
  // TODO: cache AppstreamPool
  AppstreamService({@visibleForTesting AppstreamPool? pool})
    : _pool = pool ?? _createPool(),
      _l10n = _loadL10n() {
    // The pool has only startup-locale text, so a new locale falls back to `C`.
    PlatformDispatcher.instance.onLocaleChanged = () async {
      await _loader;
      _populateCache();
    };
  }

  final AppstreamPool _pool;

  // Catalogs hold hundreds of locales; keep only the ones the app can show.
  static AppstreamPool _createPool() {
    final keys = translationKeys(PlatformDispatcher.instance.locale);
    return AppstreamPool(
      locales: keys.isEmpty ? null : keys,
      // languages and contentRatings stay: the deb details model reads them.
      omit: const {
        AppstreamDetail.cachedIcons,
        AppstreamDetail.releaseNotes,
        AppstreamDetail.screenshotCaptions,
        AppstreamDetail.screenshotThumbnails,
      },
    );
  }

  late final Future<void> _loader = _pool.load().then((_) {
    _populateCache();
    _initialized = true;
  });
  bool _initialized = false;
  final HashSet<_CachedComponent> _cache = HashSet<_CachedComponent>();
  // Pool positions, not components: maps of components would pin them all.
  final _componentsById = <String, int>{};
  final _componentsByDesktopId = <String, int>{};
  final _componentsByAlias = <String, int>{};
  final _componentsByPackage = <String, int>{};
  var _components = const <AppstreamComponent>[];

  bool get initialized => _initialized;

  @visibleForTesting
  int get cacheSize => _cache.length;

  Map<String, AppstreamComponent> getComponentsByPackage() =>
      _ComponentsByPackage(Map.unmodifiable(_componentsByPackage), _components);

  Future<void> init() async => _loader;

  Future<void> reload() async {
    await _pool.load();
    _populateCache();
  }

  void _populateCache() {
    _cache.clear();
    _componentsById.clear();
    _componentsByDesktopId.clear();
    _componentsByAlias.clear();
    _componentsByPackage.clear();

    _components = _pool.components;
    final sharedWords = <String, String>{};
    // Duplicates compare keys by position, so no component is decoded twice.
    final keys = <String>[];
    var position = 0;
    // A pass decodes each component afresh and keeps none of them.
    for (final component in _components) {
      keys.add(_componentKey(component));
      _cache.add(
        _CachedComponent.fromAppstream(position, component, sharedWords),
      );
      _index(_componentsById, component.id, position, keys);
      for (final launchable
          in component.launchables.whereType<AppstreamLaunchableDesktopId>()) {
        _index(
          _componentsByDesktopId,
          normalizeDesktopId(launchable.desktopId),
          position,
          keys,
        );
      }
      for (final provide
          in component.provides.whereType<AppstreamProvidesId>()) {
        _index(_componentsByAlias, provide.id, position, keys);
      }
      final packageName = component.getPackage();
      if (packageName.isNotEmpty) {
        _index(_componentsByPackage, packageName, position, keys);
      }
      position++;
    }
  }

  void _index(
    Map<String, int> index,
    String key,
    int position,
    List<String> componentKeys,
  ) {
    final normalizedKey = key.trim().toLowerCase();
    if (normalizedKey.isEmpty) return;
    final current = index[normalizedKey];
    if (current == null ||
        componentKeys[position].compareTo(componentKeys[current]) < 0) {
      index[normalizedKey] = position;
    }
  }

  String _componentKey(AppstreamComponent component) =>
      '${component.id.toLowerCase()}|${component.package?.toLowerCase() ?? ''}|${component.type.name}';

  final AppLocalizations _l10n;

  static AppLocalizations _loadL10n() {
    late final Locale locale;
    if (AppLocalizations.supportedLocales
        .map((l) => l.languageCode)
        .contains(PlatformDispatcher.instance.locale.languageCode)) {
      locale = PlatformDispatcher.instance.locale;
    } else {
      locale = const Locale('en');
      log.info(
        'Unsupported locale: ${PlatformDispatcher.instance.locale}. Defaulting to "en".',
      );
    }
    return lookupAppLocalizations(locale);
  }

  List<String> get _greyList => _l10n.appstreamSearchGreylist.split(';');

  AppstreamComponent? _componentAt(int? position) =>
      position == null ? null : _components[position];

  Future<AppstreamComponent?> findById(String id) async {
    await init();
    return _componentAt(_componentsById[id.trim().toLowerCase()]);
  }

  Future<AppstreamComponent?> findByDesktopId(String desktopId) async {
    await init();
    return _componentAt(_componentsByDesktopId[normalizeDesktopId(desktopId)]);
  }

  Future<AppstreamComponent?> findByAlias(String alias) async {
    await init();
    return _componentAt(_componentsByAlias[alias.trim().toLowerCase()]);
  }

  Future<AppstreamComponent?> findByPackageName(String packageName) async {
    await init();
    return _componentAt(_componentsByPackage[packageName.trim().toLowerCase()]);
  }

  static final stemmersMap = <String, Algorithm>{
    'ar': Algorithm.arabic,
    'hy': Algorithm.armenian,
    'eu': Algorithm.basque,
    'ca': Algorithm.catalan,
    'da': Algorithm.danish,
    'nl': Algorithm.dutch,
    'en': Algorithm.english,
    'fi': Algorithm.finnish,
    'fr': Algorithm.french,
    'de': Algorithm.german,
    'el': Algorithm.greek,
    'hi': Algorithm.hindi,
    'hu': Algorithm.hungarian,
    'id': Algorithm.indonesian,
    'ga': Algorithm.irish,
    'it': Algorithm.italian,
    'lt': Algorithm.lithuanian,
    'ne': Algorithm.nepali,
    'nb': Algorithm.norwegian,
    'pt': Algorithm.portuguese,
    'ro': Algorithm.romanian,
    'ru': Algorithm.russian,
    'sr': Algorithm.serbian,
    'es': Algorithm.spanish,
    'sv': Algorithm.swedish,
    'ta': Algorithm.tamil,
    'tr': Algorithm.turkish,
    'yi': Algorithm.yiddish,
  };

  // Re-implementation of as_pool_build_search_tokens()
  // (https://www.freedesktop.org/software/appstream/docs/api/appstream-AsPool.html#as-pool-build-search-tokens)
  List<String> _buildSearchTokens(String search) {
    final words = search.toLowerCase().split(RegExp(r'\s'));
    // Filter out too generic search terms
    words.removeWhere((element) => _greyList.contains(element));
    if (words.isEmpty) {
      words.addAll(search.toLowerCase().split(RegExp(r'\s')));
    }
    // Filter out short tokens, and those containing markup
    words.removeWhere(
      (element) => element.length <= 1 || element.contains(RegExp('[<>()]')),
    );
    // Extract only the common stems from the tokens
    final algorithm =
        stemmersMap[PlatformDispatcher.instance.locale.languageCode];
    if (algorithm != null) {
      final stemmer = SnowballStemmer(algorithm);
      return words
          .map(stemmer.stem)
          // Keep original tokens as well, since the stemming algorithm might
          // have unintended effects. See #1305.
          .followedBy(words)
          .toSet()
          .toList();
    } else {
      return words;
    }
  }

  // Re-implementation of as_pool_search()
  // (https://www.freedesktop.org/software/appstream/docs/api/appstream-AsPool.html#as-pool-search)
  Future<List<AppstreamComponent>> search(String search) async {
    final tokens = _buildSearchTokens(search);
    await _loader;
    if (tokens.isEmpty) {
      if (search.length <= 1) {
        // Search query too broad, matching everything
        return _components;
      } else {
        // No valid search tokens
        return [];
      }
    }
    final scored = <_ScoredComponent>[];
    for (final entry in _cache) {
      final score = entry.match(tokens);
      if (score > 0) {
        scored.add(_ScoredComponent(score, entry.index));
      }
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return [for (final entry in scored) _components[entry.index]];
  }

  AppstreamComponent getFromId(String id) {
    // Even though appstream IDs are unique, we can have multiple entries with
    // the same ID in the pool, since we're loading the metadata from multiple
    // sources. The reverse index chooses the deterministic preferred entry.
    // TODO: Remove duplicate appstream components.
    final position = _componentsById[id.trim().toLowerCase()];
    assert(position != null, 'Component not found');
    return _components[position!];
  }
}
