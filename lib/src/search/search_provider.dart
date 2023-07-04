import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';

final searchProvider = FutureProvider.autoDispose.family((ref, String query) {
  final snapd = getService<SnapdService>();
  return snapd.find(query: query);
});
