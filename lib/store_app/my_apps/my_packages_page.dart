import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:software/store_app/common/app_banner.dart';
import 'package:software/store_app/my_apps/my_packages_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MyPackagesPage extends StatefulWidget {
  const MyPackagesPage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyPackagesModel(getService<PackageKitClient>()),
      child: const MyPackagesPage(),
    );
  }

  @override
  State<MyPackagesPage> createState() => _MyPackagesPageState();
}

class _MyPackagesPageState extends State<MyPackagesPage> {
  @override
  void initState() {
    context.read<MyPackagesModel>().getPackages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MyPackagesModel>();
    bool light = Theme.of(context).brightness == Brightness.light;

    return YaruPage(
      children: [
        model.packages.isEmpty
            ? const YaruCircularProgressIndicator()
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  mainAxisExtent: 110,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  maxCrossAxisExtent: 700,
                ),
                shrinkWrap: true,
                itemCount: model.packages.length,
                itemBuilder: (context, index) {
                  final package = model.packages.elementAt(index);
                  return AppBanner(
                    color: light
                        ? YaruColors.warmGrey.shade900
                        : Theme.of(context).colorScheme.onBackground,
                    elevation: light ? 2 : 1,
                    title: package.name,
                    summary: package.version,
                    icon: const Icon(
                      YaruIcons.package_deb,
                      size: 50,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    textOverflow: TextOverflow.ellipsis,
                  );
                },
              ),
      ],
    );
  }
}
