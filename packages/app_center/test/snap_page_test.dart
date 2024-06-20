import 'package:app_center/l10n.dart';
import 'package:app_center/ratings/ratings.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:app_center_ratings_client/app_center_ratings_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:ubuntu_test/ubuntu_test.dart';
import 'package:yaru/yaru.dart';

import 'test_utils.dart';
import 'test_utils.mocks.dart';

const snapId = 'r4LxMVp7zWramXsJQAKdamxy6TAWlaDD';
const snapRating = Rating(
  snapId: snapId,
  totalVotes: 123,
  ratingsBand: RatingsBand.good,
);

final localSnap = Snap(
  name: 'testsnap',
  title: 'Testsnap',
  publisher: const SnapPublisher(displayName: 'testPublisher'),
  version: '2.0.0',
  revision: '42',
  website: 'https://example.com',
  confinement: SnapConfinement.classic,
  license: 'MIT',
  description: 'this is the **description**',
  trackingChannel: 'latest/edge',
  channel: 'latest/edge',
  installDate: DateTime(1970),
  id: 'r4LxMVp7zWramXsJQAKdamxy6TAWlaDD',
);

final storeSnap = Snap(
  name: 'testsnap',
  title: 'Testsnap',
  publisher: const SnapPublisher(displayName: 'testPublisher'),
  version: '1.0.0',
  revision: '42',
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
  media: const [
    SnapMedia(type: 'screenshot', url: 'http://example.com/example.jpg'),
  ],
);

void expectSnapInfos(
  WidgetTester tester,
  Snap snap, [
  String? channel = 'latest/stable',
]) {
  expect(find.text(snap.title!), findsOneWidget);
  expect(find.text(snap.publisher!.displayName), findsOneWidget);
  expect(find.markdownBody(snap.description), findsOneWidget);
  expect(find.text(snap.license!), findsOneWidget);

  expect(find.text(tester.l10n.snapPageConfinementLabel), findsOneWidget);
  expect(find.text(tester.l10n.snapPageDescriptionLabel), findsOneWidget);
  expect(find.text(tester.l10n.snapPageLicenseLabel), findsOneWidget);
  expect(find.text(tester.l10n.snapPageVersionLabel), findsOneWidget);
  expect(find.text(tester.l10n.snapPagePublishedLabel), findsOneWidget);

  final snapChannel = snap.channels[channel];
  if (snapChannel != null) {
    expect(
      find.text(snapChannel.confinement.localize(tester.l10n)),
      findsOneWidget,
    );
    expect(find.text(tester.l10n.snapPageDownloadSizeLabel), findsOneWidget);
    expect(
      find.text(tester.context.formatByteSize(snapChannel.size)),
      findsOneWidget,
    );
    expect(
      find.text(DateFormat.yMMMd().format(snapChannel.releasedAt)),
      findsOneWidget,
    );
  }
}

// TODO agree with design team on what snap metadata should be shown depending on:
// - whether a snap is installed locally
// - whether a snap is available in the store
// - which channel is currently selected
// - any combination of the above
void main() {
  setUp(() => registerMockRatingsService(rating: snapRating));
  tearDown(resetAllServices);

  testWidgets('local + store', (tester) async {
    final service = registerMockSnapdService(
      localSnap: localSnap,
      storeSnap: storeSnap,
    );
    final ratingsService = getService<RatingsService>() as MockRatingsService;

    final snapLauncher = createMockSnapLauncher(isLaunchable: true);
    final updatesModel = createMockUpdatesModel();

    final container = createContainer(
      overrides: [
        launchProvider.overrideWith((ref, arg) => snapLauncher),
        updatesModelProvider.overrideWith((ref) => updatesModel),
      ],
    );
    await tester.pumpApp(
      (_) => UncontrolledProviderScope(
        container: container,
        child: const SnapPage(snapName: 'testsnap'),
      ),
    );
    await container.read(snapModelProvider('testsnap').future);
    await container.read(ratingsModelProvider('testsnap').future);
    await tester.pumpAndSettle();
    expectSnapInfos(tester, storeSnap, 'latest/edge');
    expect(find.byType(ScreenshotGallery), findsOneWidget);
    expect(find.text(tester.l10n.snapActionInstallLabel), findsNothing);

    await tester.tap(find.text(tester.l10n.snapActionOpenLabel));
    verify(snapLauncher.open()).called(1);

    await tester.tap(find.byIcon(Icons.thumb_up_outlined));
    verify(
      ratingsService.vote(
        argThat(
          isA<Vote>().having((v) => v.voteUp, 'voteUp', true),
        ),
      ),
    ).called(1);

    await tester.tap(find.byIcon(Icons.thumb_down_outlined));
    verify(
      ratingsService.vote(
        argThat(
          isA<Vote>().having((v) => v.voteUp, 'voteUp', false),
        ),
      ),
    ).called(1);

    final viewMoreButton = find.byIcon(YaruIcons.view_more_horizontal);
    expect(viewMoreButton, findsOneWidget);
    await tester.tap(viewMoreButton);
    await tester.pump();

    final removeButton = find.text(tester.l10n.snapActionRemoveLabel);
    expect(removeButton, findsOneWidget);
    await tester.tap(removeButton);
    await tester.pumpAndSettle();
    verify(service.remove(any)).called(1);

    expect(find.text(tester.l10n.snapActionUpdateLabel), findsNothing);
    final l10n = tester.l10n;
    expect(
      find.text(tester.l10n.snapRatingsVotes(snapRating.totalVotes)),
      findsOneWidget,
    );
    expect(find.text(snapRating.ratingsBand.localize(l10n)), findsOneWidget);
  });

  testWidgets('local + store with update', (tester) async {
    final service = registerMockSnapdService(
      localSnap: localSnap,
      storeSnap: storeSnap,
    );
    final ratingsService = getService<RatingsService>() as MockRatingsService;
    final snapLauncher = createMockSnapLauncher(isLaunchable: true);
    final updatesModel =
        createMockUpdatesModel(refreshableSnapNames: [localSnap.name]);

    final container = createContainer(
      overrides: [
        launchProvider.overrideWith((ref, arg) => snapLauncher),
        updatesModelProvider.overrideWith((ref) => updatesModel),
      ],
    );

    await tester.pumpApp(
      (_) => UncontrolledProviderScope(
        container: container,
        child: SnapPage(snapName: storeSnap.name),
      ),
    );
    await container.read(snapModelProvider(storeSnap.name).future);
    await container.read(ratingsModelProvider(storeSnap.name).future);
    await tester.pumpAndSettle();
    expectSnapInfos(tester, storeSnap, 'latest/edge');
    expect(find.byType(ScreenshotGallery), findsOneWidget);
    expect(find.text(tester.l10n.snapActionInstallLabel), findsNothing);

    await tester.tap(find.text(tester.l10n.snapActionOpenLabel));
    verify(snapLauncher.open()).called(1);

    await tester.tap(find.byIcon(Icons.thumb_up_outlined));
    verify(
      ratingsService.vote(
        argThat(
          isA<Vote>().having((v) => v.voteUp, 'voteUp', true),
        ),
      ),
    ).called(1);

    await tester.tap(find.byIcon(Icons.thumb_down_outlined));
    verify(
      ratingsService.vote(
        argThat(
          isA<Vote>().having((v) => v.voteUp, 'voteUp', false),
        ),
      ),
    ).called(1);

    final viewMoreButton = find.byIcon(YaruIcons.view_more_horizontal);
    expect(viewMoreButton, findsOneWidget);
    await tester.tap(viewMoreButton);
    await tester.pump();

    final updateButton = find.text(tester.l10n.snapActionUpdateLabel);
    expect(updateButton, findsOneWidget);

    await tester.tap(find.text(tester.l10n.snapActionRemoveLabel));
    await tester.pump();
    verify(service.remove(any)).called(1);

    final l10n = tester.l10n;
    expect(
      find.text(tester.l10n.snapRatingsVotes(snapRating.totalVotes)),
      findsOneWidget,
    );
    expect(find.text(snapRating.ratingsBand.localize(l10n)), findsOneWidget);
  });

  testWidgets('store-only', (tester) async {
    final service = registerMockSnapdService(
      storeSnap: storeSnap,
    );
    final updatesModel = createMockUpdatesModel();
    final container = createContainer(
      overrides: [
        updatesModelProvider.overrideWith((ref) => updatesModel),
        launchProvider.overrideWith((ref, arg) => createMockSnapLauncher()),
      ],
    );

    await tester.pumpApp(
      (_) => UncontrolledProviderScope(
        container: container,
        child: SnapPage(snapName: storeSnap.name),
      ),
    );
    await container.read(snapModelProvider(storeSnap.name).future);
    await tester.pump();
    expectSnapInfos(tester, storeSnap);
    expect(find.byType(ScreenshotGallery), findsOneWidget);
    expect(find.text(tester.l10n.snapActionRemoveLabel), findsNothing);
    expect(find.text(tester.l10n.snapActionOpenLabel), findsNothing);
    expect(find.text(tester.l10n.snapActionUpdateLabel), findsNothing);
    expect(find.byIcon(Icons.thumb_up_outlined), findsNothing);
    expect(find.byIcon(Icons.thumb_down_outlined), findsNothing);

    await tester.tap(find.text(tester.l10n.snapActionInstallLabel));
    final l10n = tester.l10n;
    await tester.pumpAndSettle();
    expect(
      find.text(tester.l10n.snapRatingsVotes(snapRating.totalVotes)),
      findsOneWidget,
    );
    expect(find.text(snapRating.ratingsBand.localize(l10n)), findsOneWidget);
    verify(service.install(any, channel: anyNamed('channel'))).called(1);
  });

  testWidgets('local-only', (tester) async {
    final service = registerMockSnapdService(localSnap: localSnap);
    final ratingsService = getService<RatingsService>() as MockRatingsService;
    final snapLauncher = createMockSnapLauncher(isLaunchable: true);
    final updatesModel = createMockUpdatesModel();

    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          launchProvider.overrideWith((ref, arg) => snapLauncher),
          updatesModelProvider.overrideWith((ref) => updatesModel),
        ],
        child: SnapPage(snapName: localSnap.name),
      ),
    );
    await tester.pumpAndSettle();
    expectSnapInfos(tester, localSnap);
    expect(find.byType(ScreenshotGallery), findsNothing);
    expect(find.text(tester.l10n.snapActionInstallLabel), findsNothing);

    await tester.tap(find.byIcon(Icons.thumb_up_outlined));
    verify(
      ratingsService.vote(
        argThat(
          isA<Vote>().having((v) => v.voteUp, 'voteUp', true),
        ),
      ),
    ).called(1);

    await tester.tap(find.byIcon(Icons.thumb_down_outlined));
    verify(
      ratingsService.vote(
        argThat(
          isA<Vote>().having((v) => v.voteUp, 'voteUp', false),
        ),
      ),
    ).called(1);

    await tester.tap(find.text(tester.l10n.snapActionOpenLabel));
    verify(snapLauncher.open()).called(1);
    await tester.pump();

    final findMoreButton = find.byIcon(YaruIcons.view_more_horizontal);
    expect(findMoreButton, findsOneWidget);
    await tester.tap(findMoreButton);
    await tester.pump();

    final removeButton = find.text(tester.l10n.snapActionRemoveLabel);
    expect(removeButton, findsOneWidget);
    await tester.tap(removeButton);
    await tester.pump();
    verify(service.remove(any)).called(1);

    expect(find.text(tester.l10n.snapActionUpdateLabel), findsNothing);
    final l10n = tester.l10n;
    expect(
      find.text(tester.l10n.snapRatingsVotes(snapRating.totalVotes)),
      findsOneWidget,
    );
    expect(find.text(snapRating.ratingsBand.localize(l10n)), findsOneWidget);
  });

  testWidgets('loading', (tester) async {
    registerMockSnapdService(localSnap: localSnap, storeSnap: storeSnap);
    final snapLauncher = createMockSnapLauncher(isLaunchable: true);
    final updatesModel = createMockUpdatesModel();

    final container = createContainer(
      overrides: [
        launchProvider.overrideWith((ref, arg) => snapLauncher),
        updatesModelProvider.overrideWith((ref) => updatesModel),
      ],
    );

    await tester.pumpApp(
      (_) => UncontrolledProviderScope(
        container: container,
        child: SnapPage(snapName: storeSnap.name),
      ),
    );
    await tester.pump();
    container.read(snapModelProvider(storeSnap.name).notifier).state =
        const AsyncLoading();
    await tester.pump();
    expect(find.text(tester.l10n.snapActionRemoveLabel), findsNothing);
    expect(find.text(tester.l10n.snapActionInstallLabel), findsNothing);
    expect(find.byIcon(Icons.thumb_up_outlined), findsNothing);
    expect(find.byIcon(Icons.thumb_down_outlined), findsNothing);
    expect(find.byType(YaruCircularProgressIndicator), findsOneWidget);
    final l10n = tester.l10n;
    expect(
      find.text(tester.l10n.snapRatingsVotes(snapRating.totalVotes)),
      findsNothing,
    );
    expect(find.text(snapRating.ratingsBand.localize(l10n)), findsNothing);
  });

  // TODO: test loading states with snap change in progress
}
