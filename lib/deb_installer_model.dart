import 'dart:async';

import 'package:dpkg/dpkg.dart';
import 'package:packagekit/packagekit.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class DebInstallerModel extends SafeChangeNotifier {
  final PackageKitClient client;
  final String path;
  DebBinaryFile? _debBinaryFile;
  DebControl? _control;
  String get packageName => _control != null ? _control!.package : '';
  String get version => _control != null ? _control!.version : '';

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

  DebInstallerModel(this.path, this.client)
      : _progress = 0,
        _installationComplete = false,
        _removeComplete = false,
        _status = '',
        _appIsInstalled = false;

  Future<void> init() async {
    await client.connect();
    _debBinaryFile = DebBinaryFile(path);
    _control = await _debBinaryFile?.getControl();
    // await checkIsInstalled();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    if (_debBinaryFile != null) {
      _debBinaryFile!.close();
    }
  }

  Future<void> install() async {
    final paths = [path];

    final installTransaction = await client.createTransaction();
    final installCompleter = Completer();
    installTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        print('[${event.packageId.name}] ${event.info}');
        status = '[${event.packageId.name}] ${event.info}';
      } else if (event is PackageKitItemProgressEvent) {
        print('[${event.packageId.name}] ${event.status} ${event.percentage}%');
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
    var packageNames = [packageName];

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
    await resolveTransaction.resolve(packageNames);
    await resolveCompleter.future;
    if (packageIds.isEmpty) {
      print('No packages found');
      await client.close();
      return;
    }

    final removeTransaction = await client.createTransaction();
    final removeCompleter = Completer();
    removeTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        print('[${event.packageId.name}] ${event.info}');
        status = '[${event.packageId.name}] ${event.info}';
      } else if (event is PackageKitItemProgressEvent) {
        print('[${event.packageId.name}] ${event.status} ${event.percentage}%');
        progress = event.percentage;
      } else if (event is PackageKitErrorCodeEvent) {
        print('${event.code}: ${event.details}');
      } else if (event is PackageKitFinishedEvent) {
        removeCompleter.complete();
        removeComplete = true;
        installationComplete = false;
      }
    });
    await removeTransaction.removePackages(packageIds);
    await removeCompleter.future;
  }
}
