import 'package:package_info_plus/package_info_plus.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class SettingsModel extends SafeChangeNotifier {
  String appName;

  String packageName;

  String version;

  String buildNumber;
  SettingsModel()
      : appName = '',
        packageName = '',
        version = '',
        buildNumber = '';

  Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    notifyListeners();
  }
}
