import 'package:app_store/l10n.dart';
import 'package:app_store/src/detail/detail_page.dart';
import 'package:app_store/src/detail/detail_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_test/ubuntu_test.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'detail_page_test.mocks.dart';
import 'test_utils.dart';

@GenerateMocks([LocalSnapNotifier])
LocalSnapNotifier mockLocalSnapNotifier(LocalSnap state) {
  final mockNotifier = MockLocalSnapNotifier();
  // Ensure that `StateNotifierProviderElement.create` correctly sets its initial state in
  // https://github.com/rrousselGit/riverpod/blob/da4909ce73cb5420e48475113f365fc0a3368390/packages/riverpod/lib/src/state_notifier_provider/base.dart#L169
  when(mockNotifier.addListener(any, fireImmediately: true)).thenAnswer((i) {
    i.positionalArguments.first.call(state);
    return () {};
  });
  return mockNotifier;
}

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
  expect(find.text(tester.lang.detailPageVersionLabel), findsOneWidget);
  expect(find.text(snap.version), findsOneWidget);
  expect(find.text(tester.lang.detailPageWebsiteLabel), findsOneWidget);
  expect(find.text(snap.version), findsOneWidget);
  expect(find.text(tester.lang.detailPageConfinementLabel), findsOneWidget);
  expect(find.text(snap.confinement.name), findsOneWidget);
  expect(find.text(tester.lang.detailPageLicenseLabel), findsOneWidget);
  expect(find.text(snap.license!), findsOneWidget);
  expect(find.text(tester.lang.detailPageDescriptionLabel), findsOneWidget);
  expect(find.markdownBody(snap.description), findsOneWidget);
  expect(find.text(tester.lang.detailPageDownloadSizeLabel), findsOneWidget);
  expect(find.text(tester.context.formatByteSize(snap.downloadSize!)),
      findsOneWidget);
}

void main() {
  testWidgets('locally installed snap', (tester) async {
    const localSnap = storeSnap;

    final localSnapNotifier =
        mockLocalSnapNotifier(const LocalSnap.data(localSnap));

    await tester.pumpApp((_) => ProviderScope(
          overrides: [
            storeSnapProvider.overrideWith((ref, arg) => storeSnap),
            localSnapProvider.overrideWith((ref, arg) => localSnapNotifier)
          ],
          child: DetailPage(snapName: storeSnap.name),
        ));
    expectSnapInfos(tester, storeSnap);
    expect(find.text(tester.lang.detailPageInstallLabel), findsNothing);

    await tester.tap(find.text(tester.lang.detailPageRemoveLabel));
    verify(localSnapNotifier.remove()).called(1);
  });

  testWidgets('not locally installed snap', (tester) async {
    final localSnapNotifier = mockLocalSnapNotifier(
      LocalSnap.error(
        SnapdException(message: 'snap not installed', kind: 'snap-not-found'),
        StackTrace.empty,
      ),
    );

    await tester.pumpApp((_) => ProviderScope(
          overrides: [
            storeSnapProvider.overrideWith((ref, arg) => storeSnap),
            localSnapProvider.overrideWith((ref, arg) => localSnapNotifier)
          ],
          child: DetailPage(snapName: storeSnap.name),
        ));
    expectSnapInfos(tester, storeSnap);
    expect(find.text(tester.lang.detailPageRemoveLabel), findsNothing);

    await tester.tap(find.text(tester.lang.detailPageInstallLabel));
    verify(localSnapNotifier.install()).called(1);
  });

  testWidgets('loading', (tester) async {
    final localSnapNotifier = mockLocalSnapNotifier(
      const LocalSnap.loading(),
    );

    await tester.pumpApp((_) => ProviderScope(
          overrides: [
            storeSnapProvider.overrideWith((ref, arg) => storeSnap),
            localSnapProvider.overrideWith((ref, arg) => localSnapNotifier)
          ],
          child: DetailPage(snapName: storeSnap.name),
        ));
    expectSnapInfos(tester, storeSnap);
    expect(find.text(tester.lang.detailPageRemoveLabel), findsNothing);
    expect(find.text(tester.lang.detailPageInstallLabel), findsNothing);
    expect(find.byType(YaruCircularProgressIndicator), findsOneWidget);
  });
}
