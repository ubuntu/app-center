import 'dart:async';

import 'package:app_center/addons/addons.dart';
import 'package:app_center/constants.dart';
import 'package:app_center/snapd/snap_launcher.dart';
import 'package:app_center/store/store_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru/yaru.dart';

import 'test_utils.dart';

void main() {
  tearDown(resetAllServices);

  /// Pumps the page and returns the names of routes pushed from it.
  Future<List<String>> pumpAddonsPage(
    WidgetTester tester, {
    SnapLauncher? firmwareLauncher,
    Object? firmwareError,
    bool firmwareLoading = false,
  }) async {
    final pushedRoutes = <String>[];
    await tester.pumpApp(
      (_) => ProviderScope(
        overrides: [
          firmwareUpdaterLauncherProvider.overrideWith(
            (_) => firmwareLoading
                ? Completer<SnapLauncher?>().future
                : firmwareError != null
                ? Future.error(firmwareError)
                : Future.value(firmwareLauncher),
          ),
        ],
        child: Navigator(
          onGenerateRoute: (settings) {
            final isHome = settings.name == Navigator.defaultRouteName;
            if (!isHome) pushedRoutes.add(settings.name!);
            return MaterialPageRoute(
              settings: settings,
              builder: (_) =>
                  isHome ? const AddonsPage() : const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
    await tester.pump();
    return pushedRoutes;
  }

  final firmwareStoreRoute = StoreRoutes.namedSnap(
    name: kFirmwareUpdaterSnapName,
  );

  testWidgets('renders Additional drivers tile when drivers are available', (
    tester,
  ) async {
    registerMockDriversService();
    await pumpAddonsPage(tester);

    expect(
      find.text(tester.l10n.addonsPageAdditionalDriversTitle),
      findsOneWidget,
    );
    expect(
      find.text(tester.l10n.addonsPageAdditionalDriversDescription),
      findsOneWidget,
    );
    expect(find.byIcon(YaruIcons.go_next), findsNWidgets(3));
  });

  testWidgets('hides Additional drivers tile when drivers are unavailable', (
    tester,
  ) async {
    registerMockDriversService(available: false);
    await pumpAddonsPage(tester);

    expect(
      find.text(tester.l10n.addonsPageAdditionalDriversTitle),
      findsNothing,
    );
    expect(find.byIcon(YaruIcons.go_next), findsNWidgets(2));
  });

  testWidgets('links to the firmware updater snap when not installed', (
    tester,
  ) async {
    registerMockDriversService(available: false);
    final pushedRoutes = await pumpAddonsPage(tester);

    expect(
      find.text(tester.l10n.addonsPageFirmwareDescription),
      findsOneWidget,
    );
    expect(find.byIcon(YaruIcons.external_link), findsNothing);

    await tester.tap(find.text(tester.l10n.addonsPageFirmwareTitle));
    await tester.pump();

    expect(pushedRoutes, [firmwareStoreRoute]);
  });

  testWidgets('links to the firmware updater snap when snapd fails', (
    tester,
  ) async {
    registerMockDriversService(available: false);
    final pushedRoutes = await pumpAddonsPage(
      tester,
      firmwareError: SnapdException(message: 'offline'),
    );

    expect(find.byIcon(YaruIcons.external_link), findsNothing);

    await tester.tap(find.text(tester.l10n.addonsPageFirmwareTitle));
    await tester.pump();

    expect(pushedRoutes, [firmwareStoreRoute]);
  });

  testWidgets('firmware tile does nothing while still checking', (
    tester,
  ) async {
    registerMockDriversService(available: false);
    final pushedRoutes = await pumpAddonsPage(tester, firmwareLoading: true);

    await tester.tap(find.text(tester.l10n.addonsPageFirmwareTitle));
    await tester.pump();

    expect(pushedRoutes, isEmpty);
  });

  testWidgets('launches the firmware updater when installed', (tester) async {
    registerMockDriversService(available: false);
    final launcher = createMockSnapLauncher(isLaunchable: true);
    await pumpAddonsPage(tester, firmwareLauncher: launcher);

    expect(find.byIcon(YaruIcons.external_link), findsOneWidget);

    await tester.tap(find.text(tester.l10n.addonsPageFirmwareTitle));
    await tester.pump();

    verify(launcher.open()).called(1);
  });
}
