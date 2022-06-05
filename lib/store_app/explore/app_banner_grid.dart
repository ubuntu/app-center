import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/color_scheme.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/app_dialog.dart';
import 'package:software/store_app/common/apps_model.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:software/store_app/common/snap_section.dart';
import 'package:software/store_app/explore/app_banner.dart';

class AppBannerGrid extends StatefulWidget {
  const AppBannerGrid({Key? key, required this.snapSection, this.amount = 20})
      : super(key: key);

  final SnapSection snapSection;
  final int amount;

  @override
  State<AppBannerGrid> createState() => _AppBannerGridState();
}

class _AppBannerGridState extends State<AppBannerGrid> {
  @override
  void initState() {
    super.initState();
    context.read<AppsModel>().loadSection(widget.snapSection.title);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppsModel>();
    final sections = model.sectionNameToSnapsMap[widget.snapSection.title];
    if (sections == null || sections.isEmpty) {
      return const SizedBox();
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 10, bottom: 10),
            child: Text(
              widget.snapSection.localize(context.l10n),
              style: Theme.of(context)
                  .textTheme
                  .headline4!
                  .copyWith(fontWeight: FontWeight.w200),
            ),
          ),
          GridView(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              mainAxisExtent: 110,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              maxCrossAxisExtent: 500,
            ),
            children: sections.take(widget.amount).map((snap) {
              final snapModel = SnapModel(
                huskSnapName: snap.name,
              );
              return ChangeNotifierProvider<SnapModel>(
                create: (context) => snapModel,
                child: AppBanner(
                  snap: snap,
                  onTap: () => showDialog(
                    barrierColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Theme.of(context).colorScheme.barrierColorLight
                            : Theme.of(context).colorScheme.barrierColorDark,
                    context: context,
                    builder: (context) => ChangeNotifierProvider.value(
                      value: snapModel,
                      child: const AppDialog(),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      );
    }
  }
}
