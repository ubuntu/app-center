import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/pages/explore/app_banner.dart';
import 'package:software/pages/explore/app_dialog.dart';
import 'package:software/pages/explore/app_grid.dart';
import 'package:software/pages/explore/explore_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  static Widget create(BuildContext context) {
    final client = context.read<SnapdClient>();
    return ChangeNotifierProvider(
      create: (_) => ExploreModel(client),
      child: const ExplorePage(),
    );
  }

  static Widget createTitle(BuildContext context) =>
      Text(context.l10n.explorePageTitle);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final ScrollController _controller = ScrollController();
  double _position = 0;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    return YaruPage(children: [
      AppBannerCarousel(),
      Padding(
        padding: const EdgeInsets.only(left: 10, right: 0, top: 30, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: IconButton(
                splashRadius: 20,
                onPressed: () => model.searchActive = !model.searchActive,
                icon: Icon(
                  YaruIcons.search,
                  color: model.searchActive
                      ? Theme.of(context).primaryColor
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.8),
                ),
              ),
            ),
            SizedBox(
              height: 20,
              child: VerticalDivider(
                thickness: 1,
                width: 20,
                color: Theme.of(context).dividerColor,
              ),
            ),
            IconButton(
              onPressed: () {
                if (_position >= 1) _position -= 40;
                _controller.animateTo(
                  _position,
                  duration: Duration(milliseconds: 100),
                  curve: Curves.linear,
                );
              },
              icon: Icon(YaruIcons.pan_start),
              splashRadius: 20,
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (final section in SnapSection.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: FilterPill(
                            onPressed: () =>
                                model.setFilter(snapSections: [section]),
                            selected: model.filters[section]!,
                            iconData: snapSectionToIcon[section]!),
                      )
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                _position += 40;
                _controller.animateTo(
                  _position,
                  duration: Duration(milliseconds: 100),
                  curve: Curves.linear,
                );
              },
              icon: Icon(YaruIcons.pan_end),
              splashRadius: 20,
            ),
          ],
        ),
      ),
      if (model.searchActive) SearchField(),
      if (model.searchActive)
        AppGrid(
          topPadding: 0,
          name: model.snapSearch,
          findByName: true,
        ),
      if (!model.searchActive)
        for (int i = 0; i < model.filters.entries.length; i++)
          if (model.filters.entries.elementAt(i).value == true)
            AppGrid(
              topPadding: i == 0 ? 10 : 30,
              name: model.filters.entries.elementAt(i).key.title(),
              headline: model.filters.entries.elementAt(i).key.title(),
              findByName: false,
            ),
    ]);
  }
}

class SearchField extends StatefulWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<ExploreModel>();
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 50),
      child: TextField(
        onChanged: (value) => model.snapSearch = value,
        autofocus: true,
        decoration: InputDecoration(
          isDense: false,
          border: UnderlineInputBorder(),
        ),
      ),
    );
  }
}

class AppBannerCarousel extends StatelessWidget {
  const AppBannerCarousel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.read<ExploreModel>();
    return FutureBuilder<List<Snap>>(
      future: model.findSnapsBySection(section: 'featured'),
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
