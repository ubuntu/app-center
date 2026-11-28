import 'package:app_center/src/l10n/app_localizations.g.dart';
import 'package:app_center/widgets/legacy_material_bridge.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ubuntu_localizations/ubuntu_localizations.dart';

export 'package:app_center/src/l10n/app_localizations.g.dart';
export 'package:ubuntu_localizations/ubuntu_localizations.dart';

final List<Locale> supportedLocales = {
  const Locale('en'),
  ...List.of(AppLocalizations.supportedLocales)..remove(const Locale('en')),
}.toList();

const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  ...GlobalUbuntuLocalizations.delegates,
  ...GlobalMaterialLocalizations.delegates,
  ...legacyLocalizationsDelegates,
];
