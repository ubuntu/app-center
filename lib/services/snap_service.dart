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

import 'package:collection/collection.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:snapd/snapd.dart';
import 'package:software/app/common/snap/snap_section.dart';
import 'package:software/app/common/snap/snap_utils.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class SnapService {
  final Map<Snap, SnapdChange> _snapChanges;
  Map<Snap, SnapdChange> get snapChanges => _snapChanges;
  final SnapdClient _snapDClient;
  final NotificationsClient _notificationsClient;

  static bool isSnapdInstalled = true;

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

  Future<void> init() async => authorize().then((_) async {
        for (var section in SnapSection.values) {
          try {
            await _loadSection(section);
          } on SnapdException catch (e) {
            throw SnapdException(message: e.message);
          } on SocketException {
            isSnapdInstalled  = false;
            print("Is snapd installed: $isSnapdInstalled");
          }
        }
      });

  Future<void> authorize() async => _snapDClient.loadAuthorization();

  Future<Snap?> findLocalSnap(String huskSnapName) async {
    try {
      return await _snapDClient.getSnap(huskSnapName);
    } on SnapdException {
      return null;
    }
  }

  Future<Snap?> findSnapByName(String name) async {
    try {
      final snaps = (await _snapDClient.find(name: name));
      return snaps.first;
    } on SnapdException {
      return null;
    }
  }

  Future<List<Snap>> getLocalSnaps() async {
    final List<Snap> localSnaps = [];
    try {
      localSnaps.addAll((await _snapDClient.getSnaps()));
    }
    on SocketException {
      return localSnaps;
    }
    return localSnaps;
  }

  Future<List<Snap>> findSnapsByQuery({
    required String searchQuery,
    required String? sectionName,
  }) async {
    if (searchQuery.isEmpty) {
      return [];
    } else {
      try {
        return await _snapDClient.find(
          query: searchQuery,
          section: sectionName,
        );
      } on SnapdException catch (e) {
        throw SnapdException(message: e.message);
      }
    }
  }

  Future<List<Snap>> findSnapsBySection({String? sectionName}) async {
    if (sectionName == null) return [];
    try {
      return (await _snapDClient.find(
        section: sectionName,
      ));
    } on SnapdException catch (e) {
      throw SnapdException(message: e.message);
    }
  }

  Future<Snap?> install(
    Snap snap,
    String channelToBeInstalled,
    String doneString,
  ) async {
    if (channelToBeInstalled.isEmpty) return null;
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

  Future<bool> getSnapChangeInProgress({required String name}) async =>
      (await _snapDClient.getChanges(name: name)).isNotEmpty;

  Future<SnapdChange?> getSnapChanges({required String name}) async =>
      (await _snapDClient.getChanges(name: name)).firstOrNull;

  final _sectionsChangedController = StreamController<bool>.broadcast();
  Stream<bool> get sectionsChanged => _sectionsChangedController.stream;

  final Map<SnapSection, List<Snap>> _sectionNameToSnapsMap = {};
  Map<SnapSection, List<Snap>> get sectionNameToSnapsMap =>
      _sectionNameToSnapsMap;
  Future<void> _loadSection(SnapSection section) async {
    List<Snap> sectionList = [];
    for (final snap in await findSnapsBySection(
      sectionName: section == SnapSection.all
          ? SnapSection.featured.title
          : section.title,
    )) {
      sectionList.add(snap);
    }
    _sectionNameToSnapsMap.putIfAbsent(section, () => sectionList);
    _sectionsChangedController.add(true);
  }

  final List<Snap> _snapsWithUpdate = [];
  Future<List<Snap>> loadSnapsWithUpdate() async {
    List<Snap> localSnaps = await getLocalSnaps();

    Map<Snap, Snap> localSnapsToStoreSnaps = {};
    for (var snap in localSnaps) {
      final storeSnap = await findSnapByName(snap.name) ?? snap;
      localSnapsToStoreSnaps.putIfAbsent(snap, () => storeSnap);
    }

    final snapsWithUpdates = localSnaps.where((snap) {
      if (localSnapsToStoreSnaps[snap] == null) return false;
      return isSnapUpdateAvailable(
        storeSnap: localSnapsToStoreSnaps[snap]!,
        localSnap: snap,
      );
    }).toList();

    _snapsWithUpdate.clear();
    _snapsWithUpdate.addAll(snapsWithUpdates);

    return _snapsWithUpdate;
  }

  Future<void> refreshAll({
    required String doneMessage,
    required List<Snap> snaps,
  }) async {
    await authorize();
    for (var snap in snaps) {
      await refresh(
        snap: snap,
        message: doneMessage,
        confinement: snap.confinement,
        channel: snap.channel,
      );
    }
  }
}
