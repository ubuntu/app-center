import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/common/snap_section.dart';

class AppsModel extends SafeChangeNotifier {
  final SnapdClient client;
  final Connectivity _connectivity;
  StreamSubscription? _sub;
  ConnectivityResult? _state;
  ConnectivityResult? get state => _state;

  AppsModel(this.client, this._connectivity)
      : snapAppToSnapMap = {},
        _searchActive = false,
        _searchQuery = '',
        _exploreMode = true,
        sectionNameToSnapsMap = {};

  Future<List<Snap>> findSnapsBySection({String? section}) async {
    if (section == null) return [];
    return (await client.find(section: section));
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
    SnapSection.art_and_design: false,
    SnapSection.books_and_reference: false,
    SnapSection.development: false,
    SnapSection.devices_and_iot: false,
    SnapSection.education: false,
    SnapSection.entertainment: false,
    SnapSection.featured: false,
    SnapSection.finance: false,
    SnapSection.games: false,
    SnapSection.health_and_fitness: false,
    SnapSection.music_and_audio: false,
    SnapSection.news_and_weather: false,
    SnapSection.personalisation: false,
    SnapSection.photo_and_video: false,
    SnapSection.productivity: false,
    SnapSection.science: false,
    SnapSection.security: false,
    SnapSection.server_and_cloud: false,
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
      loadSection(snapSection.title);
    }
  }

  Future<List<Snap>> findSnapsByQuery() async =>
      searchQuery.isEmpty ? [] : await client.find(query: _searchQuery);

  Map<SnapApp, Snap> snapAppToSnapMap;
  Future<void> mapSnaps() async {
    await client.loadAuthorization();
    final snapApps = await client.getApps();
    for (var snapApp in snapApps.where(
        (snapApp) => snapApp.desktopFile != null && snapApp.snap != null)) {
      final snapsWithThisName = await client.getSnap(snapApp.snap!);
      snapAppToSnapMap.putIfAbsent(snapApp, () => snapsWithThisName);
    }
    notifyListeners();
  }

  Map<String, List<Snap>> sectionNameToSnapsMap;
  Future<void> loadSection(String name) async {
    List<Snap> sectionList = [];
    for (final snap in await findSnapsBySection(section: name)) {
      sectionList.add(snap);
    }
    sectionNameToSnapsMap.putIfAbsent(name, () => sectionList);
    notifyListeners();
  }

  Future<void> refresh() {
    return _connectivity.checkConnectivity().then((state) {
      _state = state;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  bool get appIsOnline =>
      _state == ConnectivityResult.ethernet ||
      _state == ConnectivityResult.wifi;

  Future<void> initConnectivity() async {
    _sub = _connectivity.onConnectivityChanged.listen((state) {
      _state = state;
      notifyListeners();
    });
    return refresh();
  }
}
