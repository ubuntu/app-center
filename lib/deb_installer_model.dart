import 'package:dpkg/dpkg.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class DebInstallerModel extends SafeChangeNotifier {
  final String path;
  DebBinaryFile? _debBinaryFile;
  DebControl? _control;
  String get packageName => _control != null ? _control!.package : '';
  String get version => _control != null ? _control!.version : '';

  DebInstallerModel(this.path);

  Future<void> init() async {
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
}
