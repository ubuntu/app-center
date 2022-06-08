import 'dart:async';
import 'dart:io';

import 'package:packagekit/packagekit.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class DebInstallerModel extends SafeChangeNotifier {
  DebInstallerModel(this._client, {required this.path})
      : _progress = 0,
        _status = '',
        _license = '',
        _size = 0,
        _summary = '',
        _url = '',
        _installedPackageIds = {};

  final PackageKitClient _client;
  final String path;

  Future<void> init() async {
    await _getInstalledPackages();
    await _getDetailsAboutLocalPackage();
    progress = packageIsInstalled ? 1 : 0;
    notifyListeners();
  }

  /// The ID of the local package.
  PackageKitPackageId? _packageId;
  PackageKitPackageId? get packageId => _packageId;
  set packageId(PackageKitPackageId? value) {
    if (value == _packageId) return;
    _packageId = value;
    notifyListeners();
  }

  // Convenience getters
  String get version => _packageId != null ? _packageId!.version : '';
  String get name => _packageId != null ? _packageId!.name : '';
  String get arch => _packageId != null ? _packageId!.arch : '';
  String get data => _packageId != null ? _packageId!.data : '';

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
  num get progress {
    return packageIsInstalled ? (1 - (_progress / 100)) : (_progress / 100);
  }

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

  /// Load all installed packageIds into this set to check
  /// if the package is already installed
  final Set<PackageKitPackageId> _installedPackageIds;
  List<PackageKitPackageId> get installedPackages =>
      _installedPackageIds.toList();
  bool get packageIsInstalled => _installedPackageIds.contains(packageId);

  /// Install the local package from [path]
  Future<void> installLocalFile() async {
    if (path.isEmpty || !(await File(path).exists())) return;
    final installTransaction = await _client.createTransaction();
    final installCompleter = Completer();
    installTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        status = '[${event.packageId.name}] ${event.info}';
      } else if (event is PackageKitItemProgressEvent) {
        progress = event.percentage;
      } else if (event is PackageKitFinishedEvent) {
        installCompleter.complete();
      }
    });
    await installTransaction.installFiles([path]);
    await installCompleter.future;
    await init();
  }

  /// Removes with package with [packageId]
  Future<void> remove() async {
    if (packageId == null) return;
    final removeTransaction = await _client.createTransaction();
    final removeCompleter = Completer();
    removeTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        status = '[${event.packageId.name}] ${event.info}';
      } else if (event is PackageKitItemProgressEvent) {
        progress = event.percentage;
      } else if (event is PackageKitErrorCodeEvent) {
      } else if (event is PackageKitFinishedEvent) {
        removeCompleter.complete();
      }
    });
    await removeTransaction.removePackages([packageId!]);
    await removeCompleter.future;
    await init();
  }

  /// Finds the [packageId] from [path] and sets info fields
  Future<void> _getDetailsAboutLocalPackage() async {
    if (path.isEmpty || !(await File(path).exists())) return;
    final transaction = await _client.createTransaction();
    final detailsCompleter = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitDetailsEvent) {
        packageId = event.packageId;
        summary = event.summary;
        url = event.url;
        license = event.license;
        size = event.size;
        group = event.group;
        description = event.description;
      } else if (event is PackageKitFinishedEvent) {
        detailsCompleter.complete();
      }
    });
    await transaction.getDetailsLocal([path]);
    await detailsCompleter.future;
  }

  /// Fills [_installedPackageIds] with the ids of all installed applications.
  Future<void> _getInstalledPackages() async {
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((packageKitEvent) {
      if (packageKitEvent is PackageKitPackageEvent) {
        _installedPackageIds.add(packageKitEvent.packageId);
      } else if (packageKitEvent is PackageKitErrorCodeEvent) {
      } else if (packageKitEvent is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.getPackages(
      filter: {PackageKitFilter.installed, PackageKitFilter.application},
    );
    await completer.future;
  }
}
