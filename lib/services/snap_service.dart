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

  Future<void> _addChange(Snap snap, String id, String doneString) async {
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

  Future<Snap?> findLocalSnap(String huskSnapName) async {
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
    await _addChange(
      snap,
      changeId,
      doneString,
    );
    return await findLocalSnap(snap.name);
  }

  Future<Snap?> remove(Snap snap, String doneString) async {
    await _snapDClient.loadAuthorization();
    final changeId = await _snapDClient.remove(snap.name);
    await _addChange(
      snap,
      changeId,
      doneString,
    );
    return await findLocalSnap(snap.name);
  }

  Future<Snap?> refresh({
    required Snap snap,
    required String message,
    required String channel,
    required SnapConfinement confinement,
  }) async {
    if (channel.isNotEmpty) {
      await _snapDClient.loadAuthorization();
      final changeId = await _snapDClient.refresh(
        snap.name,
        channel: channel,
        classic: confinement == SnapConfinement.classic,
      );
      await _addChange(
        snap,
        changeId,
        message,
      );
    }
    return await findLocalSnap(snap.name);
  }

  Future<Map<SnapPlug, bool>> loadPlugs(Snap localSnap) async {
    final Map<SnapPlug, bool> plugs = {};
    await _snapDClient.loadAuthorization();

    try {
      final response = await _snapDClient.getConnections(
        snap: localSnap.name,
        filter: SnapdConnectionFilter.all,
      );
      for (final plug in response.plugs) {
        if (plug.snap != 'snapd' &&
            plug.interface != null &&
            !plug.interface!.contains('content')) {
          if (plug.connections.isNotEmpty) {
            plugs.putIfAbsent(plug, () => true);
          } else {
            plugs.putIfAbsent(plug, () => false);
          }
        }
      }
    } on SnapdException {
      return {};
    }
    return plugs;
  }

  Future<void> toggleConnection({
    required Snap snapThatWantsAConnection,
    required String interface,
    required String doneMessage,
    required bool value,
  }) async {
    if (getChange(snapThatWantsAConnection) != null) {
      return;
    }

    await _snapDClient.loadAuthorization();

    final plugSnap = snapThatWantsAConnection.name;
    final plug = interface;
    String? slotSnap;
    String? slot;

    final changeId = value
        ? await _snapDClient.connect(
            plugSnap,
            plug,
            slotSnap ?? 'snapd',
            slot ?? plug,
          )
        : await _snapDClient.disconnect(
            plugSnap,
            plug,
            slotSnap ?? 'snapd',
            slot ?? plug,
          );

    _addChange(snapThatWantsAConnection, changeId, doneMessage);
  }

  Future<List<SnapdChange>> getChanges({required String name}) async =>
      await _snapDClient.getChanges(name: name);

  Future<bool> getSnapChangeInProgress({required String name}) async =>
      (await getChanges(name: name)).isNotEmpty;
}
