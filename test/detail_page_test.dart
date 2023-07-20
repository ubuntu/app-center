import 'package:app_store/l10n.dart';
import 'package:app_store/search.dart';
import 'package:app_store/snapd.dart';
import 'package:app_store/src/detail/detail_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_test/ubuntu_test.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'test_utils.dart';

const localSnap = Snap(
  name: 'testsnap',
  title: 'Testsnap',
  publisher: SnapPublisher(displayName: 'testPublisher'),
  version: '1.0.0',
  website: 'https://example.com',
  confinement: SnapConfinement.strict,
  license: 'MIT',
  description: 'this is the **description**',
  trackingChannel: 'latest/stable',
  channel: 'latest/stable',
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

void expectSnapInfos(WidgetTester tester, Snap snap, [String? channel]) {
  expect(find.text(snap.title!), findsOneWidget);
  expect(find.text(snap.publisher!.displayName), findsOneWidget);
  expect(find.markdownBody(snap.description), findsOneWidget);
  expect(find.text(snap.license!), findsOneWidget);

  expect(find.text(tester.l10n.detailPageConfinementLabel), findsOneWidget);
  expect(find.text(tester.l10n.detailPageDescriptionLabel), findsOneWidget);
  expect(find.text(tester.l10n.detailPageLicenseLabel), findsOneWidget);
  expect(find.text(tester.l10n.detailPageVersionLabel), findsOneWidget);

  if (channel != null) {
    final snapChannel = snap.channels[channel]!;
    expect(find.text(snapChannel.version), findsOneWidget);
    expect(find.text(snapChannel.confinement.name), findsOneWidget);
    expect(find.text(tester.l10n.detailPageDownloadSizeLabel), findsOneWidget);
    expect(find.text(tester.context.formatByteSize(snapChannel.size)),
        findsOneWidget);
  } else {
    expect(find.text(snap.version), findsOneWidget);
    expect(find.text(snap.confinement.name), findsOneWidget);
    if (snap.downloadSize != null) {
      expect(
          find.text(tester.l10n.detailPageDownloadSizeLabel), findsOneWidget);
      expect(find.text(tester.context.formatByteSize(snap.downloadSize!)),
          findsOneWidget);
    }
  }
}

void main() {
  testWidgets('locally installed snap', (tester) async {
    final localSnapNotifier =
        createMockLocalSnapNotifier(const LocalSnap.data(localSnap));
    final snapLauncher = createMockSnapLauncher(isLaunchable: true);

    await tester.pumpApp((_) => ProviderScope(
          overrides: [
            storeSnapProvider
                .overrideWith((ref, arg) => Stream.value(storeSnap)),
            localSnapProvider.overrideWith((ref, arg) => localSnapNotifier),
            launchProvider.overrideWith((ref, arg) => snapLauncher),
            refreshProvider.overrideWith((ref) => []),
          ],
          child: DetailPage(snapName: storeSnap.name),
        ));
    await tester.pump();
    expectSnapInfos(tester, storeSnap);
    expect(find.text(tester.l10n.detailPageInstallLabel), findsNothing);
    expect(find.text(tester.l10n.detailPageUpdateLabel), findsNothing);

    await tester.tap(find.text(tester.l10n.detailPageRemoveLabel));
    verify(localSnapNotifier.remove()).called(1);

    await tester.tap(find.text(tester.l10n.managePageOpenLabel));
    verify(snapLauncher.open()).called(1);
  });

  testWidgets('locally installed snap - switch channel', (tester) async {
    final localSnapNotifier =
        createMockLocalSnapNotifier(const LocalSnap.data(localSnap));
    final snapLauncher = createMockSnapLauncher(isLaunchable: true);

    await tester.pumpApp((_) => ProviderScope(
          overrides: [
            storeSnapProvider
                .overrideWith((ref, arg) => Stream.value(storeSnap)),
            localSnapProvider.overrideWith((ref, arg) => localSnapNotifier),
            launchProvider.overrideWith((ref, arg) => snapLauncher),
            refreshProvider.overrideWith((ref) => []),
          ],
          child: DetailPage(snapName: storeSnap.name),
        ));
    await tester.pump();
    expectSnapInfos(tester, storeSnap);
    expect(find.text(tester.l10n.detailPageInstallLabel), findsNothing);
    expect(find.text(tester.l10n.detailPageUpdateLabel), findsNothing);

    await tester.tap(find.text('latest/stable'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('latest/edge'));
    await tester.pumpAndSettle();

    expectSnapInfos(tester, storeSnap, 'latest/edge');
    expect(find.text(tester.l10n.detailPageInstallLabel), findsNothing);
    expect(find.text(tester.l10n.detailPageUpdateLabel), findsOneWidget);

    await tester.tap(find.text(tester.l10n.detailPageUpdateLabel));
    verify(localSnapNotifier.refresh(channel: 'latest/edge')).called(1);
  });

  testWidgets('locally installed snap with update', (tester) async {
    final localSnapNotifier =
        createMockLocalSnapNotifier(const LocalSnap.data(localSnap));
    final snapLauncher = createMockSnapLauncher(isLaunchable: true);

    await tester.pumpApp((_) => ProviderScope(
          overrides: [
            storeSnapProvider
                .overrideWith((ref, arg) => Stream.value(storeSnap)),
            localSnapProvider.overrideWith((ref, arg) => localSnapNotifier),
            launchProvider.overrideWith((ref, arg) => snapLauncher),
            refreshProvider.overrideWith((ref) => [storeSnap]),
          ],
          child: DetailPage(snapName: storeSnap.name),
        ));
    await tester.pump();
    expectSnapInfos(tester, storeSnap);
    expect(find.text(tester.l10n.detailPageInstallLabel), findsNothing);
    expect(find.text(tester.l10n.detailPageUpdateLabel), findsOneWidget);

    await tester.tap(find.text(tester.l10n.detailPageRemoveLabel));
    verify(localSnapNotifier.remove()).called(1);

    await tester.tap(find.text(tester.l10n.detailPageUpdateLabel));
    verify(localSnapNotifier.refresh(channel: localSnap.trackingChannel))
        .called(1);

    await tester.tap(find.text(tester.l10n.managePageOpenLabel));
    verify(snapLauncher.open()).called(1);
  });

  testWidgets('not locally installed snap', (tester) async {
    final localSnapNotifier = createMockLocalSnapNotifier(
      LocalSnap.error(
        SnapdException(message: 'snap not installed', kind: 'snap-not-found'),
        StackTrace.empty,
      ),
    );

    await tester.pumpApp((_) => ProviderScope(
          overrides: [
            storeSnapProvider
                .overrideWith((ref, arg) => Stream.value(storeSnap)),
            localSnapProvider.overrideWith((ref, arg) => localSnapNotifier),
            refreshProvider
                .overrideWith((ref) => [const Snap(name: 'othersnap')]),
          ],
          child: DetailPage(snapName: storeSnap.name),
        ));
    await tester.pump();
    expectSnapInfos(tester, storeSnap);
    expect(find.text(tester.l10n.detailPageRemoveLabel), findsNothing);
    expect(find.text(tester.l10n.managePageOpenLabel), findsNothing);
    expect(find.text(tester.l10n.detailPageUpdateLabel), findsNothing);

    await tester.tap(find.text(tester.l10n.detailPageInstallLabel));
    verify(localSnapNotifier.install(channel: 'latest/stable')).called(1);
  });

  testWidgets('local-only snap', (tester) async {
    final localSnapNotifier =
        createMockLocalSnapNotifier(const LocalSnap.data(localSnap));
    final snapLauncher = createMockSnapLauncher(isLaunchable: true);

    await tester.pumpApp((_) => ProviderScope(
          overrides: [
            storeSnapProvider.overrideWith((ref, arg) => Stream.value(null)),
            localSnapProvider.overrideWith((ref, arg) => localSnapNotifier),
            launchProvider.overrideWith((ref, arg) => snapLauncher),
            refreshProvider.overrideWith((ref) => []),
          ],
          child: DetailPage(snapName: localSnap.name),
        ));
    await tester.pump();
    expectSnapInfos(tester, localSnap);
    expect(find.text(tester.l10n.detailPageInstallLabel), findsNothing);

    await tester.tap(find.text(tester.l10n.detailPageRemoveLabel));
    verify(localSnapNotifier.remove()).called(1);

    await tester.tap(find.text(tester.l10n.managePageOpenLabel));
    verify(snapLauncher.open()).called(1);
  });

  testWidgets('loading', (tester) async {
    final localSnapNotifier = createMockLocalSnapNotifier(
      const LocalSnap.loading(),
    );

    await tester.pumpApp((_) => ProviderScope(
          overrides: [
            storeSnapProvider
                .overrideWith((ref, arg) => Stream.value(storeSnap)),
            localSnapProvider.overrideWith((ref, arg) => localSnapNotifier),
            refreshProvider.overrideWith((ref) => []),
          ],
          child: DetailPage(snapName: storeSnap.name),
        ));
    await tester.pump();
    expectSnapInfos(tester, storeSnap);
    expect(find.text(tester.l10n.detailPageRemoveLabel), findsNothing);
    expect(find.text(tester.l10n.detailPageInstallLabel), findsNothing);
    expect(find.byType(YaruCircularProgressIndicator), findsOneWidget);
  });
}
