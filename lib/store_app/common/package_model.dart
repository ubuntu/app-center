import 'dart:async';

import 'package:packagekit/packagekit.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class PackageModel extends SafeChangeNotifier {
  PackageModel(
    this._client, {
    required this.packageId,
    required this.installedId,
  })  : _progress = 0,
        _status = '',
        _license = '',
        _size = 0,
        _summary = '',
        _url = '' {
    _client.connect();
  }

  final PackageKitClient _client;

  Future<void> init() async {
    await _getDetails();
    await _checkForUpdate();
    processing = false;
    notifyListeners();
  }

  /// The ID of the package.
  final PackageKitPackageId packageId;
  set packageId(PackageKitPackageId? value) {
    if (value == packageId) return;
    packageId = value;
    notifyListeners();
  }

  /// The ID of the package if it is installed, only relevant for updates.
  final PackageKitPackageId installedId;
  set installedId(PackageKitPackageId? value) {
    if (value == installedId) return;
    installedId = value;
    notifyListeners();
  }

  // Convenience getters
  String get version => packageId.version;
  String get name => packageId.name;
  String get arch => packageId.arch;
  String get data => packageId.data;

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
  int _size;
  int get size => _size;
  set size(int value) {
    if (value == _size) return;
    _size = value;
    notifyListeners();
  }

  /// Progress of the installation/removal
  num _progress;
  num get progress => _progress;

  set progress(num value) {
    if (value == _progress) return;
    _progress = value;
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

  bool processing = true;

  /// Removes with package with [packageId]
  Future<void> remove() async {
    final removeTransaction = await _client.createTransaction();
    final removeCompleter = Completer();
    removeTransaction.events.listen((event) {
      processing = true;
      if (event is PackageKitPackageEvent) {
        // processing = event.info == PackageKitInfo.removing;
      } else if (event is PackageKitItemProgressEvent) {
        progress = event.percentage;
      } else if (event is PackageKitErrorCodeEvent) {
      } else if (event is PackageKitFinishedEvent) {
        removeCompleter.complete();
        packageIsInstalled = false;
      }
      notifyListeners();
    });
    await removeTransaction.removePackages([packageId]);
    await removeCompleter.future;
    processing = false;
    notifyListeners();
  }

  /// Installs with package with [packageId]
  Future<void> install() async {
    final installTransaction = await _client.createTransaction();
    final installCompleter = Completer();
    installTransaction.events.listen((event) {
      processing = true;
      if (event is PackageKitPackageEvent) {
        // processing = event.info == PackageKitInfo.installing;
      } else if (event is PackageKitItemProgressEvent) {
        progress = event.percentage;
      } else if (event is PackageKitFinishedEvent) {
        installCompleter.complete();
        packageIsInstalled = true;
      }
      notifyListeners();
    });
    await installTransaction.installPackages([packageId]);
    await installCompleter.future;
    processing = false;
    notifyListeners();
  }

  Future<void> _getDetails() async {
    var installTransaction = await _client.createTransaction();
    var detailsCompleter = Completer();
    installTransaction.events.listen((event) {
      if (event is PackageKitDetailsEvent) {
        summary = event.summary;
        url = event.url;
        license = event.license;
        size = event.size;
        description = event.description;
        group = event.group;
        url = event.url;
      } else if (event is PackageKitFinishedEvent) {
        detailsCompleter.complete();
      }
      notifyListeners();
    });
    await installTransaction.getDetails([packageId]);
    await detailsCompleter.future;
  }

  bool packageIsInstalled = true;

  Future<void> update() async {
    final updatePackagesTransaction = await _client.createTransaction();
    final updatePackagesCompleter = Completer();
    processing = true;
    updatePackagesTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        // print('[${event.packageId.name}] ${event.info}');
      } else if (event is PackageKitItemProgressEvent) {
        // print('[${event.packageId.name}] ${event.status} ${event.percentage}%');
      } else if (event is PackageKitErrorCodeEvent) {
        // print('${event.code}: ${event.details}');
      } else if (event is PackageKitFinishedEvent) {
        updatePackagesCompleter.complete();
        processing = false;
      }
    });
    await updatePackagesTransaction.updatePackages([packageId]);
    await updatePackagesCompleter.future;
    notifyListeners();
  }

  bool updateAvailable = false;
  Future<void> _checkForUpdate() async {
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        if (event.packageId == packageId) {
          updateAvailable = true;
        }
      } else if (event is PackageKitErrorCodeEvent) {
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
      notifyListeners();
    });
    await transaction.getUpdates();
    await completer.future;
    notifyListeners();
  }
}
