import 'package:flutter/material.dart';
import 'package:software/l10n/l10n.dart';

extension ThemeModeX on ThemeMode {
  String localize(AppLocalizations l10n) {
    switch (this) {
      case ThemeMode.system:
        return l10n.system;
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.light:
        return l10n.light;
    }
  }
}
