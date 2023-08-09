import 'package:flutter/widgets.dart';

class Clickable extends GestureDetector {
  Clickable({super.key, super.onTap, super.child});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Builder(builder: super.build),
    );
  }
}
