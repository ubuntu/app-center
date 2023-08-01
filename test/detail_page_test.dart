import 'package:app_store/l10n.dart';
import 'package:app_store/search.dart';
import 'package:app_store/snapd.dart';
import 'package:app_store/src/detail/detail_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_test/ubuntu_test.dart';
import 'package:yaru_widgets/widgets.dart';

import 'test_utils.dart';

final localSnap = Snap(
  name: 'testsnap',
  title: 'Testsnap',
  publisher: const SnapPublisher(displayName: 'testPublisher'),
  version: '2.0.0',
  website: 'https://example.com',
  confinement: SnapConfinement.classic,
  license: 'MIT',
  description: 'this is the **description**',
  trackingChannel: 'latest/edge',
  channel: 'latest/edge',
  installDate: DateTime(1970),
);

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

void expectSnapInfos(
  WidgetTester tester,
  Snap snap, [
  String? channel = 'latest/stable',
]) {
  expect(find.text(snap.title!), findsOneWidget);
  expect(find.text(snap.publisher!.displayName), findsOneWidget);
  expect(find.markdownBody(snap.description), findsOneWidget);
  expect(find.text(snap.license!), findsOneWidget);

  expect(find.text(tester.l10n.detailPageConfinementLabel), findsOneWidget);
  expect(find.text(tester.l10n.detailPageDescriptionLabel), findsOneWidget);
  expect(find.text(tester.l10n.detailPageLicenseLabel), findsOneWidget);

  final snapChannel = snap.channels[channel];
  if (snapChannel != null) {
    expect(find.text(snapChannel.confinement.name), findsOneWidget);
    expect(find.text(tester.l10n.detailPageDownloadSizeLabel), findsOneWidget);
    expect(find.text(tester.context.formatByteSize(snapChannel.size)),
        findsOneWidget);
  }
}

// TODO agree with design team on what snap metadata should be shown depending on:
// - whether a snap is installed locally
// - whether a snap is available in the store
// - which channel is currently selected
// - any combination of the above
void main() {
  testWidgets('local + store', (tester) async {
    final snapModel =
        createMockSnapModel(localSnap: localSnap, storeSnap: storeSnap);
    final snapLauncher = createMockSnapLauncher(isLaunchable: true);

    await tester.pumpApp((_) => ProviderScope(
          overrides: [
            snapModelProvider.overrideWith((ref, arg) => snapModel),
            launchProvider.overrideWith((ref, arg) => snapLauncher),
            refreshProvider.overrideWith((ref) => []),
          ],
          child: const DetailPage(snapName: 'testsnap'),
        ));
    await tester.pump();
    expectSnapInfos(tester, storeSnap, 'latest/edge');
    expect(find.text(tester.l10n.snapActionInstallLabel), findsNothing);
    expect(find.text(tester.l10n.snapActionUpdateLabel), findsNothing);

    await tester.tap(find.text(tester.l10n.snapActionRemoveLabel));
    verify(snapModel.remove()).called(1);

    await tester.tap(find.text(tester.l10n.snapActionOpenLabel));
    verify(snapLauncher.open()).called(1);
  });

  testWidgets('local + store with update', (tester) async {
    final snapModel = createMockSnapModel(
      localSnap: localSnap,
      storeSnap: storeSnap,
    );
    final snapLauncher = createMockSnapLauncher(isLaunchable: true);

    await tester.pumpApp((_) => ProviderScope(
          overrides: [
            snapModelProvider.overrideWith((ref, arg) => snapModel),
            launchProvider.overrideWith((ref, arg) => snapLauncher),
            refreshProvider.overrideWith((ref) => [storeSnap]),
          ],
          child: DetailPage(snapName: storeSnap.name),
        ));
    await tester.pump();
    expectSnapInfos(tester, storeSnap, 'latest/edge');
    expect(find.text(tester.l10n.snapActionInstallLabel), findsNothing);
    expect(find.text(tester.l10n.snapActionUpdateLabel), findsOneWidget);

    await tester.tap(find.text(tester.l10n.snapActionRemoveLabel));
    verify(snapModel.remove()).called(1);

    await tester.tap(find.text(tester.l10n.snapActionUpdateLabel));
    verify(snapModel.refresh()).called(1);

    await tester.tap(find.text(tester.l10n.snapActionOpenLabel));
    verify(snapLauncher.open()).called(1);
  });

  testWidgets('store-only', (tester) async {
    final snapModel = createMockSnapModel(storeSnap: storeSnap);
    await tester.pumpApp((_) => ProviderScope(
          overrides: [
            snapModelProvider.overrideWith((ref, arg) => snapModel),
            refreshProvider
                .overrideWith((ref) => [const Snap(name: 'othersnap')]),
          ],
          child: DetailPage(snapName: storeSnap.name),
        ));
    await tester.pump();
    expectSnapInfos(tester, storeSnap);
    expect(find.text(tester.l10n.snapActionRemoveLabel), findsNothing);
    expect(find.text(tester.l10n.snapActionOpenLabel), findsNothing);
    expect(find.text(tester.l10n.snapActionUpdateLabel), findsNothing);

    await tester.tap(find.text(tester.l10n.snapActionInstallLabel));
    verify(snapModel.install()).called(1);
  });

  testWidgets('local-only', (tester) async {
    final snapModel = createMockSnapModel(localSnap: localSnap);
    final snapLauncher = createMockSnapLauncher(isLaunchable: true);

    await tester.pumpApp((_) => ProviderScope(
          overrides: [
            snapModelProvider.overrideWith((ref, arg) => snapModel),
            launchProvider.overrideWith((ref, arg) => snapLauncher),
            refreshProvider.overrideWith((ref) => []),
          ],
          child: DetailPage(snapName: localSnap.name),
        ));
    await tester.pump();
    expectSnapInfos(tester, localSnap);
    expect(find.text(tester.l10n.snapActionInstallLabel), findsNothing);

    await tester.tap(find.text(tester.l10n.snapActionRemoveLabel));
    verify(snapModel.remove()).called(1);

    await tester.tap(find.text(tester.l10n.snapActionOpenLabel));
    verify(snapLauncher.open()).called(1);
  });

  testWidgets('loading', (tester) async {
    final snapModel = createMockSnapModel(
      state: const AsyncValue.loading(),
      storeSnap: storeSnap,
    );
    final snapLauncher = createMockSnapLauncher(isLaunchable: true);

    await tester.pumpApp((_) => ProviderScope(
          overrides: [
            snapModelProvider.overrideWith((ref, arg) => snapModel),
            launchProvider.overrideWith((ref, arg) => snapLauncher),
            refreshProvider.overrideWith((ref) => []),
          ],
          child: DetailPage(snapName: storeSnap.name),
        ));
    await tester.pump();
    expect(find.text(tester.l10n.snapActionRemoveLabel), findsNothing);
    expect(find.text(tester.l10n.snapActionInstallLabel), findsNothing);
    expect(find.byType(YaruCircularProgressIndicator), findsOneWidget);
  });
}
