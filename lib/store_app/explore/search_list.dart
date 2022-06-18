import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/snapx.dart';
import 'package:software/store_app/common/app_banner.dart';
import 'package:software/store_app/common/snap_dialog.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SearchList extends StatelessWidget {
  const SearchList({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    return FutureBuilder<List<Snap>>(
      future: model.findSnapsByQuery(),
      builder: (context, snapshot) => snapshot.hasData
          ? Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final snap in snapshot.data!)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: SizedBox(
                            height: 100,
                            child: AppBanner(
                              name: snap.name,
                              summary: snap.summary,
                              url: snap.iconUrl,
                              onTap: () => showDialog(
                                context: context,
                                builder: (context) => SnapDialog.create(
                                  context: context,
                                  huskSnapName: snap.name,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                ],
              ),
            )
          : const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: YaruCircularProgressIndicator(),
              ),
            ),
    );
  }
}
