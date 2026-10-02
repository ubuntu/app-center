import 'package:app_center/store/store_providers.dart';
import 'package:app_center/store/store_routes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gtk/gtk.dart';
import 'package:mockito/mockito.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'test_utils.dart';

void main() {
  tearDown(resetAllServices);

  for (final args in [
    ['--gst', 'H.265 decoder|gstreamer1(decoder-video/x-h265)()(64bit)'],
    ['--gst=H.265 decoder|gstreamer1(decoder-video/x-h265)()(64bit)'],
    ['--gst', 'foo|bar', '--gst', 'baz|qux'],
    ['--gst', 'foo,bar|baz'],
  ]) {
    test('gstreamer link opens media support: $args', () async {
      final app = createMockGtkApplicationNotifier();
      when(app.commandLine).thenReturn(args);
      registerMockService<GtkApplicationNotifier>(app);
      final container = createContainer();

      expect(container.read(initialRouteProvider), StoreRoutes.mediaSupport);
      expect(
        await container.read(routeStreamProvider.future),
        StoreRoutes.mediaSupport,
      );
    });
  }

  test('no command line does not open media support', () {
    registerMockService<GtkApplicationNotifier>(
      createMockGtkApplicationNotifier(),
    );
    final container = createContainer();

    expect(container.read(initialRouteProvider), isNull);
  });
}
