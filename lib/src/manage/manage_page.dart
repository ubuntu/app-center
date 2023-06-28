import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'manage_provider.dart';

class ManagePage extends ConsumerWidget {
  const ManagePage({super.key});

  @override
  Widget build(context, ref) {
    final localSnaps = ref.watch(manageProvider);
    return Scaffold(
      appBar: const YaruWindowTitleBar(
        leading: YaruBackButton(),
        title: Text('installed snaps'),
      ),
      body: localSnaps.when(
        data: (data) => _ManageView(data),
        error: (error, stack) => ErrorWidget(error),
        loading: () => const Center(child: YaruCircularProgressIndicator()),
      ),
    );
  }
}

class _ManageView extends ConsumerWidget {
  const _ManageView(this.snaps);

  final List<Snap> snaps;

  @override
  Widget build(context, ref) {
    return ListView.builder(
      itemCount: snaps.length,
      itemBuilder: (context, index) {
        final snap = snaps[index];
        return ListTile(
          key: ValueKey(snap.id),
          title: Text(snap.name),
          subtitle: Text(snap.summary),
        );
      },
    );
  }
}
