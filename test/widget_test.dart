import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:software/services/package_service.dart';
import 'package:software/services/snap_service.dart';
import 'package:software/store_app/store_app.dart';
import 'package:software/updates_state.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'widget_test.mocks.dart';

@GenerateMocks(
  [
    Connectivity,
    PackageService,
    SnapService,
  ],
)
void main() {
  testWidgets('Software app', (tester) async {
    final connectivityMock = MockConnectivity();
    registerMockService<Connectivity>(connectivityMock);
    final connectivityChangedController =
        StreamController<ConnectivityResult>.broadcast();
    when(connectivityMock.onConnectivityChanged)
        .thenAnswer((_) => connectivityChangedController.stream);
    when(connectivityMock.checkConnectivity())
        .thenAnswer((_) => Future.value(ConnectivityResult.none));

    final packageServiceMock = MockPackageService();
    registerMockService<PackageService>(packageServiceMock);
    when(packageServiceMock.updates).thenReturn([]);
    final updatesChangedController = StreamController<bool>.broadcast();
    when(packageServiceMock.updatesChanged)
        .thenAnswer((_) => updatesChangedController.stream);
    final updatesStateController = StreamController<UpdatesState>.broadcast();
    when(packageServiceMock.updatesState)
        .thenAnswer((_) => updatesStateController.stream);

    final snapServiceMock = MockSnapService();
    registerMockService<SnapService>(snapServiceMock);
    when(snapServiceMock.snapChanges).thenReturn({});
    final snapChangesInsertedController = StreamController<bool>.broadcast();
    when(snapServiceMock.snapChangesInserted)
        .thenAnswer((_) => snapChangesInsertedController.stream);
    when(
      snapServiceMock.findSnapsBySection(
        sectionName: anyNamed('sectionName'),
      ),
    ).thenAnswer((_) => Future.value([]));

    await tester.pumpWidget(StoreApp.create());

    final materialApp = find.byType(MaterialApp);
    expect(materialApp, findsOneWidget);
    expect(
      (materialApp.evaluate().single.widget as MaterialApp).title,
      'Ubuntu Software App',
    );
  });
}
