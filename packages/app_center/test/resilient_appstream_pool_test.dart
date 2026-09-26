import 'dart:io';

import 'package:app_center/appstream/appstream.dart';
import 'package:flutter_test/flutter_test.dart';

const _goodYaml = '''
File: DEP-11
Version: '0.10'
Origin: test
---
ID: com.example.Good
Type: desktop-application
Package: good-pkg
Name:
  C: Good App
Summary:
  C: A good app
''';

// Contains a release with `type: snapshot`, which the `appstream` package
// doesn't recognize and throws a `FormatException` for (see #2142).
const _badYaml = '''
File: DEP-11
Version: '0.10'
Origin: test
---
ID: com.example.Bad
Type: desktop-application
Package: bad-pkg
Name:
  C: Bad App
Summary:
  C: A bad app
Releases:
  - version: '1.0'
    type: snapshot
''';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('resilient_appstream_pool');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('skips malformed catalog files instead of hanging', () async {
    final yamlDir = Directory('${tempDir.path}/swcatalog/yaml');
    await yamlDir.create(recursive: true);
    await File('${yamlDir.path}/good.yml').writeAsString(_goodYaml);
    await File('${yamlDir.path}/bad.yml').writeAsString(_badYaml);

    final pool = ResilientAppstreamPool(catalogDirPrefixes: [tempDir.path]);

    // Regression test for #2142: previously, a single malformed catalog file
    // would make `load()` hang forever.
    await pool.load().timeout(const Duration(seconds: 10));

    expect(pool.components, hasLength(1));
    expect(pool.components.single.id, 'com.example.Good');
  });

  test('loads all valid catalog files when none are malformed', () async {
    final yamlDir = Directory('${tempDir.path}/swcatalog/yaml');
    await yamlDir.create(recursive: true);
    await File('${yamlDir.path}/good.yml').writeAsString(_goodYaml);

    final pool = ResilientAppstreamPool(catalogDirPrefixes: [tempDir.path]);
    await pool.load().timeout(const Duration(seconds: 10));

    expect(pool.components, hasLength(1));
  });

  test('returns no components when the catalog directory is absent', () async {
    final pool = ResilientAppstreamPool(
      catalogDirPrefixes: ['${tempDir.path}/does-not-exist'],
    );

    await pool.load().timeout(const Duration(seconds: 10));

    expect(pool.components, isEmpty);
  });
}
