import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '/snapd.dart';

final searchProvider = FutureProvider.family((ref, String query) {
  final snapd = getService<SnapdService>();
  return snapd.find(query: query);
});

final queryProvider = StateProvider<String>((_) => '');

final autoCompleteProvider = FutureProvider((ref) async {
  final query = ref.watch(queryProvider);
  final completer = Completer();
  ref.onDispose(completer.complete);
  await Future.delayed(const Duration(milliseconds: 100));
  if (query.isNotEmpty && !completer.isCompleted) {
    return ref.watch(searchProvider(query).future);
  }
  return [];
});
