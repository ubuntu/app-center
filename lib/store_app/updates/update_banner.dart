import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/package_dialog.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class UpdateBanner extends StatefulWidget {
  const UpdateBanner({
    super.key,
    required this.selected,
    this.onChanged,
    required this.updateId,
    required this.installedId,
    required this.group,
  });

  final bool? selected;
  final Function(bool?)? onChanged;
  final PackageKitPackageId updateId;
  final PackageKitPackageId installedId;
  final PackageKitGroup group;

  @override
  State<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends State<UpdateBanner> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        YaruBanner(
          onTap: () => showDialog(
            context: context,
            builder: (_) => PackageDialog.create(
              context: context,
              id: widget.updateId,
              installedId: widget.installedId,
              noUpdate: false,
            ),
          ),
          bannerWidth: 500,
          nameTextOverflow: TextOverflow.visible,
          name: widget.updateId.name,
          subtitleWidget: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.installedId.version,
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(YaruIcons.pan_end),
              Expanded(
                child: Text(
                  widget.updateId.version,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: Theme.of(context).brightness == Brightness.light
                        ? positiveGreenLightTheme
                        : positiveGreenDarkTheme,
                  ),
                ),
              )
            ],
          ),
          fallbackIconData: YaruIcons.package_deb,
          icon: widget.group == PackageKitGroup.system ||
                  widget.group == PackageKitGroup.security
              ? const _SystemUpdateIcon()
              : Icon(
                  YaruIcons.package_deb_filled,
                  size: 50,
                  color: Colors.brown[300],
                ),
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Checkbox(
            value: widget.selected,
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}

class _SystemUpdateIcon extends StatelessWidget {
  const _SystemUpdateIcon({
    // ignore: unused_element
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 2,
          left: 13,
          child: Container(
            height: 25,
            width: 25,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
        const Icon(
          YaruIcons.ubuntu_logo_large,
          size: 50,
          color: YaruColors.orange,
        ),
        Positioned(
          top: -1,
          right: 2,
          child: Icon(
            YaruIcons.shield,
            size: 26,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Positioned(
          top: 0,
          right: 2,
          child: Icon(
            YaruIcons.shield,
            size: 25,
            color: Colors.amber[800],
          ),
        )
      ],
    );
  }
}
