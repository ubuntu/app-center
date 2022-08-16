import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:software/store_app/common/package_dialog.dart';
import 'package:software/store_app/common/package_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
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
    context.read<PackageModel>().init();
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
            opacity: 0.2,
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
            summary:
                '${widget.updateId.version} -> ${widget.currentId.version}',
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
            value: widget.selected,
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}
