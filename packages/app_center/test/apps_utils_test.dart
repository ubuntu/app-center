import 'dart:io';

import 'package:app_center/apps/apps_utils.dart';
import 'package:dbus/dbus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsettings/gsettings.dart';
import 'package:path/path.dart' as p;

void main() {
  group('activeIconTheme', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync();
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('returns theme seeded into GSettings memory backend', () async {
      final backend = GSettingsMemoryBackend();
      await backend
          .set({'/org/gnome/desktop/interface/icon-theme': DBusString('Yaru')});

      final theme = await activeIconTheme(
        configHome: tempDir.path,
        backend: backend,
      );
      expect(theme, equals('Yaru'));
    });

    test('falls back to gtk-3.0/settings.ini when GSettings unavailable',
        () async {
      final backend = GSettingsMemoryBackend();
      await backend.set({
        '/org/gnome/desktop/interface/icon-theme': const DBusString(''),
      });

      final settingsDir = Directory(p.join(tempDir.path, 'gtk-3.0'))
        ..createSync();
      File(p.join(settingsDir.path, 'settings.ini')).writeAsStringSync('''
[Settings]
gtk-icon-theme-name=TestThemeFromINI
''');

      final theme = await activeIconTheme(
        configHome: tempDir.path,
        backend: backend,
      );
      expect(theme, equals('TestThemeFromINI'));
    });

    test('returns null when no source yields a theme', () async {
      final backend = GSettingsMemoryBackend();
      await backend.set({
        '/org/gnome/desktop/interface/icon-theme': const DBusString(''),
      });
      final theme = await activeIconTheme(
        configHome: tempDir.path,
        backend: backend,
      );
      expect(theme, isNull);
    });
  });

  group('lookupIconInDirs', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync();
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('finds icon in theme data dir', () {
      final iconPath = p.join(
        tempDir.path,
        'icons',
        'TestTheme',
        '48x48',
        'apps',
        'myapp.png',
      );
      File(iconPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync([]);

      final result = lookupIconInDirs(
        'myapp',
        dataDirs: [tempDir.path],
        theme: 'TestTheme',
        pixmapsDir: p.join(tempDir.path, 'pixmaps'),
      );
      expect(result, equals(iconPath));
    });

    test('falls back to pixmaps when icon not in theme', () {
      final pixmapsDir = p.join(tempDir.path, 'pixmaps');
      final pixmapPath = p.join(pixmapsDir, 'myapp.png');
      File(pixmapPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync([]);

      final result = lookupIconInDirs(
        'myapp',
        dataDirs: [tempDir.path],
        theme: 'TestTheme',
        pixmapsDir: pixmapsDir,
      );
      expect(result, equals(pixmapPath));
    });

    test('returns null when icon not found anywhere', () {
      final result = lookupIconInDirs(
        'nonexistent-icon',
        dataDirs: [tempDir.path],
        theme: 'TestTheme',
        pixmapsDir: p.join(tempDir.path, 'pixmaps'),
      );
      expect(result, isNull);
    });
  });
}
