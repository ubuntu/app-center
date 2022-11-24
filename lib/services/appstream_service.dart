import 'dart:ui';

import 'package:appstream/appstream.dart';
import 'package:snowball_stemmer/snowball_stemmer.dart';
import 'package:software/appstream_utils.dart';
import 'package:software/l10n/l10n.dart';

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

  final int value;
  const _MatchScore(this.value);
}

class _ScoredComponent {
  final int score;
  final AppstreamComponent component;
  const _ScoredComponent(this.score, this.component);
}

class AppstreamService {
  final AppstreamPool _pool;
  late final Future<void> _loader = _pool.load();

  AppstreamService() : _pool = AppstreamPool();

  List<String> get _greylist =>
      lookupAppLocalizations(PlatformDispatcher.instance.locale)
          .appstreamSearchGreylist
          .split(';');

  Future<void> init() async => _loader;
  // TODO: we probably want to build a cache (see AsCache) of the data,
  // filtered by language, and use that cache when searching.

  Algorithm? _selectPreferredStemmer() {
    final locale = PlatformDispatcher.instance.locale;
    switch (locale.languageCode) {
      case 'ar':
        return Algorithm.arabic;
      case 'hy':
        return Algorithm.armenian;
      case 'eu':
        return Algorithm.basque;
      case 'ca':
        return Algorithm.catalan;
      case 'da':
        return Algorithm.danish;
      case 'nl':
        return Algorithm.dutch;
      case 'en':
        return Algorithm.english;
      case 'fi':
        return Algorithm.finnish;
      case 'fr':
        return Algorithm.french;
      case 'de':
        return Algorithm.german;
      case 'el':
        return Algorithm.greek;
      case 'hi':
        return Algorithm.hindi;
      case 'hu':
        return Algorithm.hungarian;
      case 'id':
        return Algorithm.indonesian;
      case 'ga':
        return Algorithm.irish;
      case 'it':
        return Algorithm.italian;
      case 'lt':
        return Algorithm.lithuanian;
      case 'ne':
        return Algorithm.nepali;
      case 'nb':
        return Algorithm.norwegian;
      case 'pt':
        return Algorithm.portuguese;
      case 'ro':
        return Algorithm.romanian;
      case 'ru':
        return Algorithm.russian;
      case 'sr':
        return Algorithm.serbian;
      case 'es':
        return Algorithm.spanish;
      case 'sv':
        return Algorithm.swedish;
      case 'ta':
        return Algorithm.tamil;
      case 'tr':
        return Algorithm.turkish;
      case 'yi':
        return Algorithm.yiddish;
      default:
        return null;
    }
  }

  // Re-implementation of as_pool_build_search_tokens()
  // (https://www.freedesktop.org/software/appstream/docs/api/appstream-AsPool.html#as-pool-build-search-tokens)
  List<String> _buildSearchTokens(String search) {
    final words = search.toLowerCase().split(RegExp(r'\s'));
    // Filter out too generic search terms
    words.removeWhere((element) => _greylist.contains(element));
    if (words.isEmpty) {
      words.addAll(search.toLowerCase().split(RegExp(r'\s')));
    }
    // Filter out short tokens, and those containing markup
    words.removeWhere(
      (element) => element.length <= 1 || element.contains(RegExp(r'[<>()]')),
    );
    // Extract only the common stems from the tokens
    final algorithm = _selectPreferredStemmer();
    if (algorithm != null) {
      final stemmer = SnowballStemmer(algorithm);
      return words.map((element) => stemmer.stem(element)).toSet().toList();
    } else {
      return words;
    }
  }

  dynamic _getLocalizedComponentAttribute(Map<String, dynamic> attribute) {
    final languageKey = bestLanguageKey(attribute.keys);
    if (languageKey == null) return null;
    return attribute[languageKey];
  }

  List<String> _tokenize(String? value) =>
      (value != null) ? value.split(RegExp('\\W')) : [];

  int _matchComponent(AppstreamComponent component, List<String> tokens) {
    int score = _MatchScore.none.value;
    for (final token in tokens) {
      if (component.id.toLowerCase().contains(token)) {
        score |= _MatchScore.id.value;
      }
      if (_getLocalizedComponentAttribute(component.name)
              ?.toLowerCase()
              .contains(token) ==
          true) {
        score |= _MatchScore.name.value;
      }
      if (_getLocalizedComponentAttribute(component.keywords)
              ?.any((keyword) => keyword.toLowerCase() == token) ==
          true) {
        score |= _MatchScore.keyword.value;
      }
      if (_tokenize(
            _getLocalizedComponentAttribute(component.summary).toLowerCase(),
          ).contains(token) ==
          true) {
        score |= _MatchScore.summary.value;
      }
      if (_tokenize(
            _getLocalizedComponentAttribute(component.description)
                ?.toLowerCase(),
          ).contains(token) ==
          true) {
        score |= _MatchScore.description.value;
      }
      // ignore: dead_code
      if (false) {
        // XXX: https://github.com/canonical/appstream.dart/issues/25
        score |= _MatchScore.origin.value;
      }
      if (component.package?.toLowerCase().contains(token) == true) {
        score |= _MatchScore.pkgName.value;
      }
      for (final provider in component.provides) {
        if (provider is AppstreamProvidesMediatype) {
          if (provider.mediaType.toLowerCase().contains(token)) {
            score |= _MatchScore.mediaType.value;
            break;
          }
        }
      }
      if (score == _MatchScore.all.value) break;
    }
    return score;
  }

  // Re-implementation of as_pool_search()
  // (https://www.freedesktop.org/software/appstream/docs/api/appstream-AsPool.html#as-pool-search)
  Future<List<AppstreamComponent>> search(String search) async {
    final tokens = _buildSearchTokens(search);
    await _loader;
    if (tokens.isEmpty) {
      if (search.length <= 1) {
        // Search query too broad, matching everything
        return _pool.components;
      } else {
        // No valid search tokens
        return [];
      }
    }
    // TODO: use a cache
    final scored = <_ScoredComponent>[];
    for (final component in _pool.components) {
      final score = _matchComponent(component, tokens);
      if (score > 0) {
        scored.add(_ScoredComponent(score, component));
      }
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.component).toList();
  }
}
