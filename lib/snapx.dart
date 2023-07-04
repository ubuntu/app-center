import 'package:collection/collection.dart';
import 'package:snapd/snapd.dart';

extension SnapX on Snap {
  String? get iconUrl => media.firstWhereOrNull((m) => m.type == 'icon')?.url;
  bool get verifiedPublisher => publisher?.validation == 'verified';
  bool get starredPublisher => publisher?.validation == 'starred';
}
