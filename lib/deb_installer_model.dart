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

  bool _installationComplete;
  bool get installationComplete => _installationComplete;
  set installationComplete(bool value) {
    if (value == _installationComplete) return;
    _installationComplete = value;
    notifyListeners();
  }

  DebInstallerModel(this.path, this.client)
      : _progress = 0,
        _installationComplete = false,
        _status = '';

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

  Future<void> checkIsInstalled() async {
    var transaction = await client.createTransaction();
    var completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        var id = event.packageId;
        var status = {
              PackageKitInfo.available: 'Available',
              PackageKitInfo.installed: 'Installed'
            }[event.info] ??
            '         ';
        print(
          '$status ${id.name}-${id.version}.${id.arch} (${id.data})  ${event.summary}',
        );
      } else if (event is PackageKitErrorCodeEvent) {
        print('${event.code}: ${event.details}');
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.getPackages();
    await completer.future;

    await client.close();
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
      }
    });
    await installTransaction.installFiles(paths);
    await installCompleter.future;
  }
}
