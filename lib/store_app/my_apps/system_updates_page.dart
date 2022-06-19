import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/app_banner.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/my_apps/system_updates_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';

class SystemUpdatesPage extends StatefulWidget {
  const SystemUpdatesPage({super.key});

  static Widget create(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SystemUpdatesModel(
        getService<PackageKitClient>(),
      ),
      child: const SystemUpdatesPage(),
    );
  }

  @override
  State<SystemUpdatesPage> createState() => _SystemUpdatesPageState();
}

class _SystemUpdatesPageState extends State<SystemUpdatesPage> {
  @override
  void initState() {
    context.read<SystemUpdatesModel>().getUpdates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SystemUpdatesModel>();
    if (model.errorString.isNotEmpty) {
      return Center(
        child: Text(model.errorString),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20, top: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (model.updates.isNotEmpty)
                ElevatedButton(
                  onPressed: model.updating ? null : () => model.updateAll(),
                  child: Text(context.l10n.updateAll),
                ),
            ],
          ),
        ),
        Expanded(
          child: model.updates.isEmpty
              ? Center(
                  child: Text(
                    context.l10n.noUpdates,
                    style: Theme.of(context).textTheme.headline4,
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: kGridDelegate,
                  itemCount: model.updates.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return AppBanner(
                      name: model.updates[index].name,
                      icon: const Icon(
                        YaruIcons.package_deb,
                        size: 50,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
