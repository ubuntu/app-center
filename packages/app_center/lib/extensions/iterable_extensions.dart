import 'package:flutter/widgets.dart';

// TODO(Lukas): Removed once the spacing argument for Row/Column lands in 3.26.0
extension WidgetIterableExtension on Iterable<Widget> {
  List<Widget> separatedBy(Widget separator) {
    return expand((item) sync* {
      yield separator;
      yield item;
    }).skip(1).toList();
  }
}
