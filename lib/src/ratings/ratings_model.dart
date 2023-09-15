import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'exports.dart';

import 'ratings_service.dart';

final ratingsModelProvider =
    ChangeNotifierProvider.family.autoDispose<RatingsModel, String>(
  (ref, snapId) => RatingsModel(
    ratings: getService<RatingsService>(),
    snapId: snapId,
  )..init(),
);

class RatingsModel extends ChangeNotifier {
  RatingsModel({
    required this.ratings,
    required this.snapId,
  }) : _state = const AsyncValue.loading();
  final RatingsService ratings;
  final String snapId;

  Rating? snapRating;

  AsyncValue<void> get state => _state;
  AsyncValue<void> _state;

  Future<void> init() async {
    _state = await AsyncValue.guard(() async {
      final rating = await ratings.getRating(snapId);
      _setSnapRating(rating);
      notifyListeners();
    });
  }

  void _setSnapRating(Rating? rating) {
    snapRating = rating;
  }
}
