import 'package:app_center/store/store_pages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('showAddons controls whether the Add-ons tab is present', () {
    final withAddons = buildStorePages(showAddons: true);
    final withoutAddons = buildStorePages(showAddons: false);

    expect(withoutAddons.length, withAddons.length - 1);
  });
}
