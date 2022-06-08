import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/app_change_service.dart';
import 'package:software/store_app/common/app_banner.dart';
import 'package:software/store_app/common/snap_dialog.dart';
import 'package:software/store_app/my_apps/offline_dialog.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_colors/yaru_colors.dart';

class LocalSnapBanner extends StatefulWidget {
  const LocalSnapBanner({Key? key, required this.online}) : super(key: key);

  final bool online;

  static Widget create(BuildContext context, String snapName, bool online) {
    final snapModel = SnapModel(
      getService<SnapdClient>(),
      getService<AppChangeService>(),
      huskSnapName: snapName,
      online: online,
    );
    return ChangeNotifierProvider<SnapModel>(
      create: (context) => snapModel,
      child: LocalSnapBanner(online: online),
    );
  }

  @override
  State<LocalSnapBanner> createState() => _LocalSnapBannerState();
}

class _LocalSnapBannerState extends State<LocalSnapBanner> {
  @override
  void initState() {
    final model = context.read<SnapModel>();
    model.init().then((value) => model.loadOfflineIcon());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10);
    bool light = Theme.of(context).brightness == Brightness.light;
    final model = context.watch<SnapModel>();
    return InkWell(
      onTap: () => showDialog(
        context: context,
        builder: (context) {
          if (widget.online) {
            return ChangeNotifierProvider.value(
              value: model,
              child: const SnapDialog(),
            );
          } else {
            return OfflineDialog.createFromValue(
              context: context,
              value: model,
            );
          }
        },
      ),
      borderRadius: borderRadius,
      child: AppBanner(
        borderRadius: borderRadius,
        color: light
            ? YaruColors.warmGrey.shade900
            : Theme.of(context).colorScheme.onBackground,
        elevation: light ? 2 : 1,
        icon: model.offlineIcon,
        title: model.title ?? '',
        summary: model.summary ?? '',
        textOverflow: TextOverflow.ellipsis,
      ),
    );
  }
}
