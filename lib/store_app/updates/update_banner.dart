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
            opacity: 0.5,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: YaruLinearProgressIndicator(
                minHeight: 60,
                value: percentage != null ? percentage! / 100 : null,
              ),
            ),
          ),
        CheckboxListTile(
          value: selected,
          onChanged: onChanged,
          title: Text(id.name),
          subtitle: Text(id.version),
          secondary: const Icon(
            YaruIcons.package_deb,
            size: 50,
          ),
        )
      ],
    );
  }
}
