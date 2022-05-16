import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';

class ExploreModel extends SafeChangeNotifier {
  final SnapdClient client;

  bool installing;

  ExploreModel(this.client) : installing = false;

  Future<List<Snap>> findSnapApps({String? section}) async {
    final snaps = await client.find(section: section);
    return snaps;
  }

  Future<void> installSnap(Snap snap) async {
    await client.loadAuthorization();
    final changeId = await client.install([snap.name]);
    installing = true;
    notifyListeners();
    while (true) {
      final change = await client.getChange(changeId);
      if (change.ready) {
        installing = false;
        notifyListeners();
        break;
      }

      await Future.delayed(
        Duration(milliseconds: 100),
      );
    }
    installing = false;
    notifyListeners();
  }
}
