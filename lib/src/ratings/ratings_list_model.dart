import 'package:app_center/src/ratings/ratings_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import 'exports.dart';

final ratingsListModelProvider =
    ChangeNotifierProvider.family.autoDispose<RatingsListModel, List<String>>(
  (ref, snapIds) => RatingsListModel(
    ratingsService: getService<RatingsService>(),
    snapIds: snapIds,
  )..init(),
);

class RatingsListModel extends ChangeNotifier {
  RatingsListModel({
    required this.ratingsService,
    required this.snapIds,
  }) : _state = const AsyncValue.loading();
  final RatingsService ratingsService;
  final List<String> snapIds;

  Map<String, Rating?>? snapRatings;

  AsyncValue<void> get state => _state;
  AsyncValue<void> _state;

  Future<void> init() async {
    _state = await AsyncValue.guard(() async {
      final snapRatings = await ratingsService.getRatings(snapIds);
      _setSnapRatings(snapRatings);
      notifyListeners();
    });
  }

  void _setSnapRatings(Map<String, Rating?> snapRatings) {
    this.snapRatings = snapRatings;
  }
}
