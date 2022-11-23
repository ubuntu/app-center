import 'dart:ui';

import 'package:appstream/appstream.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software/appstream_utils.dart';

void main() {
  test('best language key', () {
    expect(
      bestLanguageKey(['fr', 'en', 'C'], locale: const Locale('und')),
      'C',
    );
    expect(bestLanguageKey(['fr', 'en'], locale: const Locale('und')), isNull);
    expect(bestLanguageKey(['fr', 'en', 'C'], locale: const Locale('es')), 'C');
    expect(bestLanguageKey(['fr', 'en'], locale: const Locale('es')), isNull);
    expect(
      bestLanguageKey(
        ['fr', 'en', 'es_ES'],
        locale: const Locale('es', 'ES'),
      ),
      'es_ES',
    );
    expect(
      bestLanguageKey(
        ['fr', 'en', 'es'],
        locale: const Locale('es', 'ES'),
      ),
      'es',
    );
  });

  test('localized component', () {
    const component = AppstreamComponent(
      id: 'id',
      type: AppstreamComponentType.desktopApplication,
      package: 'package',
      name: {'en': 'name', 'fr': 'nom', 'C': 'fallback name'},
      summary: {'en': 'summary', 'fr': 'résumé', 'C': 'fallback summary'},
      description: {
        'en': 'hello',
        'fr': 'bonjour',
        'C': 'fallback description'
      },
    );
    const localeEn = Locale('en', 'US');
    const localeFr = Locale('fr', 'FR');
    const localeEs = Locale('es', 'AR');
    expect(component.localizedName(locale: localeEn), 'name');
    expect(component.localizedName(locale: localeFr), 'nom');
    expect(component.localizedName(locale: localeEs), 'fallback name');
    expect(component.localizedSummary(locale: localeEn), 'summary');
    expect(component.localizedSummary(locale: localeFr), 'résumé');
    expect(component.localizedSummary(locale: localeEs), 'fallback summary');
    expect(component.localizedDescription(locale: localeEn), 'hello');
    expect(component.localizedDescription(locale: localeFr), 'bonjour');
    expect(
      component.localizedDescription(locale: localeEs),
      'fallback description',
    );
  });
}
