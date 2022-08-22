import 'dart:async';

import 'package:packagekit/packagekit.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/store_app/common/snap_section.dart';

class ExploreModel extends SafeChangeNotifier {
  final SnapdClient _snapDClient;
  final PackageKitClient _packageKitClient;

  ExploreModel(
    this._snapDClient,
    this._packageKitClient,
  )   : _searchQuery = '',
        sectionNameToSnapsMap = {},
        _errorMessage = '';

  String _errorMessage;
  String get errorMessage => _errorMessage;

  bool get showSectionBannerGrid =>
      searchQuery.isEmpty && sectionNameToSnapsMap.isNotEmpty;

  bool get showTopCarousel =>
      selectedSection == SnapSection.featured ||
      selectedSection == SnapSection.all && searchQuery.isEmpty;

  bool get showErrorPage => errorMessage.isNotEmpty;

  bool get showSearchPage => searchQuery.isNotEmpty;

  bool showTwoCarousels({required double width}) => width > 800;
  bool showThreeCarousels({required double width}) => width > 1500;

  set errorMessage(String value) {
    if (value == _errorMessage) return;
    _errorMessage = value;
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

  SnapSection _selectedSection = SnapSection.all;
  SnapSection get selectedSection => _selectedSection;
  set selectedSection(SnapSection value) {
    if (value == _selectedSection) return;
    _selectedSection = value;
    loadSection(value);
  }

  Future<List<Snap>> findSnapsByQuery() async {
    if (searchQuery.isEmpty) {
      return [];
    } else {
      try {
        return await _snapDClient.find(
          query: _searchQuery,
          section:
              selectedSection == SnapSection.all ? null : selectedSection.title,
        );
      } on SnapdException catch (e) {
        errorMessage = e.message.toString();
        return [];
      }
    }
  }

  Future<List<Snap>> findSnapsBySection({SnapSection? section}) async {
    if (section == null) return [];
    try {
      return (await _snapDClient.find(
        section: section == SnapSection.all
            ? SnapSection.featured.title
            : section.title,
      ));
    } on SnapdException catch (e) {
      errorMessage = e.toString();
      return [];
    }
  }

  Map<String, List<Snap>> sectionNameToSnapsMap;
  Future<void> loadSection(SnapSection section) async {
    List<Snap> sectionList = [];
    for (final snap in await findSnapsBySection(
      section: section,
    )) {
      sectionList.add(snap);
    }
    sectionNameToSnapsMap.putIfAbsent(section.title, () => sectionList);
    notifyListeners();
  }

  Future<List<PackageKitPackageId>> findPackageKitPackageIds({
    Set<PackageKitFilter> filter = const {},
  }) async {
    if (searchQuery.isEmpty) return [];
    final List<PackageKitPackageId> ids = [];
    final transaction = await _packageKitClient.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        final id = event.packageId;
        ids.add(id);
      } else if (event is PackageKitErrorCodeEvent) {
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.searchNames(
      [searchQuery],
      filter: filter,
    );
    await completer.future;

    return ids;
  }
}
