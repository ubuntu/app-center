import 'package:app_center/appstream.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

final appstreamSearchProvider =
    StreamProvider.family<List<AppstreamComponent>, String>(
        (ref, query) async* {
  final appstream = getService<AppstreamService>();
  if (!appstream.initialized) {
    // Return empty results in order to not slow down the autocompletion, in case
    // the appstream service is still populating the cache.
    yield [];
    await appstream.init();
  }
  yield await appstream.search(query);
});
