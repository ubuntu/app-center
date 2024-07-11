import 'package:flutter/widgets.dart';

extension WidgetIterableExtension on Iterable<Widget> {
  List<Widget> separatedBy(Widget separator) {
    return expand((item) sync* {
      yield separator;
      yield item;
    }).skip(1).toList();
  }
}
