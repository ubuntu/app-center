import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';

class MyAppsModel extends SafeChangeNotifier {
  final SnapdClient client;

  bool uninstalling;

  MyAppsModel(this.client) : uninstalling = false;

  Future<List<SnapApp>> get snapApps async {
    await client.loadAuthorization();
    return await client.apps();
  }

  Future<void> unInstallSnap(SnapApp snapApp) async {
    {
      uninstalling = true;
      notifyListeners();

      await client.loadAuthorization();
      final id = await client.remove([snapApp.name]);
      while (true) {
        final change = await client.getChange(id);
        if (change.ready) {
          uninstalling = false;
          notifyListeners();
          break;
        }

        await Future.delayed(
          Duration(milliseconds: 100),
        );
      }
    }
  }
}
