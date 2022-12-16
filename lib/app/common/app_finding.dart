import 'package:appstream/appstream.dart';
import 'package:snapd/snapd.dart';

class AppFinding {
  final Snap? snap;
  final AppstreamComponent? appstream;
  final double? rating;
  final int? totalRatings;

  AppFinding({
    this.snap,
    this.appstream,
    this.rating,
    this.totalRatings,
  });
}
