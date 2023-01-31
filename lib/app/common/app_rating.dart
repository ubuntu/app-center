import 'package:appstream/appstream.dart';
import 'package:meta/meta.dart';
import 'package:snapd/snapd.dart';

@immutable
class AppRating {
  final double? average;
  final int? total;

  const AppRating({
    this.average,
    this.total,
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
