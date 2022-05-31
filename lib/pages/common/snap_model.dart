import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/color_generator.dart';
import 'package:software/snapx.dart';

class SnapModel extends SafeChangeNotifier {
  final SnapdClient client;
  final ColorGenerator? colorGenerator;
  final String huskSnapName;
  Snap? _storeSnap;
  Snap? _localSnap;

  SnapModel({
    required this.client,
    this.colorGenerator,
    required this.huskSnapName,
  })  : _appChangeInProgress = false,
        _channelToBeInstalled = '';

  /// Apps this snap provides.
  List<SnapApp>? get apps => _storeSnap?.apps;

  /// The base snap this snap uses.
  String? get base => _storeSnap?.base;

  /// The channel this snap is from, e.g. "stable".
  String? get channel => _storeSnap?.channel;

  /// Channels available for this snap.
  Map<String, SnapChannel>? get channels => _storeSnap?.channels;

  /// Common IDs this snap contains.
  List<String>? get commonIds => _storeSnap?.commonIds;

  /// The confinement this snap is using.
  SnapConfinement? get confinement => _storeSnap?.confinement;

  /// Contact URL.
  String? get contact => _storeSnap?.contact;

  /// Multi line description.
  String? get description => _storeSnap?.description;

  /// Download size in bytes.
  int? get downloadSize => _storeSnap?.downloadSize;

  /// Unique ID for this snap.
  String? get id => _storeSnap?.id;

  /// The date this snap was installed.
  String get installDate {
    if (_localSnap == null || _localSnap!.installDate == null) return '';

    return DateFormat.yMMMEd().format(_localSnap!.installDate!);
  }

  /// Installed size in bytes.
  int? get installedSize => _storeSnap?.installedSize;

  /// Package license.
  String? get license => _storeSnap?.license;

  /// Media associated with this snap.
  List<SnapMedia>? get media => _storeSnap?.media;

  /// Unique name for this snap. Use [title] for displaying.
  String? get name => _storeSnap?.name;

  /// Publisher information.
  SnapPublisher? get publisher => _storeSnap?.publisher;

  /// Revision of this snap.
  String? get revision => _storeSnap?.revision;

  /// URL linking to the snap store page on this snap.
  String? get storeUrl => _storeSnap?.storeUrl;

  /// Single line summary.
  String? get summary => _storeSnap?.summary;

  /// Title of this snap.
  String? get title => _storeSnap?.title;

  /// The channel that updates will be installed from, e.g. "stable".
  String? get trackingChannel => _storeSnap?.trackingChannel;

  /// Tracks this snap uses.
  List<String>? get tracks => _storeSnap?.tracks;

  /// Type of snap.
  String? get type => _storeSnap?.type;

  /// Version of this snap.
  String? get version => _storeSnap?.version;

  /// Website URL.
  String? get website => _storeSnap?.website;

  bool _appChangeInProgress;
  bool get appChangeInProgress => _appChangeInProgress;
  set appChangeInProgress(bool value) {
    if (value == _appChangeInProgress) return;
    _appChangeInProgress = value;
    notifyListeners();
  }

  bool get snapIsInstalled =>
      _localSnap != null && _localSnap!.installDate != null;

  String _channelToBeInstalled;
  String get channelToBeInstalled => _channelToBeInstalled;
  set channelToBeInstalled(String value) {
    if (value == _channelToBeInstalled) return;
    _channelToBeInstalled = value;
    notifyListeners();
  }

  Future<void> init() async {
    _localSnap = await findLocalSnap(huskSnapName);
    _storeSnap = await findSnapByName(huskSnapName);
    if (snapIsInstalled && _localSnap!.trackingChannel != null) {
      channelToBeInstalled = _localSnap!.trackingChannel!;
    } else if (_storeSnap != null) {
      channelToBeInstalled = channels!.entries.first.key;
    }
    notifyListeners();
  }

  Future<Snap?> findLocalSnap(String huskSnapName) async {
    await client.loadAuthorization();
    try {
      return await client.getSnap(huskSnapName);
    } on SnapdException {
      return null;
    }
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
    _localSnap = await findLocalSnap(huskSnapName);
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
    _localSnap = await findLocalSnap(huskSnapName);
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
    _localSnap = await findLocalSnap(huskSnapName);

    notifyListeners();
  }

  Future<List<SnapApp>> get snapApps async {
    await client.loadAuthorization();
    return await client.getApps();
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
    final url = _storeSnap?.iconUrl;
    final color = url != null ? await colorGenerator?.generateColor(url) : null;
    if (_surfaceTintColor != color) {
      _surfaceTintColor = color;
      notifyListeners();
    }
  }
}
