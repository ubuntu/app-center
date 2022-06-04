import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/color_scheme.dart';
import 'package:software/store_app/pages/common/app_dialog.dart';
import 'package:software/store_app/pages/common/offline_dialog.dart';
import 'package:software/store_app/pages/common/snap_model.dart';

class SnapTile extends StatefulWidget {
  const SnapTile({Key? key, required this.snapApp, required this.appIsOnline})
      : super(key: key);

  final SnapApp snapApp;
  final bool appIsOnline;

  @override
  State<SnapTile> createState() => _SnapTileState();
}

class _SnapTileState extends State<SnapTile> {
  @override
  void initState() {
    super.initState();
    final model = context.read<SnapModel>();
    model.init();
    File? file;
    if (widget.snapApp.desktopFile != null) {
      file = File(widget.snapApp.desktopFile!);
    }
    if (file != null) {
      model.getIcon(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();
    return ListTile(
      minVerticalPadding: 20,
      onTap: () {
        showDialog(
          barrierColor: Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).colorScheme.barrierColorLight
              : Theme.of(context).colorScheme.barrierColorDark,
          context: context,
          builder: (context) {
            if (widget.appIsOnline) {
              return ChangeNotifierProvider.value(
                value: model,
                child: const AppDialog(),
              );
            } else {
              return ChangeNotifierProvider.value(
                value: model,
                child: OfflineDialog(snapApp: widget.snapApp),
              );
            }
          },
        );
      },
      leading: model.icon,
      title: Text(widget.snapApp.snap!),
    );
  }
}
