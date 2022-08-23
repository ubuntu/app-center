import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/package_dialog.dart';
import 'package:software/store_app/common/package_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class UpdateBanner extends StatefulWidget {
  const UpdateBanner({
    super.key,
    required this.selected,
    this.onChanged,
    required this.processed,
    this.percentage,
    required this.updateId,
    required this.currentId,
  });

  static Widget create({
    required BuildContext context,
    required PackageKitPackageId updateId,
    required PackageKitPackageId installedId,
    bool? selected,
    required bool processed,
    Function(bool?)? onChanged,
    int? percentage,
  }) {
    return ChangeNotifierProvider<PackageModel>(
      create: (_) => PackageModel(
        getService<PackageKitClient>(),
        packageId: updateId,
        installedId: installedId,
      ),
      child: UpdateBanner(
        selected: selected,
        processed: processed,
        updateId: updateId,
        currentId: installedId,
        onChanged: onChanged,
        percentage: percentage,
      ),
    );
  }

  final bool? selected;
  final Function(bool?)? onChanged;
  final bool processed;
  final int? percentage;
  final PackageKitPackageId updateId;
  final PackageKitPackageId currentId;

  @override
  State<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends State<UpdateBanner> {
  @override
  void initState() {
    context.read<PackageModel>().init(update: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PackageModel>();
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.processed)
          Opacity(
            opacity: 0.4,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: LinearProgressIndicator(
                minHeight: 110,
                value:
                    widget.percentage != null ? widget.percentage! / 100 : null,
              ),
            ),
          ),
        Opacity(
          opacity: widget.processed ? 0.7 : 1,
          child: YaruBanner(
            onTap: () => showDialog(
              context: context,
              builder: (context) => ChangeNotifierProvider.value(
                value: model,
                child: const PackageDialog(
                  showActions: false,
                ),
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
                  widget.currentId.version,
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
            icon: model.group == PackageKitGroup.system
                ? const _SystemUpdateIcon()
                : Icon(
                    YaruIcons.package_deb_filled,
                    size: 50,
                    color: Colors.brown[300],
                  ),
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
