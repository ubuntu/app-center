/*
 * Copyright (C) 2022 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:async';

import 'package:packagekit/packagekit.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/package_service.dart';
import 'package:software/store_app/common/snap_section.dart';

class ExploreModel extends SafeChangeNotifier {
  final SnapdClient _snapDClient;
  final PackageService _packageService;
  int _snapAmount = 40;
  int get snapAmount => _snapAmount;
  set snapAmount(int value) {
    if (value == _snapAmount) return;
    _snapAmount = value;
    notifyListeners();
  }

  Snap? _selectedSnap;
  Snap? get selectedSnap => _selectedSnap;
  set selectedSnap(Snap? snap) {
    if (snap == _selectedSnap) return;
    _selectedSnap = snap;
    notifyListeners();
  }

  PackageKitPackageId? _selectedPackage;
  PackageKitPackageId? get selectedPackage => _selectedPackage;
  set selectedPackage(PackageKitPackageId? id) {
    if (id == _selectedPackage) return;
    _selectedPackage = id;
    notifyListeners();
  }

  ExploreModel(
    this._snapDClient,
    this._packageService,
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
  }) async =>
      _packageService.findPackageKitPackageIds(
        searchQuery: searchQuery,
        filter: filter,
      );

  void clearSelection() {
    selectedSnap = null;
    selectedPackage = null;
  }
}
