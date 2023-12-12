import 'dart:async';

import 'package:collection/collection.dart';
import 'package:snapd/snapd.dart';

mixin SnapdWatcher on SnapdClient {
  Stream<SnapdChange> watchChange(
    String id, {
    Duration interval = const Duration(milliseconds: 100),
  }) {
    return Stream.periodic(interval, (_) => getChange(id))
        .asyncMap((response) async => response)
        .distinct();
  }

  Stream<List<String>> watchChanges({
    String? name,
    Duration interval = const Duration(milliseconds: 100),
  }) {
    return Stream.periodic(interval, (_) => getChanges(name: name))
        .asyncMap((response) async => response)
        .map((changes) => changes.map((c) => c.id).sorted())
        .distinct(const ListEquality().equals);
  }
}
