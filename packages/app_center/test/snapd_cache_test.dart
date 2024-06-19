import 'dart:io';

import 'package:app_center/snapd/cache_file.dart';
import 'package:app_center/snapd/snapd_cache.dart';
import 'package:file/memory.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';

import 'snapd_cache_test.mocks.dart';

@GenerateMocks([SnapdClient])
class TestSnapdCache extends MockSnapdClient with SnapdCache {}

void main() {
  test('path', () {
    final cacheHome = Platform.environment['XDG_CACHE_HOME'] ??
        '${Platform.environment['HOME']}/.cache';
    expect(cachePath, startsWith(cacheHome));
    expect(cachePath, endsWith('/snapd'));

    final file = CacheFile.fromFileName('test');
    expect(file.path, startsWith(cachePath));
    expect(file.path, endsWith('/test.smc'));
  });

  test('expiry', () async {
    final fs = MemoryFileSystem();
    final cache = CacheFile(
      'foo.cache',
      expiry: const Duration(seconds: 1),
      fs: fs,
    );

    final file = fs.file('foo.cache');
    expect(file.existsSync(), isFalse);
    expect(cache.existsSync(), isFalse);
    expect(cache.isValidSync(), isFalse);

    await cache.write(123);
    expect(file.existsSync(), isTrue);
    expect(cache.existsSync(), isTrue);
    expect(cache.isValidSync(), isTrue);

    final expired = file.lastModifiedSync().add(const Duration(seconds: 2));
    expect(cache.isValidSync(expired), isFalse);
  });

  test('read-write json', () async {
    final fs = MemoryFileSystem();
    const json = JSONMessageCodec();
    final cache = CacheFile(
      '/foo/${localSnap.name}.json',
      fs: fs,
      codec: json,
    );
    final file = fs.file('foo/${localSnap.name}.json');
    expect(file.existsSync(), isFalse);
    expect(cache.existsSync(), isFalse);
    expect(await cache.readSnap(), isNull);

    await cache.writeSnap(localSnap);
    expect(file.existsSync(), isTrue);
    expect(cache.existsSync(), isTrue);
    expect(await cache.readSnap(), equals(localSnap));
    expect(file.readAsBytesSync(), equals(localSnap.encodeCache(json)));
  });

  test('read-write smc', () async {
    final fs = MemoryFileSystem();
    const smc = StandardMessageCodec();
    final cache = CacheFile(
      '/foo/${localSnap.name}.smc',
      fs: fs,
    );
    final file = fs.file('foo/${localSnap.name}.smc');
    expect(file.existsSync(), isFalse);
    expect(cache.existsSync(), isFalse);
    expect(await cache.readSnap(), isNull);

    await cache.writeSnap(localSnap);
    expect(file.existsSync(), isTrue);
    expect(cache.existsSync(), isTrue);
    expect(await cache.readSnap(), equals(localSnap));
    expect(file.readAsBytesSync(), equals(localSnap.encodeCache(smc)));
  });

  group('category', () {
    test('uncached category', () async {
      final fs = MemoryFileSystem();

      final snapd = TestSnapdCache();
      when(snapd.find(category: 'foo')).thenAnswer((_) async => [storeSnap]);

      await expectLater(
        snapd.getCategory('foo', fileSystem: fs),
        emitsInOrder([
          emits([storeSnap]),
          emitsDone
        ]),
      );
      verify(snapd.find(category: 'foo')).called(1);
    });

    test('cached category', () async {
      final fs = MemoryFileSystem();
      const smc = StandardMessageCodec();

      final file = fs.file('$cachePath/category-foo.smc');
      file.createSync(recursive: true);
      file.writeAsBytesSync([localSnap.toJson()].encodeCache(smc));

      final snapd = TestSnapdCache();
      expect(
        snapd.getCategory('foo', fileSystem: fs),
        emitsInOrder([
          [localSnap],
          emitsDone
        ]),
      );
      verifyNever(snapd.find(category: anyNamed('category')));
    });

    test('expired category', () async {
      final fs = MemoryFileSystem();
      const smc = StandardMessageCodec();

      final file = fs.file('$cachePath/category-foo.smc');
      file.createSync(recursive: true);
      file.writeAsBytesSync([localSnap.toJson()].encodeCache(smc));
      file.setLastModifiedSync(
          DateTime.now().subtract(const Duration(days: 2)));

      final snapd = TestSnapdCache();
      when(snapd.find(category: 'foo')).thenAnswer((_) async => [storeSnap]);

      await expectLater(
        snapd.getCategory('foo', fileSystem: fs),
        emitsInOrder([
          [localSnap],
          [storeSnap],
          emitsDone
        ]),
      );
      verify(snapd.find(category: 'foo')).called(1);
    });
  });

  group('single snap', () {
    test('uncached store snap', () async {
      final fs = MemoryFileSystem();

      final snapd = TestSnapdCache();
      when(snapd.find(name: 'foo')).thenAnswer((_) async => [storeSnap]);

      await expectLater(
        snapd.getStoreSnaps(['foo'], fileSystem: fs),
        emitsInOrder([
          [],
          [storeSnap],
          emitsDone,
        ]),
      );
      verify(snapd.find(name: 'foo')).called(1);
    });

    test('cached store snap', () async {
      final fs = MemoryFileSystem();
      const smc = StandardMessageCodec();

      final file = fs.file('$cachePath/snap-foo.smc');
      file.createSync(recursive: true);
      file.writeAsBytesSync(storeSnap.encodeCache(smc));

      final snapd = TestSnapdCache();
      expect(
        snapd.getStoreSnaps(['foo'], fileSystem: fs),
        emitsInOrder([
          [storeSnap],
          [storeSnap],
          emitsDone,
        ]),
      );
      verifyNever(snapd.find(name: anyNamed('name')));
    });

    test('store snap channels', () async {
      final fs = MemoryFileSystem();
      const smc = StandardMessageCodec();

      final file = fs.file('$cachePath/snap-foo.smc');
      file.createSync(recursive: true);
      file.writeAsBytesSync(localSnap.encodeCache(smc));

      final snapd = TestSnapdCache();
      when(snapd.find(name: 'foo')).thenAnswer((_) async => [storeSnap]);

      await expectLater(
        snapd.getStoreSnaps(['foo'], fileSystem: fs),
        emitsInOrder([
          [localSnap],
          [storeSnap],
          emitsDone,
        ]),
      );
      verify(snapd.find(name: 'foo')).called(1);
    });
  });

  group('multiple snaps', () {
    test('uncached store snaps', () async {
      final fs = MemoryFileSystem();

      final snapd = TestSnapdCache();
      when(snapd.find(name: 'foo')).thenAnswer((_) async => [storeSnap]);
      when(snapd.find(name: 'bar')).thenAnswer((_) async => [storeSnap2]);

      await expectLater(
        snapd.getStoreSnaps(['foo', 'bar'], fileSystem: fs),
        emitsInOrder([
          [],
          [storeSnap, storeSnap2],
          emitsDone
        ]),
      );
      verify(snapd.find(name: 'foo')).called(1);
      verify(snapd.find(name: 'bar')).called(1);
    });

    test('mixed cached and uncached store snaps', () async {
      final fs = MemoryFileSystem();
      const smc = StandardMessageCodec();

      final file = fs.file('$cachePath/snap-foo.smc');
      file.createSync(recursive: true);
      file.writeAsBytesSync(storeSnap.encodeCache(smc));

      final snapd = TestSnapdCache();
      when(snapd.find(name: 'bar')).thenAnswer((_) async => [storeSnap2]);

      await expectLater(
        snapd.getStoreSnaps(['foo', 'bar'], fileSystem: fs),
        emitsInOrder([
          [storeSnap],
          [storeSnap, storeSnap2],
          emitsDone
        ]),
      );
      verifyNever(snapd.find(name: 'foo'));
      verify(snapd.find(name: 'bar')).called(1);
    });

    test('store snap channels', () async {
      final fs = MemoryFileSystem();
      const smc = StandardMessageCodec();

      final file = fs.file('$cachePath/snap-foo.smc');
      file.createSync(recursive: true);
      file.writeAsBytesSync(localSnap.encodeCache(smc));

      final snapd = TestSnapdCache();
      when(snapd.find(name: 'foo')).thenAnswer((_) async => [storeSnap]);
      when(snapd.find(name: 'bar')).thenAnswer((_) async => [storeSnap2]);

      await expectLater(
        snapd.getStoreSnaps(['foo', 'bar'], fileSystem: fs),
        emitsInOrder([
          [localSnap],
          [storeSnap, storeSnap2],
          emitsDone
        ]),
      );
      verify(snapd.find(name: 'foo')).called(1);
      verify(snapd.find(name: 'bar')).called(1);
    });
  });
}

final localSnap = Snap.fromJson(const {
  'id': '3wdHCAVyZEmYsCMFDE9qt92UV8rC8Wdk',
  'title': 'firefox',
  'summary': 'Mozilla Firefox web browser',
  'description':
      'Firefox is a powerful, extensible web browser with support for modern web application technologies.',
  'icon':
      'https://dashboard.snapcraft.io/site_media/appmedia/2021/12/firefox_logo.png',
  'installed-size': 256897024,
  'install-date': '2023-07-11T14:35:58.527931133+02:00',
  'name': 'firefox',
  'publisher': {
    'id': 'OgeoZuqQpVvSr9eGKJzNCrFGSaKXpkey',
    'username': 'mozilla',
    'display-name': 'Mozilla',
    'validation': 'verified'
  },
  'developer': 'mozilla',
  'status': 'active',
  'type': 'app',
  'base': 'core20',
  'version': '115.0.1-1',
  'channel': 'latest/stable',
  'tracking-channel': 'latest/stable',
  'ignore-validation': false,
  'revision': '2880',
  'confinement': 'strict',
  'private': false,
  'devmode': false,
  'jailmode': false,
  'apps': [
    {
      'snap': 'firefox',
      'name': 'firefox',
      'desktop-file':
          '/var/lib/snapd/desktop/applications/firefox_firefox.desktop'
    },
    {'snap': 'firefox', 'name': 'geckodriver'}
  ],
  'mounted-from': '/var/lib/snapd/snaps/firefox_2880.snap',
  'links': {
    'contact': [
      'https://support.mozilla.org/kb/file-bug-report-or-feature-request-mozilla'
    ],
    'website': ['https://www.mozilla.org/firefox/']
  },
  'contact':
      'https://support.mozilla.org/kb/file-bug-report-or-feature-request-mozilla',
  'website': 'https://www.mozilla.org/firefox/',
  'media': [
    {
      'type': 'icon',
      'url':
          'https://dashboard.snapcraft.io/site_media/appmedia/2021/12/firefox_logo.png',
      'width': 196,
      'height': 196
    },
    {
      'type': 'screenshot',
      'url':
          'https://dashboard.snapcraft.io/site_media/appmedia/2021/09/Screenshot_from_2021-09-30_08-01-50.png',
      'width': 1850,
      'height': 1415
    }
  ]
});

final storeSnap = Snap.fromJson(const {
  'id': '3wdHCAVyZEmYsCMFDE9qt92UV8rC8Wdk',
  'title': 'firefox',
  'summary': 'Mozilla Firefox web browser',
  'description':
      'Firefox is a powerful, extensible web browser with support for modern web application technologies.',
  'download-size': 256905216,
  'icon':
      'https://dashboard.snapcraft.io/site_media/appmedia/2021/12/firefox_logo.png',
  'name': 'firefox',
  'publisher': {
    'id': 'OgeoZuqQpVvSr9eGKJzNCrFGSaKXpkey',
    'username': 'mozilla',
    'display-name': 'Mozilla',
    'validation': 'verified'
  },
  'store-url': 'https://snapcraft.io/firefox',
  'developer': 'mozilla',
  'status': 'available',
  'type': 'app',
  'base': 'core20',
  'version': '115.0.2-1',
  'channel': 'stable',
  'ignore-validation': false,
  'revision': '2908',
  'confinement': 'strict',
  'private': false,
  'devmode': false,
  'jailmode': false,
  'license': 'MPL-2.0',
  'links': {
    'contact': [
      'https://support.mozilla.org/kb/file-bug-report-or-feature-request-mozilla'
    ],
    'website': ['https://www.mozilla.org/firefox/']
  },
  'contact':
      'https://support.mozilla.org/kb/file-bug-report-or-feature-request-mozilla',
  'website': 'https://www.mozilla.org/firefox/',
  'media': [
    {
      'type': 'icon',
      'url':
          'https://dashboard.snapcraft.io/site_media/appmedia/2021/12/firefox_logo.png',
      'width': 196,
      'height': 196
    },
    {
      'type': 'screenshot',
      'url':
          'https://dashboard.snapcraft.io/site_media/appmedia/2021/09/Screenshot_from_2021-09-30_08-01-50.png',
      'width': 1850,
      'height': 1415
    }
  ],
  'categories': [
    {'name': 'productivity', 'featured': true}
  ],
  'channels': {
    'esr/candidate': {
      'revision': '2909',
      'confinement': 'strict',
      'version': '115.0.2esr-1',
      'channel': 'esr/candidate',
      'epoch': {
        'read': [0],
        'write': [0]
      },
      'size': 256901120,
      'released-at': '2023-07-11T00:34:34.677868Z'
    },
    'esr/stable': {
      'revision': '2909',
      'confinement': 'strict',
      'version': '115.0.2esr-1',
      'channel': 'esr/stable',
      'epoch': {
        'read': [0],
        'write': [0]
      },
      'size': 256901120,
      'released-at': '2023-07-11T13:44:16.710497Z'
    },
    'latest/beta': {
      'revision': '2922',
      'confinement': 'strict',
      'version': '116.0b4-1',
      'channel': 'latest/beta',
      'epoch': {
        'read': [0],
        'write': [0]
      },
      'size': 249405440,
      'released-at': '2023-07-12T01:37:32.508198Z'
    },
    'latest/candidate': {
      'revision': '2908',
      'confinement': 'strict',
      'version': '115.0.2-1',
      'channel': 'latest/candidate',
      'epoch': {
        'read': [0],
        'write': [0]
      },
      'size': 256905216,
      'released-at': '2023-07-10T23:39:43.485418Z'
    },
    'latest/edge': {
      'revision': '2924',
      'confinement': 'strict',
      'version': '117.0a1',
      'channel': 'latest/edge',
      'epoch': {
        'read': [0],
        'write': [0]
      },
      'size': 258400256,
      'released-at': '2023-07-12T04:02:41.300927Z'
    },
    'latest/stable': {
      'revision': '2908',
      'confinement': 'strict',
      'version': '115.0.2-1',
      'channel': 'latest/stable',
      'epoch': {
        'read': [0],
        'write': [0]
      },
      'size': 256905216,
      'released-at': '2023-07-11T13:43:59.436506Z'
    }
  },
  'tracks': ['latest', 'esr']
});

final localSnap2 = Snap.fromJson(const {
  'id': 'mVyGrEwiqSi5PugCwyH7WgpoQLemtTd6',
  'title': 'hello',
  'summary': 'GNU Hello, the \'hello world\' snap',
  'description':
      'GNU hello prints a friendly greeting. This is part of the snapcraft tour at https://snapcraft.io/',
  'installed-size': 131072,
  'install-date': '2023-08-16T10:48:45.920574061+02:00',
  'name': 'hello',
  'publisher': {
    'id': 'canonical',
    'username': 'canonical',
    'display-name': 'Canonical',
    'validation': 'verified'
  },
  'developer': 'canonical',
  'status': 'active',
  'type': 'app',
  'base': 'core20',
  'version': '2.12',
  'channel': 'latest/edge',
  'tracking-channel': 'latest/edge',
  'ignore-validation': false,
  'revision': '52',
  'confinement': 'strict',
  'private': false,
  'devmode': false,
  'jailmode': false,
  'apps': [
    {'snap': 'hello', 'name': 'hello'},
    {'snap': 'hello', 'name': 'universe'}
  ],
  'mounted-from': '/var/lib/snapd/snaps/hello_52.snap',
  'links': {
    'contact': ['mailto:snaps@canonical.com']
  },
  'contact': 'mailto:snaps@canonical.com'
});

final storeSnap2 = Snap.fromJson(const {
  'id': 'mVyGrEwiqSi5PugCwyH7WgpoQLemtTd6',
  'title': 'hello',
  'summary': 'GNU Hello, the \'hello world\' snap',
  'description':
      'GNU hello prints a friendly greeting. This is part of the snapcraft tour at https://snapcraft.io/',
  'download-size': 106496,
  'name': 'hello',
  'publisher': {
    'id': 'canonical',
    'username': 'canonical',
    'display-name': 'Canonical',
    'validation': 'verified'
  },
  'store-url': 'https://snapcraft.io/hello',
  'developer': 'canonical',
  'status': 'available',
  'type': 'app',
  'base': 'core20',
  'version': '2.10',
  'channel': 'stable',
  'ignore-validation': false,
  'revision': '42',
  'confinement': 'strict',
  'private': false,
  'devmode': false,
  'jailmode': false,
  'license': 'GPL-3.0',
  'links': {
    'contact': ['mailto:snaps@canonical.com']
  },
  'contact': 'mailto:snaps@canonical.com',
  'channels': {
    'latest/beta': {
      'revision': '29',
      'confinement': 'strict',
      'version': '2.10.1',
      'channel': 'latest/beta',
      'epoch': {
        'read': [0],
        'write': [0]
      },
      'size': 65536,
      'released-at': '2017-05-17T21:17:00.205019Z'
    },
    'latest/candidate': {
      'revision': '42',
      'confinement': 'strict',
      'version': '2.10',
      'channel': 'latest/candidate',
      'epoch': {
        'read': [0],
        'write': [0]
      },
      'size': 106496,
      'released-at': '2022-01-14T01:57:40.028647Z'
    },
    'latest/edge': {
      'revision': '52',
      'confinement': 'strict',
      'version': '2.12',
      'channel': 'latest/edge',
      'epoch': {
        'read': [0],
        'write': [0]
      },
      'size': 131072,
      'released-at': '2022-03-15T17:16:17.517293Z'
    },
    'latest/stable': {
      'revision': '42',
      'confinement': 'strict',
      'version': '2.10',
      'channel': 'latest/stable',
      'epoch': {
        'read': [0],
        'write': [0]
      },
      'size': 106496,
      'released-at': '2022-01-14T02:01:54.911048Z'
    }
  },
  'tracks': ['latest']
});
