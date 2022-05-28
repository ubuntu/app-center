import 'package:collection/collection.dart';
import 'package:snapd/snapd.dart';

extension SnapX on Snap {
  String? get iconUrl => media.firstWhereOrNull((m) => m.type == 'icon')?.url;
}
