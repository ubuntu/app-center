import 'package:appstream/appstream.dart';
import 'package:snapd/snapd.dart';

class AppFinding {
  final Snap? snap;
  final AppstreamComponent? appstream;

  AppFinding({
    this.snap,
    this.appstream,
  });
}
