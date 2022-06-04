import 'dart:async';

import 'package:packagekit/packagekit.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class DebInstallerModel extends SafeChangeNotifier {
  DebInstallerModel(this.path, this.client)
      : _progress = 0,
        _installationComplete = false,
        _removeComplete = false,
        _status = '',
        _appIsInstalled = false,
        _license = '',
        _size = 0,
        _summary = '',
        _url = '';

  final PackageKitClient client;
  final String path;

  int _progress;
  int get progress => _progress;
  set progress(int value) {
    if (value == _progress) return;
    _progress = value;
    notifyListeners();
  }

  String _status;
  String get status => _status;
  set status(String value) {
    if (value == _status) return;
    _status = value;
    notifyListeners();
  }

  bool _appIsInstalled;
  bool get appIsInstalled => _appIsInstalled;
  set appIsInstalled(bool value) {
    if (value == _appIsInstalled) return;
    _appIsInstalled = value;
    notifyListeners();
  }

  bool _installationComplete;
  bool get installationComplete => _installationComplete;
  set installationComplete(bool value) {
    if (value == _installationComplete) return;
    _installationComplete = value;
    notifyListeners();
  }

  bool _removeComplete;
  bool get removeComplete => _removeComplete;
  set removeComplete(bool value) {
    if (value == _removeComplete) return;
    _removeComplete = value;
    notifyListeners();
  }

  Future<void> install() async {
    final paths = [path];

    final installTransaction = await client.createTransaction();
    final installCompleter = Completer();
    installTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        status = '[${event.packageId.name}] ${event.info}';
      } else if (event is PackageKitItemProgressEvent) {
        progress = event.percentage;
      } else if (event is PackageKitFinishedEvent) {
        installCompleter.complete();
        installationComplete = true;
        removeComplete = false;
      }
    });
    await installTransaction.installFiles(paths);
    await installCompleter.future;
  }

  Future<void> remove() async {
    final resolveTransaction = await client.createTransaction();
    final resolveCompleter = Completer();
    final packageIds = <PackageKitPackageId>[];
    resolveTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        packageIds.add(event.packageId);
      } else if (event is PackageKitFinishedEvent) {
        resolveCompleter.complete();
      }
    });
    await resolveTransaction.resolve([name]);
    await resolveCompleter.future;
    if (packageIds.isEmpty) {
      await client.close();
      return;
    }

    final removeTransaction = await client.createTransaction();
    final removeCompleter = Completer();
    removeTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        status = '[${event.packageId.name}] ${event.info}';
      } else if (event is PackageKitItemProgressEvent) {
        progress = event.percentage;
      } else if (event is PackageKitErrorCodeEvent) {
      } else if (event is PackageKitFinishedEvent) {
        removeCompleter.complete();
        removeComplete = true;
        installationComplete = false;
      }
    });
    await removeTransaction.removePackages(packageIds);
    await removeCompleter.future;
  }

  /// The ID of the package this event relates to.
  PackageKitPackageId? _packageId;
  PackageKitPackageId? get packageId => _packageId;
  set packageId(PackageKitPackageId? value) {
    if (value == _packageId) return;
    _packageId = value;
    notifyListeners();
  }

  String get version => _packageId != null ? _packageId!.version : '';
  String get name => _packageId != null ? _packageId!.name : '';
  String get arch => _packageId != null ? _packageId!.arch : '';
  String get data => _packageId != null ? _packageId!.data : '';

  /// The group this package belongs to.
  // PackageKitGroup _group;
  // PackageKitGroup get group => _group;
  // set group(PackageKitGroup value) {
  //   if (value == _group) return;
  //   _group = value;
  //   notifyListeners();
  // }

  /// The one line package summary, e.g. "Clipart for OpenOffice"
  String _summary;
  String get summary => _summary;
  set summary(String value) {
    if (value == _summary) return;
    _summary = value;
    notifyListeners();
  }

  ///The multi-line package description in markdown syntax.
  // String _description;
  // String get description => _description;
  // set description(String value) {
  //   if (value == _description) return;
  //   _description = value;
  //   notifyListeners();
  // }

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

  Future<void> init() async {
    final transaction = await client.createTransaction();
    final detailsCompleter = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitDetailsEvent) {
        packageId = event.packageId;
        summary = event.summary;
        url = event.url;
        license = event.license;
        size = event.size;
      } else if (event is PackageKitFinishedEvent) {
        detailsCompleter.complete();
      }
    });
    await transaction.getDetailsLocal([path]);
    await detailsCompleter.future;
    notifyListeners();
  }
}
