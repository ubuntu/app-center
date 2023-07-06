import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';
import '/snapx.dart';

final manageProvider = FutureProvider.autoDispose((ref) async {
  final snaps = await getService<SnapdService>().getSnaps();
  snaps.sort(((a, b) =>
      a.titleOrName.toLowerCase().compareTo(b.titleOrName.toLowerCase())));
  return snaps;
});
