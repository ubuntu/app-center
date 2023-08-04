import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';

final categoryProvider =
    StreamProvider.autoDispose.family((ref, SnapCategoryEnum category) {
  final snapd = getService<SnapdService>();
  return snapd.getCategory(category.categoryName);
});
