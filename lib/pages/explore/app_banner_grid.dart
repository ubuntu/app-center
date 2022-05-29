import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/common/apps_model.dart';
import 'package:software/pages/common/snap_model.dart';
import 'package:software/pages/common/snap_section.dart';
import 'package:software/pages/explore/app_banner.dart';
import 'package:software/pages/explore/app_dialog.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AppBannerGrid extends StatefulWidget {
  const AppBannerGrid({Key? key, required this.snapSection}) : super(key: key);

  final SnapSection snapSection;

  @override
  State<AppBannerGrid> createState() => _AppBannerGridState();
}

class _AppBannerGridState extends State<AppBannerGrid> {
  @override
  void initState() {
    super.initState();
    context.read<AppsModel>().loadSection('featured');
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppsModel>();
    return model.featuredSnaps.isNotEmpty
        ? GridView(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              mainAxisExtent: 150,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              maxCrossAxisExtent: 500,
            ),
            children: model.featuredSnaps.map((snap) {
              final snapModel = SnapModel(
                  huskSnapName: snap.name, client: getService<SnapdClient>());
              return ChangeNotifierProvider<SnapModel>(
                create: (context) => snapModel,
                child: AppBanner(
                  snap: snap,
                  onTap: () => showDialog(
                    barrierColor: Colors.black.withOpacity(0.9),
                    context: context,
                    builder: (context) => ChangeNotifierProvider.value(
                        value: snapModel, child: const AppDialog()),
                  ),
                ),
              );
            }).toList(),
          )
        : const YaruCircularProgressIndicator();
  }
}
