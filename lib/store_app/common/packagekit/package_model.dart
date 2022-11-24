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
import 'package:flutter/foundation.dart';
import 'package:packagekit/packagekit.dart';
import 'package:software/appstream_utils.dart';
import 'package:software/package_state.dart';
import 'package:software/services/package_service.dart';
import 'package:software/store_app/common/app_model.dart';

class PackageModel extends AppModel {
  final PackageService _service;

  String? _path;
  String? get path => _path;

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

  List<String> get screenshotUrls => <String>[];

  String? get iconUrl => appstream?.remoteIcon;

  Future<void> init({bool update = false}) async {
    if (_packageId != null) {
      await _updateDetails();
      if (update) {
        await _service.getUpdateDetail(model: this);
      }
    } else if (_path != null) {
      await _service.getDetailsAboutLocalPackage(model: this);
    }
    _info = null;

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
  String _summary = '';
  String get summary => _summary;
  set summary(String value) {
    if (value == _summary) return;
    _summary = value;
    notifyListeners();
  }

  // The upstream project homepage.
  String _url = '';
  String get url => _url;
  set url(String value) {
    if (value == _url) return;
    _url = value;
    notifyListeners();
  }

  /// The license string, e.g. GPLv2+
  String _license = '';
  String get license => _license;
  set license(String value) {
    if (value.isEmpty ||
        value == _license ||
        (_license.isNotEmpty && value == 'unknown')) return;
    _license = value;
    notifyListeners();
  }

  /// The size of the package in bytes.
  int _size = 0;
  int get size => _size;
  set size(int value) {
    if (value == _size) return;
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

  @override
  String toString() =>
      'PackageModel($_packageId, $_path, ${describeEnum(_packageState)})';
}
