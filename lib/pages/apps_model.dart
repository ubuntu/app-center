import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';

class AppsModel extends SafeChangeNotifier {
  final SnapdClient client;

  bool _appChangeInProgress;
  bool get appChangeInProgress => _appChangeInProgress;
  set appChangeInProgress(bool value) {
    if (value == _appChangeInProgress) return;
    _appChangeInProgress = value;
    notifyListeners();
  }

  AppsModel(this.client) : _appChangeInProgress = false;

  Future<List<Snap>> findSnapsBySection({String? section}) async {
    final snaps = await client.find(section: section);
    return snaps;
  }

  Future<Snap> findSnapByName(String name) async {
    final snaps = await client.find(name: name);
    return snaps.first;
  }

  Future<void> installSnap(Snap snap) async {
    await client.loadAuthorization();
    final changeId = await client.install(
      snap.name,
      classic: snap.confinement == SnapConfinement.classic,
    );
    appChangeInProgress = true;
    while (true) {
      final change = await client.getChange(changeId);
      if (change.ready) {
        appChangeInProgress = false;
        break;
      }
      await Future.delayed(
        Duration(milliseconds: 100),
      );
    }
    appChangeInProgress = false;
  }

  Future<List<SnapApp>> get snapApps async {
    await client.loadAuthorization();
    return await client.apps();
  }

  Future<void> unInstallSnap(SnapApp snapApp) async {
    {
      await client.loadAuthorization();
      final id = await client.remove(snapApp.name);
      appChangeInProgress = true;
      while (true) {
        final change = await client.getChange(id);
        if (change.ready) {
          appChangeInProgress = false;
          break;
        }

        await Future.delayed(
          Duration(milliseconds: 100),
        );
      }
      appChangeInProgress = false;
    }
  }

  Future<bool> snapIsIstalled(Snap snap) async {
    final snaps = await snapApps;
    for (var snapApp in snaps) {
      if (snap.name == snapApp.snap) return true;
    }
    return false;
  }
}
