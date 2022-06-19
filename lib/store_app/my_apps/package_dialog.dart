import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/my_apps/package_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PackageDialog extends StatefulWidget {
  const PackageDialog({Key? key}) : super(key: key);

  static Widget create(BuildContext context, PackageKitPackageId package) {
    return ChangeNotifierProvider(
      create: (context) => PackageModel(
        getService<PackageKitClient>(),
        packageId: package,
      ),
      child: const PackageDialog(),
    );
  }

  @override
  State<PackageDialog> createState() => _PackageDialogState();
}

class _PackageDialogState extends State<PackageDialog> {
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
        if (model.packageIsInstalled)
          OutlinedButton(
            onPressed: model.processing ? null : model.remove,
            child: Text(context.l10n.remove),
          )
        else
          ElevatedButton(
            onPressed: model.processing ? null : model.install,
            child: Text(context.l10n.install),
          ),
        if (model.updateAvailable)
          ElevatedButton(
            onPressed: model.processing ? null : model.update,
            child: Text(context.l10n.refresh),
          )
      ],
    );
  }
}
