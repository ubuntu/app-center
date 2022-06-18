import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/snapx.dart';
import 'package:software/store_app/common/app_banner.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:software/store_app/common/snap_dialog.dart';
import 'package:software/store_app/explore/explore_model.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    if (model.searchQuery.isEmpty) return const SizedBox();
    return FutureBuilder<List<Snap>>(
      future: model.findSnapsByQuery(),
      builder: (context, snapshot) =>
          snapshot.hasData && snapshot.data!.isNotEmpty
              ? GridView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: kGridDelegate,
                  shrinkWrap: true,
                  children: [
                    for (final snap in snapshot.data!)
                      AppBanner(
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
                      )
                  ],
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
