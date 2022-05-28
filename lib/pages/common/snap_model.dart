import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';

class SnapModel extends SafeChangeNotifier {
  final SnapdClient client;
  final String huskSnapName;
  Snap? snap;

  /// Apps this snap provides.
  late List<SnapApp> apps;

  /// Channel this snap is tracking.
  late String channel;

  /// Channels available for this snap.
  late Map<String, SnapChannel> channels;

  /// Common IDs this snap contains.
  late List<String> commonIds;

  /// The confinement this snap is using.
  late SnapConfinement confinement;

  /// Contact URL.
  late String? contact;

  /// Multi line description.
  late String description;

  /// Download size in bytes.
  late int? downloadSize;

  /// Unique ID for this snap.
  late String id;

  /// Installed size in bytes.
  late int? installedSize;

  /// Package license.
  late String? license;

  /// Media associated with this snap.
  late List<SnapMedia> media;

  /// Unique name for this snap. Use [title] for displaying.
  late String name;

  /// Publisher information.
  late SnapPublisher? publisher;

  /// Revision of this snap.
  late String revision;

  /// URL linking to the snap store page on this snap.
  late String? storeUrl;

  /// Single line summary.
  late String summary;

  /// Title of this snap.
  late String title;

  /// Tracks this snap uses.
  late List<String> tracks;

  /// Type of snap.
  late String type;

  /// Version of this snap.
  late String version;

  /// Website URL.
  late String? website;

  bool _appChangeInProgress;
  bool get appChangeInProgress => _appChangeInProgress;
  set appChangeInProgress(bool value) {
    if (value == _appChangeInProgress) return;
    _appChangeInProgress = value;
    notifyListeners();
  }

  bool _snapIsInstalled;
  bool get snapIsInstalled => _snapIsInstalled;
  set snapIsInstalled(bool value) {
    if (value == _snapIsInstalled) return;
    _snapIsInstalled = value;
    notifyListeners();
  }

  String _channelToBeInstalled;
  String get channelToBeInstalled => _channelToBeInstalled;
  set channelToBeInstalled(String value) {
    if (value == _channelToBeInstalled) return;
    _channelToBeInstalled = value;
    notifyListeners();
  }

  SnapModel({
    required this.client,
    required this.huskSnapName,
  })  : _appChangeInProgress = false,
        _snapIsInstalled = false,
        _channelToBeInstalled = '';

  Future<void> init() async {
    snapIsInstalled = await _checkIfSnapIsInstalled(huskSnapName);
    snap = await findSnapByName(huskSnapName);

    if (snap != null) {
      apps = snap!.apps;
      channel = snap!.channel;
      channels = snap!.channels;
      commonIds = snap!.commonIds;
      confinement = snap!.confinement;
      contact = snap!.contact;
      description = snap!.description;
      downloadSize = snap!.downloadSize;
      id = snap!.id;
      installedSize = snap!.installedSize;
      license = snap!.license;
      media = snap!.media;
      name = snap!.name;
      publisher = snap!.publisher;
      revision = snap!.revision;
      storeUrl = snap!.storeUrl;
      summary = snap!.summary;
      title = snap!.title;
      tracks = snap!.tracks;
      type = snap!.type;
      version = snap!.version;
      website = snap!.website;
      _channelToBeInstalled = snapIsInstalled
          ? '${tracks.first}/$channel'
          : channels.entries.first.key;
    }
    notifyListeners();
  }

  Future<Snap> findSnapByName(String name) async {
    final snaps = await client.find(name: name);
    return snaps.first;
  }

  Future<void> installSnap(Snap snap, String? channel) async {
    await client.loadAuthorization();
    final changeId = await client.install(
      snap.name,
      channel: channel,
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
        const Duration(milliseconds: 100),
      );
    }
    appChangeInProgress = false;
    snapIsInstalled = true;
  }

  Future<void> unInstallSnap(SnapApp snapApp) async {
    await client.loadAuthorization();
    final id = await client.remove(snapApp.name);
    appChangeInProgress = true;
    while (true) {
      final change = await client.getChange(id);
      if (change.ready) {
        appChangeInProgress = false;
        snapIsInstalled = false;
        break;
      }

      await Future.delayed(
        const Duration(milliseconds: 100),
      );
    }
    appChangeInProgress = false;
  }

  Future<void> refreshSnapApp(Snap snap, String snapChannel) async {
    await client.loadAuthorization();
    final id = await client.refresh(snap.name, channel: snapChannel);
    appChangeInProgress = true;
    while (true) {
      final change = await client.getChange(id);
      if (change.ready) {
        appChangeInProgress = false;
        channelToBeInstalled = snapChannel;
        break;
      }

      await Future.delayed(
        const Duration(milliseconds: 100),
      );
    }
  }

  Future<List<SnapApp>> get snapApps async {
    await client.loadAuthorization();
    return await client.apps();
  }

  Future<bool> _checkIfSnapIsInstalled(String snap) async {
    final installedSnapApps = await snapApps;
    for (var snapApp in installedSnapApps) {
      if (snap == snapApp.snap) return true;
    }
    return false;
  }

  String get versionString => channels[channelToBeInstalled] != null
      ? channels[channelToBeInstalled]!.version
      : version;
}
