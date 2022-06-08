import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:software/store_app/common/app_banner.dart';
import 'package:software/store_app/my_apps/package_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_icons/yaru_icons.dart';

class PackageBanner extends StatefulWidget {
  const PackageBanner({Key? key}) : super(key: key);

  static Widget create(BuildContext context, PackageKitPackageId packageId) =>
      ChangeNotifierProvider(
        create: (context) =>
            PackageModel(getService<PackageKitClient>(), packageId: packageId),
        child: const PackageBanner(),
      );

  @override
  State<PackageBanner> createState() => _PackageBannerState();
}

class _PackageBannerState extends State<PackageBanner> {
  @override
  void initState() {
    context.read<PackageModel>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool light = Theme.of(context).brightness == Brightness.light;
    final model = context.watch<PackageModel>();
    return AppBanner(
      color: light
          ? YaruColors.warmGrey.shade900
          : Theme.of(context).colorScheme.onBackground,
      elevation: light ? 2 : 1,
      title: model.name,
      summary: model.version,
      icon: const Icon(
        YaruIcons.package_deb,
        size: 50,
      ),
      borderRadius: BorderRadius.circular(10),
      textOverflow: TextOverflow.ellipsis,
    );
  }
}
