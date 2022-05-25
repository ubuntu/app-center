import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/common/snap_section.dart';

class AppsModel extends SafeChangeNotifier {
  final SnapdClient client;

  AppsModel(this.client)
      : _appChangeInProgress = false,
        snapAppToSnapMap = {},
        _searchActive = false,
        _searchQuery = '',
        _exploreMode = true,
        _currentSnapChannel = '';

  bool _appChangeInProgress;
  bool get appChangeInProgress => _appChangeInProgress;
  set appChangeInProgress(bool value) {
    if (value == _appChangeInProgress) return;
    _appChangeInProgress = value;
    notifyListeners();
  }

  Future<List<Snap>> findSnapsBySection({String? section}) async {
    final snaps = await client.find(section: section);
    return snaps;
  }

  Future<Snap> findSnapByName(String name) async {
    final snaps = await client.find(name: name);
    return snaps.first;
  }

  Future<void> installSnap(Snap snap, String? channel) async {
    await client.loadAuthorization();
    final changeId = await client.install(
      snap.name,
      channel: channel,
      classic: snap.confinement == SnapConfinement.classic,
    );
    appChangeInProgress = true;
    while (true) {
      final change = await client.getChange(changeId);
      if (change.ready) {
        appChangeInProgress = false;
        break;
      }
      await Future.delayed(
        Duration(milliseconds: 100),
      );
    }
    appChangeInProgress = false;
  }

  Future<void> unInstallSnap(SnapApp snapApp) async {
    await client.loadAuthorization();
    final id = await client.remove(snapApp.name);
    appChangeInProgress = true;
    while (true) {
      final change = await client.getChange(id);
      if (change.ready) {
        appChangeInProgress = false;
        break;
      }

      await Future.delayed(
        Duration(milliseconds: 100),
      );
    }
    appChangeInProgress = false;
  }

  Future<void> refreshSnapApp(Snap snap, String snapChannel) async {
    await client.loadAuthorization();
    final id = await client.refresh(snap.name,
        channel:
            snapChannel.replaceAll('latest/', '').replaceAll('insiders/', ''));
    appChangeInProgress = true;
    while (true) {
      final change = await client.getChange(id);
      if (change.ready) {
        appChangeInProgress = false;
        break;
      }

      await Future.delayed(
        Duration(milliseconds: 100),
      );
    }
    appChangeInProgress = false;
  }

  Future<List<SnapApp>> get snapApps async {
    await client.loadAuthorization();
    return await client.apps();
  }

  Future<bool> snapIsIstalled(Snap snap) async {
    final installedSnapApps = await snapApps;
    for (var snapApp in installedSnapApps) {
      if (snap.name == snapApp.snap) return true;
    }
    return false;
  }

  String _currentSnapChannel;
  String get currentSnapChannel => _currentSnapChannel;
  set currentSnapChannel(String value) {
    if (_currentSnapChannel == value) return;
    _currentSnapChannel =
        !value.contains('latest/') && !value.contains('insiders/')
            ? 'latest/' + value
            : value;
    notifyListeners();
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
    }
    notifyListeners();
  }

  Future<List<Snap>> findSnapsByQuery() async {
    return searchQuery.isEmpty ? [] : await client.find(query: _searchQuery);
  }

  Map<SnapApp, Snap> snapAppToSnapMap;

  Future<void> init() async {
    await mapSnaps();
    notifyListeners();
  }

  Future<void> mapSnaps() async {
    final installedSnaps = await snapApps;

    for (var snapApp
        in installedSnaps.where((element) => element.desktopFile != null)) {
      final List<Snap> snapsWithThisName =
          await client.find(name: snapApp.snap);
      snapAppToSnapMap.putIfAbsent(snapApp, () => snapsWithThisName.first);
    }
  }
}
