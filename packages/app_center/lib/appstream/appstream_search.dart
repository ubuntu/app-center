import 'package:app_center/appstream/appstream.dart';
import 'package:appstream/appstream.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

final appstreamSearchProvider =
    StreamProvider.family<List<AppstreamComponent>, String>(
      (
        ref,
        query,
      ) => _search(query, returnBeforeInitialization: true),
    );

final appstreamSearchWithLoadingProvider =
    StreamProvider.family<List<AppstreamComponent>, String>(
      (
        ref,
        query,
      ) => _search(query, returnBeforeInitialization: false),
    );

Stream<List<AppstreamComponent>> _search(
  String query, {
  required bool returnBeforeInitialization,
}) async* {
  final appstream = getService<AppstreamService>();
  if (!appstream.initialized) {
    if (returnBeforeInitialization) {
      // Do not slow down autocomplete while AppStream populates its cache.
      yield [];
    }
    await appstream.init();
  }
  yield await appstream.search(query);
}
