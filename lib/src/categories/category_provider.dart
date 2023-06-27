import 'package:app_store/snapd.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

final categoryProvider =
    FutureProvider.autoDispose.family((ref, String category) {
  final snapd = getService<SnapdService>();
  return snapd.find(category: category);
});
