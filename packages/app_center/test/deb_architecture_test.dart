import 'package:app_center/deb/deb_architecture.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isDebArchitectureCompatible', () {
    test('native architecture is compatible', () {
      expect(
        isDebArchitectureCompatible(packageArch: 'amd64', systemArch: 'amd64'),
        isTrue,
      );
    });

    test('32-bit companion is compatible', () {
      expect(
        isDebArchitectureCompatible(packageArch: 'i386', systemArch: 'amd64'),
        isTrue,
      );
      expect(
        isDebArchitectureCompatible(packageArch: 'armhf', systemArch: 'arm64'),
        isTrue,
      );
    });

    test('foreign CPU architecture is incompatible', () {
      expect(
        isDebArchitectureCompatible(packageArch: 'amd64', systemArch: 'arm64'),
        isFalse,
      );
      expect(
        isDebArchitectureCompatible(packageArch: 'arm64', systemArch: 'amd64'),
        isFalse,
      );
    });

    test('architecture-independent \'all\' is always compatible', () {
      expect(
        isDebArchitectureCompatible(packageArch: 'all', systemArch: 'arm64'),
        isTrue,
      );
    });

    test('empty package architecture falls open', () {
      expect(
        isDebArchitectureCompatible(packageArch: '', systemArch: 'amd64'),
        isTrue,
      );
    });

    test('unrecognized system architecture falls open', () {
      expect(
        isDebArchitectureCompatible(
          packageArch: 'amd64',
          systemArch: 'sparc64',
        ),
        isTrue,
      );
    });
  });
}
