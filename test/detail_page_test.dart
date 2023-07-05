import 'package:app_store/src/detail/detail_page.dart';
import 'package:app_store/src/detail/detail_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'detail_page_test.mocks.dart';
import 'test_utils.dart';

@GenerateMocks([DetailNotifier])
DetailNotifier buildDetailNotifier(DetailState state) {
  final mockDetailNotifier = MockDetailNotifier();
  when(mockDetailNotifier.addListener(any, fireImmediately: true))
      .thenAnswer((i) {
    i.positionalArguments.first.call(state);
    return () {};
  });
  return mockDetailNotifier;
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
}

void main() {
  testWidgets('locally installed snap', (tester) async {
    const localSnap = storeSnap;

    final mockDetailNotifier =
        buildDetailNotifier(const DetailState.data(localSnap));

    await tester.pumpApp((_) => ProviderScope(
          overrides: [
            detailModelProvider.overrideWith((ref, arg) => mockDetailNotifier)
          ],
          child: const DetailPage(snap: storeSnap),
        ));
    expectSnapInfos(tester, storeSnap);
    expect(find.text(tester.lang.detailPageInstallLabel), findsNothing);

    await tester.tap(find.text(tester.lang.detailPageRemoveLabel));
    verify(mockDetailNotifier.remove()).called(1);
  });

  testWidgets('not locally installed snap', (tester) async {
    final mockDetailNotifier = buildDetailNotifier(
      DetailState.error(
        SnapdException(message: 'snap not installed', kind: 'snap-not-found'),
        StackTrace.empty,
      ),
    );

    await tester.pumpApp((_) => ProviderScope(
          overrides: [
            detailModelProvider.overrideWith((ref, arg) => mockDetailNotifier)
          ],
          child: const DetailPage(snap: storeSnap),
        ));
    expectSnapInfos(tester, storeSnap);
    expect(find.text(tester.lang.detailPageRemoveLabel), findsNothing);

    await tester.tap(find.text(tester.lang.detailPageInstallLabel));
    verify(mockDetailNotifier.install()).called(1);
  });

  testWidgets('loading', (tester) async {
    final mockDetailNotifier = buildDetailNotifier(
      const DetailState.loading(),
    );

    await tester.pumpApp((_) => ProviderScope(
          overrides: [
            detailModelProvider.overrideWith((ref, arg) => mockDetailNotifier)
          ],
          child: const DetailPage(snap: storeSnap),
        ));
    expectSnapInfos(tester, storeSnap);
    expect(find.text(tester.lang.detailPageRemoveLabel), findsNothing);
    expect(find.text(tester.lang.detailPageInstallLabel), findsNothing);
    expect(find.byType(YaruCircularProgressIndicator), findsOneWidget);
  });
}
