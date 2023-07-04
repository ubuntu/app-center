import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/l10n.dart';
import 'manage_provider.dart';

class ManagePage extends ConsumerWidget {
  const ManagePage({super.key});

  static IconData get icon => Icons.apps;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).managePageLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localSnaps = ref.watch(manageProvider);
    return localSnaps.when(
      data: (data) => _ManageView(data),
      error: (error, stack) => ErrorWidget(error),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _ManageView extends ConsumerWidget {
  const _ManageView(this.snaps);

  final List<Snap> snaps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
