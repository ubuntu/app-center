import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:intl/intl.dart';
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
        _size = '',
        _summary = '',
        _url = '',
        _processing = false {
    _client.connect();
  }

  final PackageKitClient _client;

  Future<void> init({bool update = false}) async {
    await _isInstalled();
    await _getDetails();
    if (update) {
      await getUpdateDetail();
    }
  }

  /// The ID of the package.
  final PackageKitPackageId packageId;

  /// The ID of the package if it is installed, only relevant for updates.
  final PackageKitPackageId installedId;

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
  String _size;
  String get size => _size;
  void setSize(int value) {
    _size = _formatBytes(value, 2);
    notifyListeners();
  }

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
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

  bool _processing;
  bool get processing => _processing;
  set processing(bool value) {
    if (value == _processing) return;
    _processing = value;
    notifyListeners();
  }

  bool _packageIsInstalled = false;
  bool get packageIsInstalled => _packageIsInstalled;
  set packageIsInstalled(bool value) {
    if (value == _packageIsInstalled) return;
    _packageIsInstalled = value;
    notifyListeners();
  }

  /// Removes with package with [packageId]
  Future<void> remove() async {
    final removeTransaction = await _client.createTransaction();
    processing = true;
    final removeCompleter = Completer();
    removeTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        // processing = event.info == PackageKitInfo.removing;
      } else if (event is PackageKitItemProgressEvent) {
        progress = event.percentage;
      } else if (event is PackageKitErrorCodeEvent) {
      } else if (event is PackageKitFinishedEvent) {
        removeCompleter.complete();
      }
    });
    await removeTransaction.removePackages([packageId]);
    await removeCompleter.future;
    await _isInstalled();
    processing = false;
  }

  /// Installs with package with [packageId]
  Future<void> install() async {
    final installTransaction = await _client.createTransaction();
    processing = true;
    final installCompleter = Completer();
    installTransaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        // processing = event.info == PackageKitInfo.installing;
      } else if (event is PackageKitItemProgressEvent) {
        progress = event.percentage;
      } else if (event is PackageKitFinishedEvent) {
        installCompleter.complete();
      }
    });
    await installTransaction.installPackages([packageId]);
    await installCompleter.future;
    await _isInstalled();
    processing = false;
  }

  /// Get the details about the package or update with given [packageId]
  Future<void> _getDetails() async {
    var installTransaction = await _client.createTransaction();
    var detailsCompleter = Completer();
    installTransaction.events.listen((event) {
      if (event is PackageKitDetailsEvent) {
        summary = event.summary;
        url = event.url;
        license = event.license;
        setSize(event.size);
        description = event.description;
        group = event.group;
      } else if (event is PackageKitFinishedEvent) {
        detailsCompleter.complete();
      }
    });
    await installTransaction.getDetails([packageId]);
    await detailsCompleter.future;
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

  /// Get more details about given [packageId]
  Future<void> getUpdateDetail() async {
    changelog = '';
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitUpdateDetailEvent) {
        changelog = event.changelog;
        issued = DateFormat.yMMMMEEEEd(Platform.localeName)
            .format(event.issued ?? DateTime.now());
      } else if (event is PackageKitErrorCodeEvent) {
        // print('${event.code}: ${event.details}');
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });
    await transaction.getUpdateDetail([packageId]);
    await completer.future;
  }

  Future<void> _isInstalled() async {
    final transaction = await _client.createTransaction();
    final completer = Completer();
    transaction.events.listen((event) {
      if (event is PackageKitPackageEvent) {
        if (event.info == PackageKitInfo.installed) {
          packageIsInstalled = true;
        }
      } else if (event is PackageKitErrorCodeEvent) {
      } else if (event is PackageKitFinishedEvent) {
        completer.complete();
      }
    });

    await transaction.searchNames([packageId.name]);
    await completer.future;
  }
}
