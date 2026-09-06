import 'package:app_center/snapd/snapd.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';
import 'test_utils.mocks.dart';

void main() {
  test('cleaned query', () {
    const searchParameters = SnapSearchParameters(
      query: 'a+b=c&d|e>f<g!h(i)j{k}l[m]n^o"p~q*r?s:t\\u/v',
    );
    expect(
      searchParameters.cleanedQuery,
      equals('a b c d e f g h i j k l m n o p q r s t u v'),
    );
  });

  group('snapSearchProvider case-insensitivity', () {
    late MockSnapdService snapd;

    setUp(() {
      snapd = MockSnapdService();
      registerMockService<SnapdService>(snapd);
    });

    tearDown(resetAllServices);

    test('case-insensitive search in ubuntuDesktop featured snaps', () async {
      when(snapd.getStoreSnaps(any)).thenAnswer(
        (invocation) {
          final names = invocation.positionalArguments.first as List<String>;
          return Stream.value(
            names.map((name) => createSnap(name: name)).toList(),
          );
        },
      );

      final container = createContainer();

      // Lowercase query matching mixed case / standard name
      const searchParamsLower = SnapSearchParameters(
        query: 'office',
        category: SnapCategoryEnum.ubuntuDesktop,
      );
      final resultLower = await container.read(
        snapSearchProvider(searchParamsLower).future,
      );
      verify(
        snapd.getStoreSnaps(
          argThat(
            predicate<List<String>>(
              (names) => names.every((n) => n.toLowerCase().contains('office')),
            ),
          ),
        ),
      ).called(1);
      expect(resultLower, isNotEmpty);

      // Uppercase query matching the same featured snaps
      const searchParamsUpper = SnapSearchParameters(
        query: 'OFFICE',
        category: SnapCategoryEnum.ubuntuDesktop,
      );
      final resultUpper = await container.read(
        snapSearchProvider(searchParamsUpper).future,
      );
      verify(
        snapd.getStoreSnaps(
          argThat(
            predicate<List<String>>(
              (names) => names.every((n) => n.toLowerCase().contains('office')),
            ),
          ),
        ),
      ).called(1);
      expect(resultUpper.length, equals(resultLower.length));
    });

    test('case-insensitive search in gameDev category', () async {
      when(snapd.getStoreSnaps(any)).thenAnswer(
        (invocation) {
          final names = invocation.positionalArguments.first as List<String>;
          return Stream.value(
            names.map((name) => createSnap(name: name)).toList(),
          );
        },
      );

      final container = createContainer();

      const searchParams = SnapSearchParameters(
        query: 'GODOT',
        category: SnapCategoryEnum.gameDev,
      );
      final result = await container.read(
        snapSearchProvider(searchParams).future,
      );
      verify(
        snapd.getStoreSnaps(
          argThat(
            predicate<List<String>>(
              (names) => names.every((n) => n.toLowerCase().contains('godot')),
            ),
          ),
        ),
      ).called(1);
      expect(result, isNotEmpty);
    });
  });
}
