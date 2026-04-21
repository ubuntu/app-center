import 'dart:io';
import 'dart:isolate';

import 'package:app_center/l10n.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter/foundation.dart';
import 'package:gsettings/gsettings.dart';
import 'package:path/path.dart' as p;
import 'package:snapd/snapd.dart';
import 'package:ubuntu_logger/ubuntu_logger.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;

final log = Logger('apps_utils');

enum AppConfinement {
  unknown,
  strict,
  development,
  classic,
  unrestricted;

  factory AppConfinement.fromSnap(SnapConfinement confinement) =>
      switch (confinement) {
        SnapConfinement.unknown => AppConfinement.unknown,
        SnapConfinement.strict => AppConfinement.strict,
        SnapConfinement.devmode => AppConfinement.development,
        SnapConfinement.classic => AppConfinement.classic,
      };

  factory AppConfinement.fromDeb() => AppConfinement.unrestricted;
}

enum AppLink {
  unknown,
  homepage,
  contact;

  factory AppLink.fromAppstream(AppstreamUrlType appstreamUrlType) =>
      switch (appstreamUrlType) {
        AppstreamUrlType.homepage => AppLink.homepage,
        AppstreamUrlType.contact => AppLink.contact,
        _ => AppLink.unknown,
      };
}

extension AppLinkL10n on AppLink {
  String localize(AppLocalizations l10n, AppMetadata data) {
    return switch (this) {
      AppLink.unknown => l10n.appUrlTypeUnknown,
      AppLink.homepage => l10n.appUrlTypeHomepage,
      AppLink.contact => l10n.appUrlTypeContact(data.publisher ?? ''),
    };
  }
}

/// Common metadata found between package types.
abstract class AppMetadata {
  String? get publisher;
  AppConfinement? get confinement;
  String? get license;
  String? get version;
  DateTime? get published;
  int? get downloadSize;
  Map<AppLink, String>? get links;
}

extension AppConfinementL10n on AppConfinement {
  String localize(AppLocalizations l10n) => switch (this) {
        AppConfinement.unrestricted => l10n.appConfinementUnrestricted,
        AppConfinement.classic => l10n.appConfinementClassic,
        AppConfinement.development => l10n.appConfinementDevelopment,
        AppConfinement.strict => l10n.appConfinementStrict,
        AppConfinement.unknown => l10n.appConfinementUnknown,
      };

  String? localizeTooltip(AppLocalizations l10n) => switch (this) {
        AppConfinement.unrestricted => l10n.appConfinementUnrestrictedTooltip,
        AppConfinement.classic => l10n.appConfinementClassicTooltip,
        AppConfinement.strict => l10n.appConfinementStrictTooltip,
        _ => null,
      };
}

/// Returns the name of the active GTK icon theme by querying GSettings.
@visibleForTesting
Future<String?> activeIconTheme({
  String? configHome,
  GSettingsBackend? backend,
}) async {
  final settings = GSettings(
    'org.gnome.desktop.interface',
    backend: backend,
  );
  try {
    final value = await settings.get('icon-theme');
    final themeName = value.asString().trim();
    if (themeName.isNotEmpty) return themeName;
  } on Exception catch (e) {
    log.warning('Could not get icon theme from schema: $e');
  } finally {
    await settings.close();
  }

  // gtk-3.0/settings.ini fallback
  final gtk3Settings = File(
    p.join(configHome ?? xdg.configHome.path, 'gtk-3.0', 'settings.ini'),
  );
  if (gtk3Settings.existsSync()) {
    for (final line in gtk3Settings.readAsLinesSync()) {
      if (line.startsWith('gtk-icon-theme-name')) {
        final parts = line.split('=');
        if (parts.length == 2) {
          final themeName = parts[1].trim();
          if (themeName.isNotEmpty) return themeName;
        }
        break;
      }
    }
  }

  return null;
}

final _iconPathCache = <String, Future<String?>>{};

/// Looks up a local filesystem path for a stock icon named [name] by searching
/// XDG icon theme directories.
Future<String?> lookupThemedIcon(String name) =>
    _iconPathCache.putIfAbsent(name, () async {
      try {
        return Isolate.run(() async {
          final dataDirs =
              [xdg.dataHome, ...xdg.dataDirs].map((d) => d.path).toList();
          final theme = await activeIconTheme();
          return lookupIconInDirs(
            name,
            dataDirs: dataDirs,
            theme: theme,
            pixmapsDir: '/usr/share/pixmaps',
          );
        });
      } on Exception catch (_) {
        return null;
      }
    });

/// Searches [dataDirs] and [pixmapsDir] for an icon file named [name] under
/// [theme], using the standard XDG size and context subdirectory layout.
@visibleForTesting
String? lookupIconInDirs(
  String name, {
  required List<String> dataDirs,
  required String? theme,
  required String pixmapsDir,
}) {
  const supportedExtensions = ['.svg', '.png', '.xpm'];
  const sizes = ['scalable', '256x256', '128x128', '64x64', '48x48'];
  const iconSubdirs = ['apps', 'categories'];

  if (theme != null) {
    for (final dataDir in dataDirs) {
      for (final size in sizes) {
        for (final subdir in iconSubdirs) {
          for (final ext in supportedExtensions) {
            final path =
                p.join(dataDir, 'icons', theme, size, subdir, '$name$ext');
            if (File(path).existsSync()) return path;
          }
        }
      }
    }
  }

  for (final ext in supportedExtensions) {
    final path = p.join(pixmapsDir, '$name$ext');
    if (File(path).existsSync()) return path;
  }

  return null;
}
