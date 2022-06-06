import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/app_change_service.dart';
import 'package:software/services/color_generator.dart';
import 'package:software/snapx.dart';
import 'package:xdg_icons/xdg_icons.dart';

const fallBackIcon = XdgIconTheme(
  data: XdgIconThemeData(theme: 'Yaru'),
  child: XdgIcon(name: 'application-x-executable', size: 50),
);

class SnapModel extends SafeChangeNotifier {
  final AppChangeService _appChangeService;
  final SnapdClient _client;
  final ColorGenerator? colorGenerator;
  final String huskSnapName;
  Snap? _storeSnap;
  Snap? _localSnap;

  SnapModel(
    this._client,
    this._appChangeService, {
    this.colorGenerator,
    required this.huskSnapName,
  })  : _appChangeInProgress = false,
        _channelToBeInstalled = '',
        selectableChannels = {},
        icon = fallBackIcon;

  StreamSubscription<bool>? _snapChangesSub;

  /// Apps this snap provides.
  List<SnapApp>? get apps => _localSnap?.apps;

  /// The base snap this snap uses.
  String? get base => _storeSnap?.base ?? _localSnap?.base;

  /// The channel this snap is from, e.g. "stable".
  String? get channel => _storeSnap?.channel ?? _localSnap?.channel;

  Map<String, SnapChannel> selectableChannels;

  /// Common IDs this snap contains.
  List<String>? get commonIds => _storeSnap?.commonIds ?? _localSnap?.commonIds;

  /// The confinement this snap is using.
  SnapConfinement? get confinement =>
      _storeSnap?.confinement ?? _localSnap?.confinement;

  /// Contact URL.
  String? get contact => _storeSnap?.contact ?? _localSnap?.contact;

  /// Multi line description.
  String? get description => _storeSnap?.description ?? _localSnap?.description;

  /// Download size in bytes.
  int? get downloadSize => _storeSnap?.downloadSize ?? _localSnap?.downloadSize;

  String? get iconUrl => _storeSnap?.iconUrl ?? _localSnap?.iconUrl;

  /// Unique ID for this snap.
  String? get id => _storeSnap?.id ?? _localSnap?.id;

  /// The date this snap was installed.
  String get installDate {
    if (_localSnap == null || _localSnap!.installDate == null) return '';

    return DateFormat.yMMMEd().format(_localSnap!.installDate!);
  }

  /// Installed size in bytes.
  int? get installedSize => _localSnap?.installedSize;

  /// Package license.
  String? get license => _storeSnap?.license ?? _localSnap?.license;

  /// Media associated with this snap.
  List<SnapMedia>? get media => _storeSnap?.media ?? _localSnap?.media;

  /// Unique name for this snap. Use [title] for displaying.
  String? get name => _storeSnap?.name ?? _localSnap?.name;

  /// Publisher information.
  SnapPublisher? get publisher =>
      _storeSnap?.publisher ?? _localSnap?.publisher;

  /// Revision of this snap.
  String? get revision => _storeSnap?.revision ?? _localSnap?.revision;

  /// URL linking to the snap store page on this snap.
  String? get storeUrl => _storeSnap?.storeUrl ?? _localSnap?.storeUrl;

  /// Single line summary.
  String? get summary => _storeSnap?.summary ?? _localSnap?.summary;

  /// Title of this snap.
  String? get title => _storeSnap?.title ?? _localSnap?.title;

  /// The channel that updates will be installed from, e.g. "stable".
  String? get trackingChannel => _localSnap?.trackingChannel;

  /// Tracks this snap uses.
  List<String>? get tracks => _storeSnap?.tracks;

  /// Type of snap.
  String? get type => _storeSnap?.type ?? _localSnap?.type;

  /// Version of this snap.
  String? get version => _localSnap?.version ?? _storeSnap?.version;

  /// Website URL.
  String? get website => _storeSnap?.website ?? _localSnap?.website;

  num? get installPercent => downloadSize == null || installedSize == null
      ? 0
      : installedSize! / downloadSize!;

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
    if (_storeSnap != null && _storeSnap!.tracks.isNotEmpty) {
      for (var track in _storeSnap!.tracks) {
        for (var risk in ['stable', 'candidate', 'beta', 'edge']) {
          var name = '$track/$risk';
          var channel = _storeSnap!.channels[name];
          final channelName = '$track/$risk';
          if (channel != null) {
            selectableChannels.putIfAbsent(channelName, () => channel);
          }
        }
      }
    }
    if (snapIsInstalled) {
      if (trackingChannel != null &&
          selectableChannels.entries
              .where((element) => element.key == trackingChannel)
              .isNotEmpty) {
        channelToBeInstalled = trackingChannel!;
      } else {
        channelToBeInstalled = selectableChannels.entries.first.key;
      }
    } else if (_storeSnap != null) {
      channelToBeInstalled = selectableChannels.entries.first.key;
    }

    _snapChangesSub = _appChangeService.snapChangesInserted.listen((_) {
      if (_storeSnap != null) {
        appChangeInProgress = _appChangeService.getChange(_storeSnap!) != null;
      }
      if (_localSnap != null) {
        appChangeInProgress = _appChangeService.getChange(_localSnap!) != null;
      }
      notifyListeners();
    });

    notifyListeners();
  }

  void addChange(Snap snap, SnapdChange change) {
    _appChangeService.addChange(snap, change);
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _snapChangesSub?.cancel();
    super.dispose();
  }

  Future<Snap?> findLocalSnap(String huskSnapName) async {
    await _client.loadAuthorization();
    try {
      return await _client.getSnap(huskSnapName);
    } on SnapdException {
      return null;
    }
  }

  Future<Snap> findSnapByName(String name) async {
    final snaps = await _client.find(name: name);
    return snaps.first;
  }

  Future<void> installSnap() async {
    if (name == null) return;
    await _client.loadAuthorization();
    final changeId = await _client.install(
      name!,
      channel: channelToBeInstalled,
      classic: confinement == SnapConfinement.classic,
    );
    await _appChangeService.addChange(
      _storeSnap!,
      await _client.getChange(changeId),
    );
    _localSnap = await findLocalSnap(huskSnapName);
    notifyListeners();
  }

  Future<void> removeSnap() async {
    if (name == null) return;
    await _client.loadAuthorization();
    final id = await _client.remove(name!);
    await _appChangeService.addChange(_localSnap!, await _client.getChange(id));
    _localSnap = await findLocalSnap(huskSnapName);
    notifyListeners();
  }

  Future<void> refreshSnapApp() async {
    if (name == null || channelToBeInstalled.isEmpty) return;
    await _client.loadAuthorization();
    final id = await _client.refresh(name!, channel: channelToBeInstalled);
    await _appChangeService.addChange(_localSnap!, await _client.getChange(id));
    _localSnap = await findLocalSnap(huskSnapName);
    notifyListeners();
  }

  Future<List<SnapApp>> get snapApps async {
    await _client.loadAuthorization();
    return await _client.getApps();
  }

  String? get versionString => selectableChannels[channelToBeInstalled] != null
      ? selectableChannels[channelToBeInstalled]!.version
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

  void open() {
    if (_localSnap == null && _localSnap!.apps.isEmpty) return;
    Process.start(
      _localSnap!.apps.first.name,
      [],
      mode: ProcessStartMode.detached,
    );
  }

  Widget icon;
  Future<void> getIcon(File file) async {
    final iconLine = (await file
            .openRead()
            .map(utf8.decode)
            .transform(const LineSplitter())
            .where((line) => line.contains('Icon='))
            .first)
        .replaceAll('Icon=', '');
    if (iconLine.endsWith('.png') || iconLine.endsWith('.jpg')) {
      icon = Image.file(
        File(iconLine),
        filterQuality: FilterQuality.medium,
        width: 50,
      );
    }
    if (iconLine.endsWith('.svg')) {
      try {
        icon = SvgPicture.file(
          File(iconLine),
          width: 50,
        );
      } finally {
        icon = fallBackIcon;
      }
    }
    if (!iconLine.contains('/')) {
      icon = XdgIconTheme(
        data: const XdgIconThemeData(theme: 'Yaru'),
        child: XdgIcon(name: iconLine, size: 48),
      );
    }
    notifyListeners();
  }
}
