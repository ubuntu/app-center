import 'dart:async';

import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/app_change_service.dart';
import 'package:software/store_app/common/snap_section.dart';

class AppsModel extends SafeChangeNotifier {
  final SnapdClient client;
  final AppChangeService _appChangeService;
  StreamSubscription<bool>? _snapChangesSub;

  final Map<SnapSection, bool> filters = {
    for (final snapSection in SnapSection.values)
      snapSection: snapSection == SnapSection.development ? true : false,
  };

  AppsModel(
    this.client,
    this._appChangeService,
  )   : _localSnaps = [],
        _searchActive = false,
        _searchQuery = '',
        _exploreMode = true,
        sectionNameToSnapsMap = {};

  Future<void> init() async {
    await _loadLocalSnaps();
    _snapChangesSub = _appChangeService.snapChangesInserted.listen((_) async {
      await _loadLocalSnaps();
      notifyListeners();
    });
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _snapChangesSub?.cancel();
    super.dispose();
  }

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

  final List<Snap> _localSnaps;
  List<Snap> get localSnaps => _localSnaps;
  Future<void> _loadLocalSnaps() async {
    await client.loadAuthorization();
    final localSnaps = <Snap>[];
    final snapApps = (await client.getApps());
    for (var snapApp in snapApps.where(
      (snapApp) => snapApp.desktopFile != null && snapApp.snap != null,
    )) {
      final localSnap = await client.getSnap(snapApp.snap!);
      localSnaps.add(localSnap);
    }
    _localSnaps.clear();
    _localSnaps.addAll(localSnaps);
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
}
