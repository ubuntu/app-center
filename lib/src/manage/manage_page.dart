import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/l10n.dart';
import '/snapd.dart';
import '/store.dart';
import '/widgets.dart';
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
    final l10n = AppLocalizations.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(kYaruPagePadding),
      itemCount: snaps.length,
      itemBuilder: (context, index) {
        final snap = snaps[index];
        final snapLauncher = ref.watch(launchProvider(snap));
        return ListTile(
          key: ValueKey(snap.id),
          leading: SnapIcon(iconUrl: snap.iconUrl),
          title: Text(snap.titleOrName),
          subtitle: Row(
            children: [
              Text(snap.channel),
              const SizedBox(width: 4),
              Text(snap.version),
            ],
          ),
          trailing: ButtonBar(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (snapLauncher.isLaunchable)
                PushButton.outlined(
                  onPressed: snapLauncher.open,
                  child: Text(l10n.managePageOpenLabel),
                ),
            ],
          ),
          onTap: () => StoreNavigator.pushDetail(context, snap.name),
        );
      },
    );
  }
}
