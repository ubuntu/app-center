import 'package:yaru/yaru.dart';

class AppPageSection extends YaruExpandable {
  const AppPageSection({required super.header, required super.child, super.key})
      : super(
          expandButtonPosition: YaruExpandableButtonPosition.start,
          isExpanded: true,
          gapHeight: 24,
        );
}
