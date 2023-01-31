import 'package:appstream/appstream.dart';
import 'package:snapd/snapd.dart';

class AppRating {
  final double? average;
  final int? total;

  AppRating({
    this.average,
    this.total,
  });
}

extension SnapRatingId on Snap {
  String get ratingId => 'io.snapcraft.$name-$id';
}

extension AppstreamRatingId on AppstreamComponent {
  String get ratingId => '$package.desktop';
}
