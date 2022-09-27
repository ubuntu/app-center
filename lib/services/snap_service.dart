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

import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class SnapService {
  final Map<Snap, SnapdChange> _snapChanges;
  Map<Snap, SnapdChange> get snapChanges => _snapChanges;
  final SnapdClient _snapDClient;
  final NotificationsClient _notificationsClient;

  Future<void> addChange(Snap snap, String id, String doneString) async {
    final newChange = await _snapDClient.getChange(id);
    _snapChanges.putIfAbsent(snap, () => newChange);
    if (!_snapChangesController.isClosed) {
      _snapChangesController.add(true);
    }
    while (true) {
      final newChange = await _snapDClient.getChange(id);
      if (newChange.ready) {
        removeChange(snap);
        _notificationsClient.notify(
          'Software',
          body: '$doneString: ${newChange.summary}',
          appName: snap.name,
          appIcon: 'snap-store',
          hints: [
            NotificationHint.desktopEntry('software'),
            NotificationHint.urgency(NotificationUrgency.normal)
          ],
        );
        break;
      }
      await Future.delayed(
        const Duration(milliseconds: 100),
      );
    }
  }

  void removeChange(Snap snap) {
    _snapChanges.remove(snap);
    if (!_snapChangesController.isClosed) {
      _snapChangesController.add(true);
    }
  }

  SnapdChange? getChange(Snap snap) {
    return _snapChanges[snap];
  }

  final _snapChangesController = StreamController<bool>.broadcast();

  Stream<bool> get snapChangesInserted => _snapChangesController.stream;

  SnapService()
      : _snapChanges = {},
        _snapDClient = getService<SnapdClient>(),
        _notificationsClient = getService<NotificationsClient>();

  Future<Snap?> _findLocalSnap(String huskSnapName) async {
    await _snapDClient.loadAuthorization();
    try {
      return await _snapDClient.getSnap(huskSnapName);
    } on SnapdException {
      return null;
    }
  }

  Future<Snap?> findSnapByName(String name) async {
    await _snapDClient.loadAuthorization();
    try {
      final snaps = (await _snapDClient.find(name: name));
      return snaps.first;
    } on SnapdException {
      return null;
    }
  }

  Future<Snap?> install(
    Snap snap,
    String channelToBeInstalled,
    String doneString,
  ) async {
    if (channelToBeInstalled.isEmpty) return null;
    await _snapDClient.loadAuthorization();
    final changeId = await _snapDClient.install(
      snap.name,
      channel: channelToBeInstalled,
      classic: snap.confinement == SnapConfinement.classic,
    );
    await addChange(
      snap,
      changeId,
      doneString,
    );
    return await _findLocalSnap(snap.name);
  }

  Future<Snap?> remove(Snap snap, String doneString) async {
    await _snapDClient.loadAuthorization();
    final changeId = await _snapDClient.remove(snap.name);
    await addChange(
      snap,
      changeId,
      doneString,
    );
    return await _findLocalSnap(snap.name);
  }

  Future<void> refresh(
    Snap snap,
    String doneString,
    String channelToBeInstalled,
    SnapConfinement confinement,
  ) async {
    if (channelToBeInstalled.isEmpty) return;
    await _snapDClient.loadAuthorization();
    final changeId = await _snapDClient.refresh(
      snap.name,
      channel: channelToBeInstalled,
      classic: confinement == SnapConfinement.classic,
    );
    await addChange(
      snap,
      changeId,
      doneString,
    );
  }

  Future<void> connect({
    required SnapConnection con,
  }) async {
    await _snapDClient.loadAuthorization();
    await _snapDClient.connect(
      con.plug.snap,
      con.plug.plug,
      con.slot.snap,
      con.slot.slot,
    );
  }

  Future<void> disconnect({
    required SnapConnection con,
  }) async {
    await _snapDClient.loadAuthorization();
    await _snapDClient.disconnect(
      con.plug.snap,
      con.plug.plug,
      con.slot.snap,
      con.slot.slot,
    );
  }

  Map<String, SnapConnection> connections = {};
  Future<void> loadConnections(Snap snap) async {
    await _snapDClient.loadAuthorization();
    final response = await _snapDClient.getConnections();

    for (final connection in response.established) {
      final interface = connection.interface;
      if (connection.plug.snap.contains(snap.name) && interface != 'content') {
        connections.putIfAbsent(
          interface,
          () => connection,
        );
      }
    }
  }
}
