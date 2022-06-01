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

  DebInstallerModel(this.path, this.client);

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
    final packageNames = [path];

    final resolveTransaction = await client.createTransaction();
    final resolveCompleter = Completer();
    final packageIds = <PackageKitPackageId>[];
    resolveTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        packageIds.add(event.packageId);
      } else if (event is PackageKitErrorCodeEvent) {
        print('${event.code}: ${event.details}');
      } else if (event is PackageKitFinishedEvent) {
        resolveCompleter.complete();
      }
    });
    await resolveTransaction.resolve(packageNames);
    await resolveCompleter.future;
    if (packageIds.isEmpty) {
      print('No packages found');
      return;
    }

    final installTransaction = await client.createTransaction();
    final installCompleter = Completer();
    installTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        print('[${event.packageId.name}] ${event.info}');
      } else if (event is PackageKitItemProgressEvent) {
        print('[${event.packageId.name}] ${event.status} ${event.percentage}%');
      } else if (event is PackageKitFinishedEvent) {
        installCompleter.complete();
      }
    });
    await installTransaction.installPackages(packageIds);
    await installCompleter.future;
  }
}
