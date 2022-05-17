import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/explore/app_banner.dart';
import 'package:software/pages/explore/app_dialog.dart';
import 'package:software/pages/explore/app_grid.dart';
import 'package:software/pages/explore/explore_model.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class FilterPill extends StatelessWidget {
  final IconData iconData;
  final bool selected;
  final Function()? onPressed;

  FilterPill({
    required this.selected,
    required this.iconData,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 20,
      onPressed: onPressed,
      icon: Icon(
        iconData,
        color: selected
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
      ),
    );
  }
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) {
    final client = context.read<SnapdClient>();
    return ChangeNotifierProvider(
      create: (_) => ExploreModel(client),
      child: const ExplorePage(),
    );
  }

  static Widget createTitle(BuildContext context) => Text('Explore');

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    return YaruPage(children: [
      AppBannerCarousel(),
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              for (final section in SnapSection.values)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilterPill(
                      onPressed: () => model.setFilter(snapSections: [section]),
                      selected: model.filters[section]!,
                      iconData: snapSectionToIcon[section]!),
                )
            ],
          ),
        ),
      ),
      for (int i = 0; i < model.filters.entries.length; i++)
        if (model.filters.entries.elementAt(i).value == true)
          AppGrid(
            topPadding: i == 0 ? 0 : 10,
            sectionName: model.filters.entries.elementAt(i).key.title(),
            headline: model.filters.entries.elementAt(i).key.title(),
            showHeadline: true,
          )
    ]);
  }
}

class SearchAppsDialog extends StatefulWidget {
  const SearchAppsDialog({Key? key}) : super(key: key);

  @override
  State<SearchAppsDialog> createState() => _SearchAppsDialogState();
}

class _SearchAppsDialogState extends State<SearchAppsDialog> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    return SimpleDialog(
      children: [
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: TextField(
            onChanged: (value) => model.snapSearch = value,
            autofocus: true,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
            ),
          ),
        ),
        ...model.searchedSnaps.map((e) => ListTile()).toList()
      ],
    );
  }
}

class AppBannerCarousel extends StatelessWidget {
  const AppBannerCarousel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.read<ExploreModel>();
    return FutureBuilder<List<Snap>>(
      future: model.findSnapsBySection(section: 'development'),
      builder: (context, snapshot) => snapshot.hasData
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: YaruCarousel(
                placeIndicator: false,
                autoScrollDuration: Duration(seconds: 3),
                width: MediaQuery.of(context).size.width - 30,
                height: MediaQuery.of(context).size.height / 5,
                autoScroll: true,
                children: snapshot.data!
                    .where((element) => element.media.isNotEmpty)
                    .take(10)
                    .map(
                      (snap) => AppBanner(
                        snap: snap,
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => ChangeNotifierProvider.value(
                            value: model,
                            child: AppDialog(snap: snap),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: YaruCircularProgressIndicator(),
              ),
            ),
    );
  }
}
