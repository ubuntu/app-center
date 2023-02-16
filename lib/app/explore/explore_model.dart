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
import 'package:collection/collection.dart';
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
    _selectedAppFormats.add(AppFormat.snap);
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
        _selectedAppFormats.add(AppFormat.packageKit);
        notifyListeners();
      }).then(
        (_) => Future.forEach<SnapSection>(
          startPageApps.keys,
          _loadStartPageAppstreamComponents,
        ),
      );
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

  final Set<AppFormat> _selectedAppFormats = {};
  Set<AppFormat> get selectedAppFormats => Set.from(_selectedAppFormats);
  final Set<AppFormat> _enabledAppFormats = {};
  Set<AppFormat> get enabledAppFormats => Set.from(_enabledAppFormats);
  void handleAppFormat(AppFormat appFormat) {
    if (!_selectedAppFormats.contains(appFormat)) {
      _selectedAppFormats.add(appFormat);
    } else {
      if (_selectedAppFormats.length < 2) return;
      _selectedAppFormats.remove(appFormat);
    }
    notifyListeners();
  }

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

  Map<String, AppFinding>? _searchResult;
  Map<String, AppFinding>? get searchResult => _searchResult;
  set searchResult(Map<String, AppFinding>? value) {
    _searchResult = value;
    notifyListeners();
  }

  void _loadStartPageSnaps(SnapSection section) {
    if (!_snapService.sectionNameToSnapsMap.containsKey(section)) return;
    startPageApps[section] = _snapService.sectionNameToSnapsMap[section]!
        .map((s) => AppFinding(snap: s))
        .toList();
    startPageAppsChanged++;
  }

  Future<AppstreamComponent?> _getAppstreamComponentFromSnap(Snap snap) =>
      _findAppstreamComponents(snap.name).then(
        (components) =>
            components.firstWhereOrNull((e) => e.package == snap.name),
      );

  Future<void> _loadStartPageAppstreamComponents(
    SnapSection section,
  ) async {
    if (!startPageApps.containsKey(section)) return;
    for (var i = 0; i < startPageApps[section]!.length; i++) {
      final appstreamComponent = await _getAppstreamComponentFromSnap(
        startPageApps[section]![i].snap!,
      );
      await Future.delayed(const Duration(milliseconds: 2));
      if (appstreamComponent != null) {
        startPageApps[section]![i] = AppFinding(
          snap: startPageApps[section]![i].snap,
          appstream: appstreamComponent,
        );
      }
    }
    startPageAppsChanged++;
    notifyListeners();
  }

  Future<void> search() async {
    searchResult = null;

    final Map<String, AppFinding> appFindings = {};
    if (searchQuery != null && searchQuery != '') {
      if (selectedAppFormats
          .containsAll([AppFormat.snap, AppFormat.packageKit])) {
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

        final components = await _findAppstreamComponents(searchQuery!);
        for (final component in components) {
          final snap =
              snaps.firstWhereOrNull((snap) => snap.name == component.package);
          if (snap == null) {
            appFindings.putIfAbsent(
              component.localizedName(),
              () => AppFinding(appstream: component),
            );
          } else {
            appFindings.update(
              snap.name,
              (value) => AppFinding(
                snap: snap,
                appstream: component,
              ),
            );
          }
        }
      } else if (selectedAppFormats.contains(AppFormat.snap) &&
          !(selectedAppFormats.contains(AppFormat.packageKit))) {
        final snaps = await _findSnapsByQuery(searchQuery!);
        for (final snap in snaps) {
          appFindings.putIfAbsent(
            snap.name,
            () => AppFinding(snap: snap),
          );
        }
      } else if (!selectedAppFormats.contains(AppFormat.snap) &&
          (selectedAppFormats.contains(AppFormat.packageKit))) {
        final components = await _findAppstreamComponents(searchQuery!);
        for (final component in components) {
          appFindings.putIfAbsent(
            component.localizedName(),
            () => AppFinding(appstream: component),
          );
        }
      }

      searchResult = appFindings;
    }
  }
}
