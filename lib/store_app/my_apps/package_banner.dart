import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/app_banner.dart';
import 'package:software/store_app/my_apps/package_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PackageBanner extends StatelessWidget {
  const PackageBanner({Key? key, required this.packageId}) : super(key: key);

  final PackageKitPackageId packageId;

  @override
  Widget build(BuildContext context) {
    bool light = Theme.of(context).brightness == Brightness.light;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => showDialog(
        context: context,
        builder: (_) => ChangeNotifierProvider(
          create: (context) => PackageModel(
            getService<PackageKitClient>(),
            packageId: packageId,
          ),
          child: const _PackageDialog(),
        ),
      ),
      child: AppBanner(
        color: light
            ? YaruColors.warmGrey.shade900
            : Theme.of(context).colorScheme.onBackground,
        elevation: light ? 2 : 1,
        title: packageId.name,
        summary: packageId.version,
        icon: const Icon(
          YaruIcons.package_deb,
          size: 50,
        ),
        borderRadius: BorderRadius.circular(10),
        textOverflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _PackageDialog extends StatefulWidget {
  const _PackageDialog({Key? key}) : super(key: key);

  @override
  State<_PackageDialog> createState() => _PackageDialogState();
}

class _PackageDialogState extends State<_PackageDialog> {
  @override
  void initState() {
    context.read<PackageModel>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PackageModel>();
    return AlertDialog(
      title: YaruDialogTitle(
        title: model.name,
        closeIconData: YaruIcons.window_close,
      ),
      titlePadding: EdgeInsets.zero,
      scrollable: true,
      content: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 145,
            height: 185,
            child: LiquidLinearProgressIndicator(
              value: model.packageIsInstalled ? 1 : 0,
              backgroundColor: Colors.white.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation(
                Theme.of(context).primaryColor,
              ),
              direction: Axis.vertical,
              borderRadius: 20,
            ),
          ),
          Icon(
            YaruIcons.debian,
            size: 120,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
        ],
      ),
      actions: [
        model.packageIsInstalled
            ? OutlinedButton(
                onPressed: model.processing ? null : model.remove,
                child: Text(context.l10n.remove),
              )
            : ElevatedButton(
                onPressed: model.processing ? null : model.install,
                child: Text(context.l10n.install),
              )
      ],
    );
  }
}
