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
import 'dart:io';

import 'package:appstream/appstream.dart';
import 'package:collection/collection.dart';
import 'package:data_size/data_size.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:packagekit/packagekit.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:software/services/appstream/appstream_utils.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:software/services/packagekit/package_state.dart';

class PackageModel extends SafeChangeNotifier {
  final PackageService _service;

  String? _path;
  String? get path => _path;
  set path(String? path) {
    if (path == _path || path == null) return;
    _path = path;
    notifyListeners();
  }

  final AppstreamComponent? _appstream;
  AppstreamComponent? get appstream => _appstream;

  PackageModel({
    required PackageService service,
    PackageKitPackageId? packageId,
    AppstreamComponent? appstream,
    String? path,
  })  : _service = service,
        _appstream = appstream {
    if (packageId != null) {
      _packageId = packageId;
    } else if (path != null) {
      _path = path;
    } else {
      throw Exception('Either packaged ID or local file path is required');
    }
    if (appstream?.projectLicense != null) {
      _license = appstream!.projectLicense!;
    }
  }

  String? get title => appstream?.localizedName() ?? packageId?.name;

  String? get developerName {
    final devName = appstream?.developerName[
            WidgetsBinding.instance.window.locale.countryCode?.toLowerCase()] ??
        appstream?.developerName['C'];

    return devName ?? appstream?.localizedName();
  }

  String? get releasedAt {
    if (appstream == null ||
        (appstream != null && appstream!.releases.firstOrNull?.date == null)) {
      return null;
    }

    return DateFormat.yMd(Platform.localeName)
        .add_jms()
        .format(appstream!.releases.first.date!.toLocal());
  }

  List<String> get screenshotUrls =>
      appstream?.screenshots
          .map((e) => e.images.firstOrNull?.url)
          .whereType<String>()
          .toList() ??
      [];

  String? get iconUrl => appstream?.icon;

  Future<void> init({bool getUpdateDetail = false}) async {
    await _service.cancelCurrentUpdatesRefresh();
    if (_packageId != null) {
      await _updateDetails();
      if (getUpdateDetail) {
        await _service.getUpdateDetail(model: this);
      }
    } else if (_path != null) {
      await _service.getDetailsAboutLocalPackage(model: this);
    }
    _info = null;
    await checkDependencies();

    return _service.isInstalled(model: this).then(_updatePercentage);
  }

  PackageKitPackageId? _packageId;
  PackageKitPackageId? get packageId => _packageId;
  set packageId(PackageKitPackageId? value) {
    if (value == _packageId) return;
    _packageId = value;
    notifyListeners();
  }

  PackageKitInfo? _info;
  PackageKitInfo? get info => _info;
  set info(PackageKitInfo? value) {
    if (value == _info) return;
    _info = value;
    notifyListeners();
  }

  PackageState _packageState = PackageState.ready;
  PackageState get packageState => _packageState;
  set packageState(PackageState value) {
    if (value == _packageState) return;
    _packageState = value;
    notifyListeners();
  }

  // The group this package belongs to.
  PackageKitGroup? _group;
  PackageKitGroup? get group => _group;
  set group(PackageKitGroup? value) {
    if (value == _group) return;
    _group = value;
    notifyListeners();
  }

  // The multi-line package description in markdown syntax.
  String? _description;
  String get description => _description ?? '';
  set description(String value) {
    if (value == _description) return;
    _description = value;
    notifyListeners();
  }

  /// The one line package summary, e.g. "Clipart for OpenOffice"
  String? _summary;
  String? get summary => _summary;
  set summary(String? value) {
    if (value == null || value == _summary) return;
    _summary = value;
    notifyListeners();
  }

  // The upstream project homepage.
  String? _url;
  String? get url => _url;
  set url(String? value) {
    if (value == null || value == _url) return;
    _url = value;
    notifyListeners();
  }

  /// The license string, e.g. GPLv2+
  String? _license;
  String? get license => appstream?.projectLicense ?? _license;
  set license(String? value) {
    if (value == null || value == _license) return;
    _license = value;
    notifyListeners();
  }

  /// The size of the package in bytes.
  int? _size;
  String? getFormattedSize() => _size?.formatByteSize();
  int get size => _size ?? 0;
  set size(int? value) {
    if (value == null || value == _size) return;
    _size = value;
    notifyListeners();
  }

  /// Progress of the installation/removal
  int _percentage = 0;
  int get percentage => _percentage;
  set percentage(int value) {
    if (value == _percentage) return;
    _percentage = value;
    notifyListeners();
  }

  String _changelog = '';
  String get changelog => _changelog;
  set changelog(String value) {
    if (value == _changelog) return;
    _changelog = value;
    notifyListeners();
  }

  String _issued = '';
  String get issued => _issued;
  set issued(String value) {
    if (value == _issued) return;
    _issued = value;
    notifyListeners();
  }

  bool? _isInstalled;
  bool? get isInstalled => _isInstalled;
  set isInstalled(bool? value) {
    if (value == _isInstalled) return;
    _isInstalled = value;
    notifyListeners();
  }

  bool? _versionChanged;
  bool? get versionChanged => _versionChanged;
  set versionChanged(bool? value) {
    if (value == _versionChanged) return;
    _versionChanged = value;
    notifyListeners();
  }

  Future<void> _updateDetails([void _]) async {
    assert(_packageId != null);
    return _service.getDetails(model: this);
  }

  void _updatePercentage([void _]) {
    if (isInstalled != null) {
      percentage = isInstalled! ? 100 : 0;
    }
  }

  Future<void> install() async {
    if (_path != null) {
      return _service
          .installLocalFile(model: this)
          .then(_updateDetails)
          .then(_updatePercentage);
    } else if (_packageId != null) {
      return _service
          .install(model: this)
          .then(_updateDetails)
          .then(_updatePercentage);
    }
  }

  Future<void> remove() async {
    return _service
        .remove(model: this)
        .then(_updateDetails)
        .then(_updatePercentage);
  }

  Map<PackageKitPackageId, PackageKitInfo>? _dependencies;
  Map<PackageKitPackageId, PackageKitInfo>? get dependencies => _dependencies;
  set dependencies(Map<PackageKitPackageId, PackageKitInfo>? value) {
    if (value == null) return;
    _dependencies = value;
    notifyListeners();
  }

  List<String> get uninstalledDependencyNames => dependencies != null
      ? dependencies!.entries
          .where(
            (element) => element.value == PackageKitInfo.available,
          )
          .map((e) => e.key.name)
          .toList()
      : [];

  Future<void> checkDependencies() async {
    if (_packageId == null) return;
    await _service.getDependencies(model: this);
  }

  @override
  String toString() =>
      'PackageModel($_packageId, $_path, ${describeEnum(_packageState)})';
}
