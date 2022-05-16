import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';

class ExploreModel extends SafeChangeNotifier {
  final SnapdClient client;

  ExploreModel(this.client);

  Future<List<Snap>> findSnapApps() async {
    final snaps = await client.find();
    return snaps;
  }
}
