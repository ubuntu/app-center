import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/snapx.dart';
import 'package:software/services/color_generator.dart';

class SnapModel extends SafeChangeNotifier {
  final SnapdClient client;
  final ColorGenerator? colorGenerator;
  final String huskSnapName;
  Snap? _snap;

  SnapModel({
    required this.client,
    this.colorGenerator,
    required this.huskSnapName,
  })  : _appChangeInProgress = false,
        _channelToBeInstalled = '',
        _snapIsInstalled = false;

  /// Apps this snap provides.
  List<SnapApp>? get apps => _snap?.apps;

  /// Channel this snap is tracking.
  String? get channel => _snap?.channel;

  /// Channels available for this snap.
  Map<String, SnapChannel>? get channels => _snap?.channels;

  /// Common IDs this snap contains.
  List<String>? get commonIds => _snap?.commonIds;

  /// The confinement this snap is using.
  SnapConfinement? get confinement => _snap?.confinement;

  /// Contact URL.
  String? get contact => _snap?.contact;

  /// Multi line description.
  String? get description => _snap?.description;

  /// Download size in bytes.
  int? get downloadSize => _snap?.downloadSize;

  /// Unique ID for this snap.
  String? get id => _snap?.id;

  /// The date this snap was installed.
  String get installDate => _snap != null && _snap!.installDate != null
      ? DateFormat.yMMMEd().format(_snap!.installDate!)
      : 'not installed';

  /// Installed size in bytes.
  int? get installedSize => _snap?.installedSize;

  /// Package license.
  String? get license => _snap?.license;

  /// Media associated with this snap.
  List<SnapMedia>? get media => _snap?.media;

  /// Unique name for this snap. Use [title] for displaying.
  String? get name => _snap?.name;

  /// Publisher information.
  SnapPublisher? get publisher => _snap?.publisher;

  /// Revision of this snap.
  String? get revision => _snap?.revision;

  /// URL linking to the snap store page on this snap.
  String? get storeUrl => _snap?.storeUrl;

  /// Single line summary.
  String? get summary => _snap?.summary;

  /// Title of this snap.
  String? get title => _snap?.title;

  /// Tracks this snap uses.
  List<String>? get tracks => _snap?.tracks;

  /// Type of snap.
  String? get type => _snap?.type;

  /// Version of this snap.
  String? get version => _snap?.version;

  /// Website URL.
  String? get website => _snap?.website;

  bool _appChangeInProgress;
  bool get appChangeInProgress => _appChangeInProgress;
  set appChangeInProgress(bool value) {
    if (value == _appChangeInProgress) return;
    _appChangeInProgress = value;
    notifyListeners();
  }

  // TODO: when [installDate] is provided for any installed channel we only need to check it for null in this getter
  // and remove the setter
  bool _snapIsInstalled;
  bool get snapIsInstalled => _snapIsInstalled;
  set snapIsInstalled(bool value) {
    if (value == _snapIsInstalled) return;
    _snapIsInstalled = value;
    notifyListeners();
  }

  Future<bool> _checkIfSnapIsInstalled(String snap) async {
    final installedSnapApps = await snapApps;
    for (var snapApp in installedSnapApps) {
      if (snap == snapApp.name) return true;
    }
    return false;
  }

  String _channelToBeInstalled;
  String get channelToBeInstalled => _channelToBeInstalled;
  set channelToBeInstalled(String value) {
    if (value == _channelToBeInstalled) return;
    _channelToBeInstalled = value;
    notifyListeners();
  }

  Future<void> init() async {
    snapIsInstalled = await _checkIfSnapIsInstalled(huskSnapName);
    _snap = await findSnapByName(huskSnapName);

    if (_snap != null) {
      if (channels != null && channels!.entries.isNotEmpty) {
        if (snapIsInstalled) {
          for (var entry in channels!.entries) {
            if (entry.value.version == version) {
              channelToBeInstalled = entry.key;
            }
          }
        } else {
          channelToBeInstalled = channels!.entries.first.key;
        }
      }
    }
    notifyListeners();
  }

  Future<Snap> findSnapByName(String name) async {
    final snaps = await client.find(name: name);
    return snaps.first;
  }

  Future<void> installSnap() async {
    if (name == null) return;
    await client.loadAuthorization();
    final changeId = await client.install(
      name!,
      channel: channelToBeInstalled,
      classic: confinement == SnapConfinement.classic,
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
    _snap = await findSnapByName(huskSnapName);
    snapIsInstalled = await _checkIfSnapIsInstalled(huskSnapName);
    notifyListeners();
  }

  Future<void> removeSnap() async {
    if (name == null) return;
    await client.loadAuthorization();
    final id = await client.remove(name!);
    appChangeInProgress = true;
    while (true) {
      final change = await client.getChange(id);
      if (change.ready) {
        appChangeInProgress = false;
        break;
      }
      await Future.delayed(
        const Duration(milliseconds: 100),
      );
    }
    _snap = await findSnapByName(huskSnapName);
    snapIsInstalled = await _checkIfSnapIsInstalled(huskSnapName);
    notifyListeners();
  }

  Future<void> refreshSnapApp() async {
    if (name == null || channelToBeInstalled.isEmpty) return;
    await client.loadAuthorization();
    final id = await client.refresh(name!, channel: channelToBeInstalled);
    appChangeInProgress = true;
    while (true) {
      final change = await client.getChange(id);
      if (change.ready) {
        appChangeInProgress = false;
        break;
      }

      await Future.delayed(
        const Duration(milliseconds: 100),
      );
    }
    _snap = await findSnapByName(huskSnapName);
    snapIsInstalled = await _checkIfSnapIsInstalled(huskSnapName);
    notifyListeners();
  }

  Future<List<SnapApp>> get snapApps async {
    await client.loadAuthorization();
    return await client.apps();
  }

  String? get versionString => channels?[channelToBeInstalled] != null
      ? channels![channelToBeInstalled]!.version
      : version;

  Color get surfaceTintColor {
    if (_surfaceTintColor == null && colorGenerator != null) {
      _generateSurfaceTintColor();
    }
    return _surfaceTintColor ?? Colors.transparent;
  }

  Color? _surfaceTintColor;

  Future<void> _generateSurfaceTintColor() async {
    final url = _snap?.iconUrl;
    final color = url != null ? await colorGenerator?.generateColor(url) : null;
    if (_surfaceTintColor != color) {
      _surfaceTintColor = color;
      notifyListeners();
    }
  }
}
