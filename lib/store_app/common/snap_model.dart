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
import 'package:software/services/color_generator.dart';
import 'package:software/services/snap_service.dart';
import 'package:software/snapx.dart';
import 'package:software/store_app/common/utils.dart';

class SnapModel extends SafeChangeNotifier {
  SnapModel(
    this._client,
    this._snapService, {
    required this.doneString,
    this.colorGenerator,
    required this.huskSnapName,
    this.online = true,
  })  : _appChangeInProgress = false,
        _channelToBeInstalled = '',
        connections = {};

  Future<void> init() async {
    _localSnap = await _findLocalSnap(huskSnapName);
    if (online) {
      _storeSnap = await _findSnapByName(huskSnapName).timeout(
        const Duration(seconds: 15),
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

    _selectableChannels = _fillSelectableChannels(storeSnap: _storeSnap);

    channelToBeInstalled = _determineChannelToBeInstalled(
      storeSnap: _storeSnap,
      snapIsInstalled: snapIsInstalled,
      selectableChannels: selectableChannels,
      trackingChannel: trackingChannel,
    );

    _snapChangesSub = _snapService.snapChangesInserted.listen((_) async {
      _loadProgress();
      if (!appChangeInProgress) {
        _localSnap = await _findLocalSnap(huskSnapName);
      }
      notifyListeners();
    });

    await loadConnections();
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _snapChangesSub?.cancel();
    super.dispose();
  }

  final SnapService _snapService;

  /// The [SnapDClient]
  final SnapdClient _client;

  /// Used for some banners to have a generated color tint.
  final ColorGenerator? colorGenerator;

  /// [SnapDClient] does not return information about channels of a [Snap] unless
  /// they are found by name. Thus we instantiate [SnapModel] only with the [huskSnapName]
  /// and load the rest of the information about the snap inside [init].
  final String huskSnapName;

  /// The snap loaded by find inside [init] with given [huskSnapName]
  /// from the snap store. This [Snap] includes all information, but not the installed channel
  /// and not the list of [SnapConnection]s.
  Snap? _storeSnap;

  /// Mainly used for the information about the install [SnapChannel] and
  /// the [SnapConnection]s. It is used as a fallback for some information
  /// if the snap is offline.
  Snap? _localSnap;

  /// Boolean flag to decide if snapd is used offline or online.
  bool online;

  /// Localized string used to after install/refresh/remove to display inside the
  /// desktop notification.
  final String doneString;

  /// [StreamSubscription] to listen to snap changes.
  StreamSubscription<bool>? _snapChangesSub;

  /// Apps this snap provides.
  List<SnapApp>? get apps => _localSnap?.apps;

  /// The base snap this snap uses.
  String? get base => _storeSnap?.base ?? _localSnap?.base;

  /// The channel this snap is from, e.g. "stable".
  String? get channel => _storeSnap?.channel ?? _localSnap?.channel;

  /// Map to select a [SnapChannel]
  Map<String, SnapChannel> get selectableChannels => _selectableChannels ?? {};
  Map<String, SnapChannel>? _selectableChannels;

  /// The [SnapChannel] the snap should be installed from.
  String _channelToBeInstalled;
  String get channelToBeInstalled => _channelToBeInstalled;
  set channelToBeInstalled(String value) {
    if (value == _channelToBeInstalled) return;
    _channelToBeInstalled = value;
    notifyListeners();
  }

  /// Helper getter for the selected [SnapChannel]'s version.
  String get selectedChannelVersion =>
      selectableChannels[channelToBeInstalled] != null
          ? selectableChannels[channelToBeInstalled]!.version
          : '';

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

  /// Helper getter to get the icon url of the [SnapMedia]
  String? get iconUrl => _storeSnap?.iconUrl ?? _localSnap?.iconUrl;

  /// Helper getter to get the screenshot urls of the [SnapMedia]
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

  /// ISO normed [installDate]
  String get installDateIsoNorm {
    if (_localSnap == null || _localSnap!.installDate == null) return '';

    return DateFormat.yMd(Platform.localeName)
        .add_jms()
        .format(_localSnap!.installDate!.toLocal());
  }

  /// Helper getter to check if the snap has been installed.
  bool get snapIsInstalled =>
      _localSnap != null && _localSnap!.installDate != null;

  /// Installed size in bytes as a formated string.
  String get installedSize {
    return _localSnap != null && _localSnap!.installedSize != null
        ? formatBytes(_localSnap!.installedSize!, 2)
        : '';
  }

  /// Package license.
  String? get license => _storeSnap?.license ?? _localSnap?.license;

  /// The date this snap was installed.
  String get releasedAt {
    if (selectableChannels[channelToBeInstalled] == null) return '';

    return DateFormat.yMMMEd(Platform.localeName)
        .format(selectableChannels[channelToBeInstalled]!.releasedAt);
  }

  /// ISO normed [releasedAt]
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

  /// Checks if the app is started as a snap.
  bool get isSnapEnv => Platform.environment['SNAP']?.isNotEmpty == true;

  /// Helper getter to check if the publisher is verified.
  bool get verified => publisher != null && publisher!.validation == 'verified';

  bool _appChangeInProgress;
  bool get appChangeInProgress => _appChangeInProgress;
  set appChangeInProgress(bool value) {
    if (value == _appChangeInProgress) return;
    _appChangeInProgress = value;
    notifyListeners();
  }

  void _loadProgress() {
    if (_storeSnap != null) {
      appChangeInProgress = _snapService.getChange(_storeSnap!) != null;
    }
    if (_localSnap != null) {
      appChangeInProgress = _snapService.getChange(_localSnap!) != null;
    }
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

  Future<void> install() async {
    if (name == null) return;
    await _client.loadAuthorization();
    final changeId = await _client.install(
      name!,
      channel: channelToBeInstalled,
      classic: confinement == SnapConfinement.classic,
    );
    await _snapService.addChange(
      _storeSnap!,
      changeId,
      doneString,
    );
    _localSnap = await _findLocalSnap(huskSnapName);
    await loadConnections();
    notifyListeners();
  }

  Future<void> remove() async {
    if (name == null) return;
    await _client.loadAuthorization();
    final changeId = await _client.remove(name!);
    await _snapService.addChange(
      _localSnap!,
      changeId,
      doneString,
    );
    _localSnap = await _findLocalSnap(huskSnapName);
    notifyListeners();
  }

  Future<void> refresh() async {
    if (name == null || channelToBeInstalled.isEmpty) return;
    await _client.loadAuthorization();
    final changeId = await _client.refresh(
      name!,
      channel: channelToBeInstalled,
      classic: selectableChannels[channelToBeInstalled]?.confinement ==
          SnapConfinement.classic,
    );
    await _snapService.addChange(
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

  Color? _surfaceTintColor;
  Color get surfaceTintColor {
    if (_surfaceTintColor == null && colorGenerator != null) {
      _generateSurfaceTintColor();
    }
    return _surfaceTintColor ?? Colors.transparent;
  }

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

  Map<String, SnapChannel> _fillSelectableChannels({required Snap? storeSnap}) {
    Map<String, SnapChannel> selectableChannels = {};
    if (storeSnap != null && storeSnap.tracks.isNotEmpty) {
      for (var track in storeSnap.tracks) {
        for (var risk in ['stable', 'candidate', 'beta', 'edge']) {
          var name = '$track/$risk';
          var channel = storeSnap.channels[name];
          final channelName = '$track/$risk';
          if (channel != null) {
            selectableChannels.putIfAbsent(channelName, () => channel);
          }
        }
      }
    }
    return selectableChannels;
  }

  String _determineChannelToBeInstalled({
    required Snap? storeSnap,
    required bool snapIsInstalled,
    required Map<String, SnapChannel> selectableChannels,
    required String? trackingChannel,
  }) {
    if (snapIsInstalled && selectableChannels.entries.isNotEmpty) {
      if (trackingChannel != null &&
          selectableChannels.entries
              .where((element) => element.key.contains(trackingChannel))
              .isNotEmpty) {
        return trackingChannel;
      } else {
        return selectableChannels.entries.first.key;
      }
    } else if (storeSnap != null) {
      return selectableChannels.entries.first.key;
    }
    return '';
  }
}
