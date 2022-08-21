import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/app_change_service.dart';
import 'package:software/snapx.dart';
import 'package:software/store_app/common/animated_scroll_view_item.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/snap_dialog.dart';
import 'package:software/store_app/my_apps/my_snaps_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class MySnapsPage extends StatefulWidget {
  const MySnapsPage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) => ChangeNotifierProvider(
        create: (context) => MySnapsModel(
          getService<SnapdClient>(),
          getService<AppChangeService>(),
        ),
        child: const MySnapsPage(),
      );

  @override
  State<MySnapsPage> createState() => _MySnapsPageState();
}

class _MySnapsPageState extends State<MySnapsPage> {
  @override
  void initState() {
    context.read<MySnapsModel>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mySnapsModel = context.watch<MySnapsModel>();
    return mySnapsModel.localSnaps.isNotEmpty
        ? _MySnapsGrid(snaps: mySnapsModel.localSnaps)
        : const SizedBox();
  }
}

class _MySnapsGrid extends StatefulWidget {
  // ignore: unused_element
  const _MySnapsGrid({super.key, required this.snaps});

  final List<Snap> snaps;

  @override
  State<_MySnapsGrid> createState() => __MySnapsGridState();
}

class __MySnapsGridState extends State<_MySnapsGrid> {
  late ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _controller,
      padding: const EdgeInsets.all(20.0),
      gridDelegate: kGridDelegate,
      shrinkWrap: true,
      itemCount: widget.snaps.length,
      itemBuilder: (context, index) {
        final snap = widget.snaps.elementAt(index);
        return AnimatedScrollViewItem(
          child: YaruBanner(
            name: snap.name,
            summary: snap.summary,
            url: snap.iconUrl,
            fallbackIconData: YaruIcons.package_snap,
            onTap: () => showDialog(
              context: context,
              builder: (context) =>
                  SnapDialog.create(context: context, huskSnapName: snap.name),
            ),
          ),
        );
      },
    );
  }
}
