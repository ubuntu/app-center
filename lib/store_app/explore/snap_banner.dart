import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/app_change_service.dart';
import 'package:software/store_app/common/app_dialog.dart';
import 'package:software/store_app/common/app_banner.dart';
import 'package:software/store_app/common/snap_icon.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_colors/yaru_colors.dart';

class SnapBanner extends StatelessWidget {
  const SnapBanner({
    Key? key,
    required this.snap,
    this.onTap,
    this.surfaceTintColor,
    this.watermark = false,
  }) : super(key: key);

  final Snap snap;
  final Function()? onTap;
  final Color? surfaceTintColor;
  final bool watermark;

  static Widget create(BuildContext context, Snap snap) {
    final snapModel = SnapModel(
      getService<SnapdClient>(),
      getService<AppChangeService>(),
      huskSnapName: snap.name,
    );
    return ChangeNotifierProvider<SnapModel>(
      create: (context) => snapModel,
      child: SnapBanner(
        snap: snap,
        onTap: () => showDialog(
          context: context,
          builder: (context) => ChangeNotifierProvider.value(
            value: snapModel,
            child: const AppDialog(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10);

    bool light = Theme.of(context).brightness == Brightness.light;
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: surfaceTintColor != null
          ? Stack(
              children: [
                AppBanner(
                  borderRadius: borderRadius,
                  color: surfaceTintColor!,
                  title: snap.title ?? '',
                  summary: snap.summary,
                  elevation: 4,
                  icon: SnapIcon(snap),
                  textOverflow: TextOverflow.visible,
                ),
                if (watermark == true)
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: 0.1,
                        child: SizedBox(height: 130, child: SnapIcon(snap)),
                      ),
                    ),
                  ),
              ],
            )
          : AppBanner(
              borderRadius: borderRadius,
              color: light
                  ? YaruColors.warmGrey.shade900
                  : Theme.of(context).colorScheme.onBackground,
              elevation: light ? 2 : 1,
              icon: SnapIcon(snap),
              title: snap.title ?? '',
              summary: snap.summary,
              textOverflow: TextOverflow.ellipsis,
            ),
    );
  }
}
