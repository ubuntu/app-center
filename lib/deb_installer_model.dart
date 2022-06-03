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

  DebInstallerModel(this.path, this.client) : _progress = 0;

  Future<void> init() async {
    await client.connect();
    _debBinaryFile = DebBinaryFile(path);
    _control = await _debBinaryFile?.getControl();
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

    await client.connect();

    final installTransaction = await client.createTransaction();
    final installCompleter = Completer();
    installTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        print('[${event.packageId.name}] ${event.info}');
      } else if (event is PackageKitItemProgressEvent) {
        print('[${event.packageId.name}] ${event.status} ${event.percentage}%');
        _progress = event.percentage;
      } else if (event is PackageKitFinishedEvent) {
        installCompleter.complete();
      }
    });
    await installTransaction.installFiles(paths);
    await installCompleter.future;

    await client.close();
  }
}
