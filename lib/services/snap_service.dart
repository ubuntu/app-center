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

import 'package:collection/collection.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:snapd/snapd.dart';
import 'package:software/app/common/snap/snap_section.dart';
import 'package:software/snapd_change_x.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class SnapService {
  final Map<String, SnapdChange> _snapChanges;
  Map<String, SnapdChange> get snapChanges => _snapChanges;
  final SnapdClient _snapDClient;
  final NotificationsClient _notificationsClient;

  Future<void> _addChange(String id, String doneString) async {
    final newChange = await _snapDClient.getChange(id);
    _snapChanges.putIfAbsent(id, () => newChange);
    if (!_snapChangesController.isClosed) {
      _snapChangesController.add(true);
    }
    var progress = newChange.progress;
    while (true) {
      final newChange = await _snapDClient.getChange(id);
      if (progress != newChange.progress) {
        progress = newChange.progress;
        if (!_snapChangesController.isClosed) {
          _snapChangesController.add(true);
        }
      }
      if (newChange.ready) {
        removeChange(id);
        _notificationsClient.notify(
          'Software',
          body: '$doneString: ${newChange.summary}',
          appName: 'Snap Store',
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

  void removeChange(String id) {
    _snapChanges.remove(id);
    if (!_snapChangesController.isClosed) {
      _snapChangesController.add(true);
    }
  }

  SnapdChange? getChange(Snap snap) {
    return _snapChanges.values
        .firstWhereOrNull((change) => change.snapNames.contains(snap.name));
  }

  final _snapChangesController = StreamController<bool>.broadcast();

  Stream<bool> get snapChangesInserted => _snapChangesController.stream;

  SnapService()
      : _snapChanges = {},
        _snapDClient = getService<SnapdClient>(),
        _notificationsClient = getService<NotificationsClient>();

  late Future<void> _initialized;
  Future<void> get initialized => _initialized;

  Future<void> init() {
    _initialized = authorize().then((_) async {
      for (var section in SnapSection.values) {
        try {
          await _loadSection(section);
        } on SnapdException catch (e) {
          throw SnapdException(message: e.message);
        }
      }
    });
    return _initialized;
  }

  Future<void> authorize() async => await _snapDClient.loadAuthorization();

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

  List<Snap> _localSnaps = [];
  UnmodifiableListView<Snap> get localSnaps =>
      UnmodifiableListView(_localSnaps);
  Future<void> loadLocalSnaps() async {
    _localSnaps = (await _snapDClient.getSnaps());
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
      changeId,
      doneString,
    );
    return await findLocalSnap(snap.name);
  }

  Future<Snap?> remove(Snap snap, String doneString) async {
    final changeId = await _snapDClient.remove(snap.name);
    await _addChange(
      changeId,
      doneString,
    );
    return await findLocalSnap(snap.name);
  }

  final _refreshErrorController = StreamController<String>.broadcast();
  Stream<String> get refreshError => _refreshErrorController.stream;

  Future<Snap?> refresh({
    required Snap snap,
    required String message,
    required String channel,
    required SnapConfinement confinement,
  }) async {
    if (channel.isNotEmpty) {
      try {
        final changeId = await _snapDClient.refresh(
          snap.name,
          channel: channel,
          classic: confinement == SnapConfinement.classic,
        );

        await _addChange(
          changeId,
          message,
        );
      } on SnapdException catch (e) {
        if (e.message.contains('has running apps')) {
          _refreshErrorController.add(
            '${snap.name} has running apps, close ${snap.name} to update.',
          );
        }
      }
    }

    return await findLocalSnap(snap.name);
  }

  Future<void> refreshMany({
    required List<Snap> snaps,
    required String message,
  }) async {
    final changeId =
        await _snapDClient.refreshMany(snaps.map((e) => e.name).toList());
    await _addChange(changeId, message);
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

    _addChange(changeId, doneMessage);
  }

  Future<bool> getSnapChangeInProgress({required String name}) async =>
      (await _snapDClient.getChanges(name: name)).isNotEmpty;

  Future<SnapdChange?> getSnapChanges({required String name}) async =>
      (await _snapDClient.getChanges(name: name)).firstOrNull;

  final _sectionsChangedController = StreamController<SnapSection>.broadcast();
  Stream<SnapSection> get sectionsChanged => _sectionsChangedController.stream;

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
    _sectionsChangedController.add(section);
  }

  List<Snap> _snapsWithUpdate = [];
  UnmodifiableListView<Snap> get snapsWithUpdate =>
      UnmodifiableListView(_snapsWithUpdate);
  Future<void> loadSnapsWithUpdate() async {
    _snapsWithUpdate = await _snapDClient.find(filter: SnapFindFilter.refresh);
  }
}
