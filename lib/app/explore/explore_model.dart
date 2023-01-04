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
import 'dart:math';

import 'package:appstream/appstream.dart';
import 'package:collection/collection.dart';
import 'package:packagekit/packagekit.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/app/common/app_finding.dart';
import 'package:software/services/appstream/appstream_utils.dart';
import 'package:software/services/appstream/appstream_service.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:software/services/snap_service.dart';
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/snap/snap_section.dart';
import 'package:software/app/common/snap/snap_sort.dart';
import 'package:software/services/packagekit/updates_state.dart';

class ExploreModel extends SafeChangeNotifier {
  final AppstreamService _appstreamService;
  final SnapService _snapService;
  final PackageService _packageService;
  StreamSubscription<UpdatesState>? _updatesStateSub;
  StreamSubscription<bool>? _sectionsChangedSub;

  Future<void> init() async {
    _enabledAppFormats.add(AppFormat.snap);
    _selectedAppFormats.add(AppFormat.snap);
    _snapService.initialized.then(
      (value) => _sectionsChangedSub =
          _snapService.sectionsChanged.listen((_) => notifyListeners()),
    );

    if (_packageService.isAvailable) {
      _appstreamService.init().then((_) {
        _enabledAppFormats.add(AppFormat.packageKit);
        _selectedAppFormats.add(AppFormat.packageKit);
        notifyListeners();
      });
      _updatesState = _packageService.lastUpdatesState;
      _updatesStateSub = _packageService.updatesState.listen((event) {
        updatesState = event;
      });
    }
  }

  @override
  void dispose() {
    _updatesStateSub?.cancel();
    _sectionsChangedSub?.cancel();
    super.dispose();
  }

  bool get packageKitReady =>
      updatesState != null &&
      updatesState != UpdatesState.updating &&
      updatesState != UpdatesState.checkingForUpdates;

  UpdatesState? _updatesState;
  UpdatesState? get updatesState => _updatesState;
  set updatesState(UpdatesState? value) {
    if (value == _updatesState) return;
    _updatesState = value;
    notifyListeners();
  }

  ExploreModel(
    this._appstreamService,
    this._snapService,
    this._packageService, [
    this._errorMessage,
  ]) : _searchQuery = '';

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  set errorMessage(String? value) {
    if (value == _errorMessage) return;
    _errorMessage = value;
    notifyListeners();
  }

  bool get showSectionBannerGrid =>
      searchQuery.isEmpty && sectionNameToSnapsMap.isNotEmpty;

  bool get showStartPage => selectedSection == SnapSection.all;

  bool get showErrorPage => errorMessage != null && errorMessage!.isNotEmpty;

  bool get showSearchPage => searchQuery.isNotEmpty;

  bool showTwoCarousels({required double width}) => width > 800;
  bool showThreeCarousels({required double width}) => width > 1500;

  String _searchQuery;
  String get searchQuery => _searchQuery;
  void setSearchQuery(String value) {
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
    notifyListeners();
  }

  Future<List<Snap>> findSnapsByQuery() async {
    if (searchQuery.isEmpty) {
      return [];
    } else {
      try {
        return await _snapService.findSnapsByQuery(
          searchQuery: searchQuery,
          sectionName:
              selectedSection == SnapSection.all ? null : selectedSection.title,
        );
      } on SnapdException catch (e) {
        errorMessage = e.message.toString();
        return [];
      }
    }
  }

  Map<SnapSection, List<Snap>> get sectionNameToSnapsMap =>
      _snapService.sectionNameToSnapsMap;

  Future<List<AppstreamComponent>> findAppstreamComponents() async =>
      _appstreamService.search(searchQuery);

  AppFormat _appFormat = AppFormat.snap;
  AppFormat get appFormat => _appFormat;
  void setAppFormat(AppFormat value) {
    if (value == _appFormat) return;
    _appFormat = value;
    notifyListeners();
  }

  SnapSort _snapSort = SnapSort.name;
  SnapSort get snapSort => _snapSort;
  void setSnapSort(SnapSort value) {
    if (value == _snapSort) return;
    _snapSort = value;
    notifyListeners();
  }

  PackageKitGroup? _packageKitGroup;
  PackageKitGroup? get packageKitGroup => _packageKitGroup;
  void setPackageKitGroup(PackageKitGroup? value) {
    if (value == _packageKitGroup) return;
    _packageKitGroup = value;
    notifyListeners();
  }

  final Set<PackageKitFilter> _packageKitFilters = {};
  Set<PackageKitFilter> get packageKitFilters => _packageKitFilters;
  void handleFilter(bool value, PackageKitFilter filter) {
    if (value) {
      _packageKitFilters.add(filter);
    } else {
      _packageKitFilters.remove(filter);
    }
    notifyListeners();
  }

  final Set<AppFormat> _selectedAppFormats = {};
  Set<AppFormat> get selectedAppFormats => _selectedAppFormats;
  final Set<AppFormat> _enabledAppFormats = {};
  Set<AppFormat> get enabledAppFormats => _enabledAppFormats;
  void handleAppFormat(AppFormat appFormat) {
    if (!_selectedAppFormats.contains(appFormat)) {
      _selectedAppFormats.add(appFormat);
    } else {
      if (_selectedAppFormats.length < 2) return;
      _selectedAppFormats.remove(appFormat);
    }
    notifyListeners();
  }

  // TODO: get real rating from backend
  Future<Map<String, AppFinding>> search() async {
    final Map<String, AppFinding> appFindings = {};

    if (selectedAppFormats
        .containsAll([AppFormat.snap, AppFormat.packageKit])) {
      final snaps = await findSnapsByQuery();
      for (final snap in snaps) {
        appFindings.putIfAbsent(
          snap.name,
          () => AppFinding(
            snap: snap,
            rating: fakeRating(),
            totalRatings: fakeTotalRatings(),
          ),
        );
      }

      final components = await findAppstreamComponents();
      for (final component in components) {
        final snap =
            snaps.firstWhereOrNull((snap) => snap.name == component.package);
        if (snap == null) {
          appFindings.putIfAbsent(
            component.localizedName(),
            () {
              return AppFinding(
                appstream: component,
                rating: fakeRating(),
                totalRatings: fakeTotalRatings(),
              );
            },
          );
        } else {
          appFindings.update(
            snap.name,
            (value) => AppFinding(
              snap: snap,
              appstream: component,
              rating: fakeRating(),
              totalRatings: fakeTotalRatings(),
            ),
          );
        }
      }
    } else if (selectedAppFormats.contains(AppFormat.snap) &&
        !(selectedAppFormats.contains(AppFormat.packageKit))) {
      final snaps = await findSnapsByQuery();
      for (final snap in snaps) {
        appFindings.putIfAbsent(
          snap.name,
          () => AppFinding(
            snap: snap,
            rating: fakeRating(),
            totalRatings: fakeTotalRatings(),
          ),
        );
      }
    } else if (!selectedAppFormats.contains(AppFormat.snap) &&
        (selectedAppFormats.contains(AppFormat.packageKit))) {
      final components = await findAppstreamComponents();
      for (final component in components) {
        appFindings.putIfAbsent(
          component.localizedName(),
          () => AppFinding(
            appstream: component,
            rating: fakeRating(),
            totalRatings: fakeTotalRatings(),
          ),
        );
      }
    }

    return appFindings;
  }

  int fakeTotalRatings() => Random().nextInt(3000);

  double fakeRating() => 4.5;
}
