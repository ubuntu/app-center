import 'package:appstream/appstream.dart';
import 'package:meta/meta.dart';
import 'package:snapd/snapd.dart';

@immutable
class AppRating {
  final double? average;
  final int? total;

  final int? star0;
  final int? star1;
  final int? star2;
  final int? star3;
  final int? star4;
  final int? star5;

  const AppRating({
    this.average,
    this.total,
    this.star0,
    this.star1,
    this.star2,
    this.star3,
    this.star4,
    this.star5,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppRating &&
        average == other.average &&
        total == other.total;
  }

  @override
  int get hashCode => Object.hash(average, total);
}

extension SnapRatingId on Snap {
  String get ratingId => 'io.snapcraft.$name-$id';
}

extension AppstreamRatingId on AppstreamComponent {
  String get ratingId => '$package.desktop';
}
