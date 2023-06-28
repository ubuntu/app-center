import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';

final manageProvider = FutureProvider.autoDispose((ref) {
  final snapd = getService<SnapdService>();
  return snapd.getSnaps();
});
