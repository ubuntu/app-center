import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/common/snap_section.dart';

class AppsModel extends SafeChangeNotifier {
  final SnapdClient client;

  AppsModel(this.client)
      : snapAppToSnapMap = {},
        _searchActive = false,
        _searchQuery = '',
        _exploreMode = true,
        featuredSnaps = [],
        snapApps = [];

  Future<List<Snap>> findSnapsBySection({String? section}) async =>
      (await client.find(section: section));

  Future<Snap> findSnapByName(String name) async =>
      (await client.find(name: name)).first;

  List<SnapApp> snapApps;
  Future<List<SnapApp>> loadSnapApps() async {
    await client.loadAuthorization();
    final apps = await client.apps();
    snapApps.clear();
    snapApps.addAll(apps.where((element) => element.desktopFile != null));
    notifyListeners();
    return apps;
  }

  Future<bool> snapIsIstalled(Snap snap) async {
    for (var snapApp in (await loadSnapApps())) {
      if (snap.name == snapApp.snap) return true;
    }
    return false;
  }

  bool _searchActive;
  bool get searchActive => _searchActive;
  set searchActive(bool value) {
    if (value == _searchActive) return;
    _searchActive = value;
    if (_searchActive == false) {
      searchQuery = '';
    }
    notifyListeners();
  }

  bool _exploreMode;
  bool get exploreMode => _exploreMode;
  set exploreMode(bool value) {
    if (value == _exploreMode) return;
    _exploreMode = value;
    notifyListeners();
  }

  String _searchQuery;
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    if (value == _searchQuery) return;
    _searchQuery = value;
    notifyListeners();
  }

  final Map<SnapSection, bool> filters = {
    SnapSection.artAndDesign: false,
    SnapSection.booksAndReference: false,
    SnapSection.development: false,
    SnapSection.devicesAndIot: false,
    SnapSection.education: false,
    SnapSection.entertainment: false,
    SnapSection.featured: false,
    SnapSection.finance: false,
    SnapSection.games: false,
    SnapSection.healthAndFitness: false,
    SnapSection.musicAndAudio: false,
    SnapSection.newsAndWeather: false,
    SnapSection.personalisation: false,
    SnapSection.photoAndVideo: false,
    SnapSection.productivity: false,
    SnapSection.science: false,
    SnapSection.security: false,
    SnapSection.serverAndCloud: false,
    SnapSection.social: false,
    SnapSection.utilities: false,
  };

  List<SnapSection> get selectedFilters =>
      filters.entries
          .where((entry) => entry.value == true)
          .map((e) => e.key)
          .toList() +
      filters.entries
          .where((entry) => entry.value == false)
          .map((e) => e.key)
          .toList();

  void setFilter({required List<SnapSection> snapSections}) {
    for (var snapSection in snapSections) {
      filters[snapSection] = !filters[snapSection]!;
    }
    notifyListeners();
  }

  Future<List<Snap>> findSnapsByQuery() async =>
      searchQuery.isEmpty ? [] : await client.find(query: _searchQuery);

  Map<SnapApp, Snap> snapAppToSnapMap;
  Future<void> mapSnaps() async {
    for (var snapApp in (await loadSnapApps())
        .where((element) => element.desktopFile != null)) {
      final List<Snap> snapsWithThisName =
          await client.find(name: snapApp.snap);
      snapAppToSnapMap.putIfAbsent(snapApp, () => snapsWithThisName.first);
    }
    notifyListeners();
  }

  List<Snap> featuredSnaps;
  Future<void> loadFeaturedSnaps() async {
    for (final featuredSnap in await findSnapsBySection(section: 'featured')) {
      featuredSnaps.add(featuredSnap);
    }
    notifyListeners();
  }
}
