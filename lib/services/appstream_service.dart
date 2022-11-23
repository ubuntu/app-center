import 'package:appstream/appstream.dart';
import 'package:snowball_stemmer/snowball_stemmer.dart';
import 'package:software/appstream_utils.dart';

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

  // AS_SEARCH_GREYLIST_STR (as-pool.c)
  // TODO: localize
  final _greylist =
      'app;application;package;program;programme;suite;tool'.split(';');

  Future<void> init() async => _loader;
  // TODO: we probably want to build a cache (see AsCache) of the data,
  // filtered by language, and use that cache when searching.

  List<String> _buildSearchTokens(String search) {
    // re-implement as_pool_build_search_tokens
    // (https://www.freedesktop.org/software/appstream/docs/api/appstream-AsPool.html#as-pool-build-search-tokens)
    final tokens = <String>[];
    final words = search.toLowerCase().split(' ');
    words.removeWhere((element) => _greylist.contains(element));
    // TODO: use Characters for proper graphemes separation, create an extension
    // on the Characters class to add useful methods such as the equivalents for
    // g_str_tokenize_and_fold()
    if (words.isEmpty) {
      words.addAll(search.toLowerCase().split(' '));
    }
    // TODO: filter out markup (as_user_search_term_valid) ?
    // FIXME: get the correct algorithm for the current locale, if any
    final stemmer = SnowballStemmer(Algorithm.english);
    tokens.addAll(words.map((element) => stemmer.stem(element)));
    return tokens;
  }

  dynamic _getLocalizedComponentAttribute(Map<String, dynamic> attribute) {
    final languageKey = bestLanguageKey(attribute.keys);
    if (languageKey == null) return null;
    return attribute[languageKey];
  }

  List<String> _tokenize(String? value) {
    // TODO: see as_component_value_tokenize()
    if (value == null) return [];
    return value.split(RegExp('\\W'));
  }

  int _matchComponent(AppstreamComponent component, List<String> tokens) {
    int score = _MatchScore.none.value;
    for (final token in tokens) {
      if (component.id.contains(token)) {
        score |= _MatchScore.id.value;
      }
      if (_getLocalizedComponentAttribute(component.name)?.contains(token) ==
          true) {
        score |= _MatchScore.name.value;
      }
      if (_getLocalizedComponentAttribute(component.keywords)
              ?.contains(token) ==
          true) {
        score |= _MatchScore.keyword.value;
      }
      if (_tokenize(_getLocalizedComponentAttribute(component.summary))
              .contains(token) ==
          true) {
        score |= _MatchScore.summary.value;
      }
      if (_tokenize(_getLocalizedComponentAttribute(component.description))
              .contains(token) ==
          true) {
        score |= _MatchScore.description.value;
      }
      // TODO: to match on origin, need the parent collection's origin,
      // which we don't have access to here.
      if (component.package?.contains(token) == true) {
        score |= _MatchScore.pkgName.value;
      }
      for (final provider in component.provides) {
        if (provider is AppstreamProvidesMediatype) {
          if (provider.mediaType.contains(token)) {
            score |= _MatchScore.mediaType.value;
            break;
          }
        }
      }
      if (score == _MatchScore.all.value) break;
    }
    return score;
  }

  Future<List<AppstreamComponent>> search(String search) async {
    // re-implement as_pool_search
    // (https://www.freedesktop.org/software/appstream/docs/api/appstream-AsPool.html#as-pool-search)
    await _loader;
    final tokens = _buildSearchTokens(search);
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
