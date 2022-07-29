import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class UpdateBanner extends StatelessWidget {
  const UpdateBanner({
    super.key,
    required this.selected,
    this.onChanged,
    required this.processed,
    this.percentage,
    required this.id,
  });

  final bool? selected;
  final Function(bool?)? onChanged;
  final bool processed;
  final int? percentage;
  final PackageKitPackageId id;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (processed)
          Opacity(
            opacity: 0.2,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: LinearProgressIndicator(
                minHeight: 110,
                value: percentage != null ? percentage! / 100 : null,
              ),
            ),
          ),
        Opacity(
          opacity: processed ? 0.7 : 1,
          child: YaruBanner(
            name: id.name,
            summary: id.version,
            fallbackIconData: YaruIcons.package_deb,
            icon: const Icon(
              YaruIcons.package_deb,
              size: 50,
            ),
          ),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Checkbox(
            value: selected,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
