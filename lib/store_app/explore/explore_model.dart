import 'dart:async';

import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/store_app/common/snap_section.dart';

class ExploreModel extends SafeChangeNotifier {
  final SnapdClient client;

  Future<void> init() async {
    await _loadSection(_selectedSection);
    notifyListeners();
  }

  ExploreModel(
    this.client,
  )   : _searchQuery = '',
        _exploreMode = true,
        sectionNameToSnapsMap = {},
        _errorMessage = '';

  String _errorMessage;
  String get errorMessage => _errorMessage;

  bool showTwoCarousels({required double width}) => width > 800;
  bool showThreeCarousels({required double width}) => width > 1500;

  set errorMessage(String value) {
    if (value == _errorMessage) return;
    _errorMessage = value;
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
    errorMessage = '';
    if (value == _searchQuery) return;
    _searchQuery = value;
    notifyListeners();
  }

  SnapSection _selectedSection = SnapSection.featured;
  SnapSection get selectedSection => _selectedSection;
  set selectedSection(SnapSection value) {
    if (value == _selectedSection) return;
    _selectedSection = value;
  }

  Future<List<Snap>> findSnapsByQuery() async {
    if (searchQuery.isEmpty) {
      return [];
    } else {
      try {
        return await client.find(query: _searchQuery);
      } on SnapdException catch (e) {
        errorMessage = e.message.toString();
        return [];
      }
    }
  }

  Future<List<Snap>> findSnapsBySection({String? section}) async {
    if (section == null) return [];
    try {
      return (await client.find(section: section));
    } on SnapdException catch (e) {
      errorMessage = e.toString();
      return [];
    }
  }

  Map<String, List<Snap>> sectionNameToSnapsMap;
  Future<void> _loadSection(SnapSection section) async {
    List<Snap> sectionList = [];
    for (final snap in await findSnapsBySection(section: section.title)) {
      sectionList.add(snap);
    }
    sectionNameToSnapsMap.putIfAbsent(section.title, () => sectionList);
  }
}
