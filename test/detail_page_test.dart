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
);

const storeSnap = Snap(
  name: 'testsnap',
  title: 'Testsnap',
  publisher: SnapPublisher(displayName: 'testPublisher'),
  version: '1.0.0',
  website: 'https://example.com',
  confinement: SnapConfinement.strict,
  license: 'MIT',
  description: 'this is the **description**',
  downloadSize: 1337,
);

void expectSnapInfos(WidgetTester tester, Snap snap) {
  expect(find.text(snap.title!), findsOneWidget);
  expect(find.text(snap.publisher!.displayName), findsOneWidget);
  expect(find.text(tester.l10n.detailPageVersionLabel), findsOneWidget);
  expect(find.text(snap.version), findsOneWidget);
  expect(find.text(tester.l10n.detailPageWebsiteLabel), findsOneWidget);
  expect(find.text(snap.version), findsOneWidget);
  expect(find.text(tester.l10n.detailPageConfinementLabel), findsOneWidget);
  expect(find.text(snap.confinement.name), findsOneWidget);
  expect(find.text(tester.l10n.detailPageLicenseLabel), findsOneWidget);
  expect(find.text(snap.license!), findsOneWidget);
  expect(find.text(tester.l10n.detailPageDescriptionLabel), findsOneWidget);
  expect(find.markdownBody(snap.description), findsOneWidget);
  if (snap.downloadSize != null) {
    expect(find.text(tester.l10n.detailPageDownloadSizeLabel), findsOneWidget);
    expect(find.text(tester.context.formatByteSize(snap.downloadSize!)),
        findsOneWidget);
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
    verify(localSnapNotifier.refresh()).called(1);

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
    verify(localSnapNotifier.install()).called(1);
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
