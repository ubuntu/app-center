/*
 * Copyright (C) 2022 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/app_change_service.dart';
import 'package:software/services/color_generator.dart';
import 'package:software/snapx.dart';

class SnapModel extends SafeChangeNotifier {
  final AppChangeService _appChangeService;
  final SnapdClient _client;
  final ColorGenerator? colorGenerator;
  final String huskSnapName;
  Snap? _storeSnap;
  Snap? _localSnap;
  bool online;
  final String doneString;

  SnapModel(
    this._client,
    this._appChangeService, {
    required this.doneString,
    this.colorGenerator,
    required this.huskSnapName,
    this.online = true,
  })  : _appChangeInProgress = false,
        _channelToBeInstalled = '',
        selectableChannels = {},
        connections = {},
        _connectionsExpanded = false;

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

  bool get strict => confinement == SnapConfinement.strict;

  /// Contact URL.
  String? get contact => _storeSnap?.contact ?? _localSnap?.contact;

  /// Multi line description.
  String? get description => _storeSnap?.description ?? _localSnap?.description;

  /// Download size in bytes.
  int? get downloadSize => _storeSnap?.downloadSize ?? _localSnap?.downloadSize;

  String? get iconUrl => _storeSnap?.iconUrl ?? _localSnap?.iconUrl;

  List<String>? get screenshotUrls =>
      _storeSnap?.screenshotUrls ?? _localSnap?.screenshotUrls;

  /// Unique ID for this snap.
  String? get id => _storeSnap?.id ?? _localSnap?.id;

  /// The date this snap was installed.
  String get installDate {
    if (_localSnap == null || _localSnap!.installDate == null) return '';

    return DateFormat.yMMMEd(Platform.localeName)
        .format(_localSnap!.installDate!);
  }

  String get installDateIsoNorm {
    if (_localSnap == null || _localSnap!.installDate == null) return '';

    return DateFormat.yMd(Platform.localeName)
        .add_jms()
        .format(_localSnap!.installDate!.toLocal());
  }

  /// Installed size in bytes.
  int? get installedSize => _localSnap?.installedSize;

  /// Package license.
  String? get license => _storeSnap?.license ?? _localSnap?.license;

  /// The date this snap was installed.
  String get releasedAt {
    if (selectableChannels[channelToBeInstalled] == null) return '';

    return DateFormat.yMMMEd(Platform.localeName)
        .format(selectableChannels[channelToBeInstalled]!.releasedAt);
  }

  String get releaseAtIsoNorm {
    if (selectableChannels[channelToBeInstalled] == null) return '';

    return DateFormat.yMd(Platform.localeName)
        .add_jms()
        .format(selectableChannels[channelToBeInstalled]!.releasedAt.toLocal());
  }

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
  String get version => _localSnap?.version ?? _storeSnap?.version ?? '';

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

  bool _connectionsExpanded;
  bool get connectionsExpanded => _connectionsExpanded;
  set connectionsExpanded(bool value) {
    if (value == _connectionsExpanded) return;
    _connectionsExpanded = value;
    notifyListeners();
  }

  Future<void> init() async {
    _localSnap = await _findLocalSnap(huskSnapName);
    if (online) {
      _storeSnap = await _findSnapByName(huskSnapName).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          notifyListeners();
          return null;
        },
      );
    }

    if (snapIsInstalled) {
      appChangeInProgress =
          (await _client.getChanges(name: _localSnap!.name)).isNotEmpty;
    } else if (_storeSnap != null) {
      appChangeInProgress =
          (await _client.getChanges(name: _storeSnap!.name)).isNotEmpty;
    }

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
    if (snapIsInstalled && selectableChannels.entries.isNotEmpty) {
      if (trackingChannel != null &&
          selectableChannels.entries
              .where((element) => element.key.contains(trackingChannel!))
              .isNotEmpty) {
        channelToBeInstalled = trackingChannel!;
      } else {
        channelToBeInstalled = selectableChannels.entries.first.key;
      }
    } else if (_storeSnap != null) {
      channelToBeInstalled = selectableChannels.entries.first.key;
    }

    _snapChangesSub = _appChangeService.snapChangesInserted.listen((_) async {
      _loadProgress();
      if (!appChangeInProgress) {
        _localSnap = await _findLocalSnap(huskSnapName);
      }
      notifyListeners();
    });

    await loadConnections();
    notifyListeners();
  }

  void _loadProgress() {
    if (_storeSnap != null) {
      appChangeInProgress = _appChangeService.getChange(_storeSnap!) != null;
    }
    if (_localSnap != null) {
      appChangeInProgress = _appChangeService.getChange(_localSnap!) != null;
    }
  }

  @override
  Future<void> dispose() async {
    await _snapChangesSub?.cancel();
    super.dispose();
  }

  Future<Snap?> _findLocalSnap(String huskSnapName) async {
    await _client.loadAuthorization();
    try {
      return await _client.getSnap(huskSnapName);
    } on SnapdException {
      return null;
    }
  }

  Future<Snap?> _findSnapByName(String name) async {
    await _client.loadAuthorization();
    try {
      final snaps = (await _client.find(name: name));
      return snaps.first;
    } on SnapdException {
      return null;
    }
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
      changeId,
      doneString,
    );
    _localSnap = await _findLocalSnap(huskSnapName);
    await loadConnections();
    notifyListeners();
  }

  Future<void> removeSnap() async {
    if (name == null) return;
    await _client.loadAuthorization();
    final changeId = await _client.remove(name!);
    await _appChangeService.addChange(
      _localSnap!,
      changeId,
      doneString,
    );
    _localSnap = await _findLocalSnap(huskSnapName);
    notifyListeners();
  }

  Future<void> refreshSnapApp() async {
    if (name == null || channelToBeInstalled.isEmpty) return;
    await _client.loadAuthorization();
    final changeId = await _client.refresh(
      name!,
      channel: channelToBeInstalled,
      classic: selectableChannels[channelToBeInstalled]?.confinement ==
          SnapConfinement.classic,
    );
    await _appChangeService.addChange(
      _localSnap!,
      changeId,
      doneString,
    );
    await loadConnections();
    notifyListeners();
  }

  Future<void> connect({
    required SnapConnection con,
  }) async {
    await _client.loadAuthorization();
    await _client.connect(
      con.plug.snap,
      con.plug.plug,
      con.slot.snap,
      con.slot.slot,
    );
    notifyListeners();
  }

  Future<void> disconnect({
    required SnapConnection con,
  }) async {
    await _client.loadAuthorization();
    await _client.disconnect(
      con.plug.snap,
      con.plug.plug,
      con.slot.snap,
      con.slot.slot,
    );
    notifyListeners();
  }

  Map<String, SnapConnection> connections;
  Future<void> loadConnections() async {
    await _client.loadAuthorization();
    final response = await _client.getConnections();

    for (final connection in response.established) {
      final interface = connection.interface;
      if (connection.plug.snap.contains(huskSnapName) &&
          interface != 'content') {
        connections.putIfAbsent(
          interface,
          () => connection,
        );
      }
    }
  }

  String? get selectedChannelVersion =>
      selectableChannels[channelToBeInstalled] != null
          ? selectableChannels[channelToBeInstalled]!.version
          : '';

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
}
