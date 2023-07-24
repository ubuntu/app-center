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

import 'package:appstream/appstream.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/app/common/app_finding.dart';
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/snap/snap_section.dart';
import 'package:software/services/appstream/appstream_service.dart';
import 'package:software/services/appstream/appstream_utils.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:software/services/snap_service.dart';

class ExploreModel extends SafeChangeNotifier {
  final AppstreamService _appstreamService;
  final SnapService _snapService;
  final PackageService _packageService;
  StreamSubscription<SnapSection>? _sectionsChangedSub;

  Future<void> init() async {
    _enabledAppFormats.add(AppFormat.snap);
    _loadStartPageSnaps(SnapSection.all);
    _sectionsChangedSub = _snapService.sectionsChanged.listen(
      (section) {
        _loadStartPageSnaps(section);
        notifyListeners();
      },
    );

    await _packageService.initialized;
    if (_packageService.isAvailable) {
      _appstreamService.init().then((_) {
        _enabledAppFormats.add(AppFormat.packageKit);
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    _sectionsChangedSub?.cancel();
    super.dispose();
  }

  ExploreModel(
    this._appstreamService,
    this._snapService,
    this._packageService, [
    this._errorMessage,
  ]);

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  set errorMessage(String? value) {
    if (value == _errorMessage) return;
    _errorMessage = value;
    notifyListeners();
  }

  bool get showErrorPage => errorMessage != null && errorMessage!.isNotEmpty;

  bool get showSearchPage => searchQuery != null && searchQuery!.isNotEmpty;

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void setSearchQuery(String? value) {
    errorMessage = '';
    if (value == null || value == _searchQuery) return;
    _searchQuery = value;
    notifyListeners();
  }

  SnapSection? _selectedSection = SnapSection.all;
  SnapSection? get selectedSection => _selectedSection;
  void setSelectedSection(SnapSection? value) {
    if (value == null || value == _selectedSection) return;
    _selectedSection = value;
    notifyListeners();
  }

  final startPageApps = <SnapSection, List<AppFinding>>{};
  var startPageAppsChanged = 0;

  AppFormat _appFormat = AppFormat.snap;
  AppFormat get appFormat => _appFormat;
  void setAppFormat(AppFormat value) {
    if (_appFormat == value) return;
    _appFormat = value;
    notifyListeners();
  }

  final Set<AppFormat> _enabledAppFormats = {};
  Set<AppFormat> get enabledAppFormats => Set.from(_enabledAppFormats);

  Future<List<Snap>> _findSnapsByQuery(String searchQuery) async {
    try {
      return await _snapService.findSnapsByQuery(
        searchQuery: searchQuery,
        sectionName:
            selectedSection == null || selectedSection == SnapSection.all
                ? null
                : selectedSection!.title,
      );
    } on SnapdException catch (e) {
      errorMessage = e.message.toString();
      return [];
    }
  }

  Future<Snap?> _findSnapByName(String name) async {
    try {
      return await _snapService.findSnapByName(name);
    } on SnapdException catch (e) {
      errorMessage = e.message.toString();
      return null;
    }
  }

  Future<List<AppstreamComponent>> _findAppstreamComponents(
    String searchQuery,
  ) async =>
      _appstreamService.search(searchQuery);

  Map<String, AppFinding>? _snapSearchResult;
  Map<String, AppFinding>? get snapSearchResult => _snapSearchResult;
  set snapSearchResult(Map<String, AppFinding>? value) {
    _snapSearchResult = value;
    notifyListeners();
  }

  Map<String, AppFinding>? _appStreamSearchResult;
  Map<String, AppFinding>? get appStreamSearchResult => _appStreamSearchResult;
  set appStreamSearchResult(Map<String, AppFinding>? value) {
    _appStreamSearchResult = value;
    notifyListeners();
  }

  void _loadStartPageSnaps(SnapSection section) {
    if (!_snapService.sectionNameToSnapsMap.containsKey(section)) return;
    startPageApps[section] = _snapService.sectionNameToSnapsMap[section]!
        .map((s) => AppFinding(snap: s))
        .toList();
    startPageAppsChanged++;
  }

  Future<void> searchByPublisher(String username) async {
    setSearchQuery(username);

    snapSearchResult = null;

    final Map<String, AppFinding> appFindings = {};
    if (searchQuery != null && searchQuery != '') {
      final snaps = await _findSnapsByQuery(searchQuery!);
      final publishersSnaps =
          snaps.where((snap) => snap.publisher?.username == username);

      for (final snap in publishersSnaps) {
        appFindings.putIfAbsent(
          snap.name,
          () => AppFinding(snap: snap),
        );
      }

      snapSearchResult = appFindings;
    }
  }

  Future<void> searchSnaps() async {
    snapSearchResult = null;

    final Map<String, AppFinding> appFindings = {};
    if (searchQuery != null && searchQuery != '') {
      final snaps = await _findSnapsByQuery(searchQuery!);
      final exactMatch = await _findSnapByName(searchQuery!);
      if (exactMatch != null) {
        snaps.insert(0, exactMatch);
      }
      for (final snap in snaps) {
        appFindings.putIfAbsent(
          snap.name,
          () => AppFinding(snap: snap),
        );
      }

      snapSearchResult = appFindings;
    }
  }

  Future<void> searchAppStream() async {
    appStreamSearchResult = null;

    final Map<String, AppFinding> appFindings = {};

    if ((searchQuery != null && searchQuery != '')) {
      final components = await _findAppstreamComponents(searchQuery!);
      for (final component in components) {
        appFindings.putIfAbsent(
          component.localizedName(),
          () => AppFinding(appstream: component),
        );
      }

      appStreamSearchResult = appFindings;
    }
  }
}
