import 'dart:async';

import 'package:packagekit/packagekit.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:software/package_state.dart';
import 'package:software/services/package_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class PackageModel extends SafeChangeNotifier {
  final PackageService _service;
  StreamSubscription<PackageState>? _packageStateSub;
  StreamSubscription<String>? _summarySub;
  StreamSubscription<String>? _urlSub;
  StreamSubscription<String>? _licenseSub;
  StreamSubscription<String>? _sizeSub;
  StreamSubscription<String>? _descriptionSub;
  StreamSubscription<String>? _changeLogSub;
  StreamSubscription<String>? _issuedSub;
  StreamSubscription<PackageKitGroup>? _groupController;

  PackageModel()
      : _percentage = 0,
        _status = '',
        _license = '',
        _size = '',
        _summary = '',
        _url = '',
        _errorMessage = '',
        _service = getService<PackageService>();

  Future<void> init({
    bool update = false,
    required PackageKitPackageId packageId,
  }) async {
    _service.getDetails(packageId: packageId);
    if (update) {
      _service.getUpdateDetail(packageId: packageId);
    }
    _packageStateSub = _service.packageState.listen((event) {
      packageState = event;
    });

    _summarySub = _service.summary.listen((event) {
      summary = event;
    });
    _urlSub = _service.url.listen((event) {
      url = event;
    });
    _licenseSub = _service.license.listen((event) {
      license = event;
    });
    _sizeSub = _service.size.listen((event) {
      size = event;
    });
    _descriptionSub = _service.description.listen((event) {
      description = event;
    });
    _changeLogSub = _service.changelog.listen((event) {
      changelog = event;
    });
    _issuedSub = _service.issued.listen((event) {
      issued = event;
    });
    _groupController = _service.group.listen((event) {
      group = event;
    });
  }

  @override
  void dispose() {
    _packageStateSub?.cancel();
    _summarySub?.cancel();
    _urlSub?.cancel();
    _licenseSub?.cancel();
    _sizeSub?.cancel();
    _descriptionSub?.cancel();
    _changeLogSub?.cancel();
    _issuedSub?.cancel();
    _groupController?.cancel();
    super.dispose();
  }

  PackageState? _packageState = PackageState.ready;
  PackageState? get packageState => _packageState;
  set packageState(PackageState? value) {
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
  String _summary;
  String get summary => _summary;
  set summary(String value) {
    if (value == _summary) return;
    _summary = value;
    notifyListeners();
  }

  // The upstream project homepage.
  String _url;
  String get url => _url;
  set url(String value) {
    if (value == _url) return;
    _url = value;
    notifyListeners();
  }

  /// The license string, e.g. GPLv2+
  String _license;
  String get license => _license;
  set license(String value) {
    if (value == _license) return;
    _license = value;
    notifyListeners();
  }

  /// The size of the package in bytes.
  String _size;
  String get size => _size;
  set size(String value) {
    if (value == _size) return;
    _size = value;
    notifyListeners();
  }

  /// Progress of the installation/removal
  num _percentage;
  num get percentage => _percentage;
  set percentage(num value) {
    if (value == _percentage) return;
    _percentage = value;
    notifyListeners();
  }

  /// Status of the transaction
  String _status;
  String get status => _status;
  set status(String value) {
    if (value == _status) return;
    _status = value;
    notifyListeners();
  }

  bool isInstalled({required PackageKitPackageId packageId}) =>
      _service.isInstalled(packageId: packageId);

  String _errorMessage;
  String get errorMessage => _errorMessage;
  set errorMessage(String value) {
    if (value == _errorMessage) return;
    _errorMessage = value;
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

  /// Removes with package with [packageId]
  Future<void> remove({required PackageKitPackageId packageId}) async =>
      _service.remove(packageId: packageId);

  /// Installs with package with [packageId]
  Future<void> install({required PackageKitPackageId packageId}) async =>
      _service.install(packageId: packageId);
}
