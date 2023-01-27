import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:software/app/common/app_format.dart';
import 'package:software/services/packagekit/package_service.dart';

class UpdatesModel extends SafeChangeNotifier {
  final PackageService _packageService;

  AppFormat? _appFormat;

  UpdatesModel(this._packageService);

  Future<void> init() async {
    _enabledAppFormats.add(AppFormat.snap);
    if (_packageService.isAvailable) {
      _enabledAppFormats.add(AppFormat.packageKit);
      _appFormat = AppFormat.packageKit;
      notifyListeners();
    }
  }

  AppFormat? get appFormat => _appFormat;
  set appFormat(AppFormat? value) {
    if (value == null || value == _appFormat) return;
    _appFormat = value;
    notifyListeners();
  }

  final Set<AppFormat> _enabledAppFormats = {};
  Set<AppFormat> get enabledAppFormats => _enabledAppFormats;

  void setAppFormat(AppFormat value) {
    if (value == _appFormat) return;
    _appFormat = value;
    if (_appFormat == AppFormat.packageKit && _packageService.isAvailable) {
      _packageService.getInstalledPackages().then((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }
}
