import 'package:app_center/snapd.dart';
import 'package:app_center/src/snapd/multisnap_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';

import 'test_utils.dart';

final storeSnap = Snap(
  name: 'testsnap',
  title: 'Testsnap',
  publisher: const SnapPublisher(displayName: 'testPublisher'),
  version: '1.0.0',
  website: 'https://example.com',
  confinement: SnapConfinement.strict,
  license: 'MIT',
  description: 'this is the **description**',
  downloadSize: 1337,
  channels: {
    'latest/stable': SnapChannel(
      confinement: SnapConfinement.strict,
      size: 1337,
      releasedAt: DateTime(1970),
      version: '1.0.0',
    ),
    'latest/edge': SnapChannel(
      confinement: SnapConfinement.classic,
      size: 31337,
      releasedAt: DateTime(1970, 1, 2),
      version: '2.0.0',
    ),
  },
);

void main() {
  test('install-many', () async {
    final service = createMockSnapdService(
      storeSnap: storeSnap,
    );
    final model =
        MultiSnapModel(snapd: service, category: SnapCategoryEnum.gameDev);
    await model.init();

    await model.installAll();

    verify(service.installMany(List<String>.from(List<String>.generate(
        SnapCategoryEnum.gameDev.featuredSnapNames!.length,
        (index) => 'testsnap')))).called(1);
  });
}
