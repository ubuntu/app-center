import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/l10n.dart';
import '/layout.dart';
import '/snapd.dart';
import '/store.dart';
import '/widgets.dart';
import 'manage_model.dart';

class ManagePage extends ConsumerWidget {
  const ManagePage({super.key});

  static IconData icon(bool selected) => YaruIcons.app_grid;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).managePageLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(manageModelProvider);
    return model.state.when(
      data: (_) => _ManageView(model),
      error: (error, stack) => ErrorWidget(error),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _ManageView extends ConsumerWidget {
  const _ManageView(this.model);
  final ManageModel model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        if (model.refreshableSnaps.isNotEmpty)
          PushButton.elevated(
            onPressed: model.updateAll,
            child: Text(l10n.managePageUpdateAllLabel),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(kPagePadding),
            itemCount: model.refreshableSnaps.length +
                model.nonRefreshableSnaps.length +
                (model.refreshableSnaps.isNotEmpty ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == model.refreshableSnaps.length && index > 0) {
                return const Divider();
              }
              final refreshableSnapsOffset = model.refreshableSnaps.isNotEmpty
                  ? model.refreshableSnaps.length + 1
                  : 0;
              final snap = index < model.refreshableSnaps.length
                  ? model.refreshableSnaps.elementAt(index)
                  : model.nonRefreshableSnaps
                      .elementAt(index - refreshableSnapsOffset);
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
                        child: Text(l10n.snapActionOpenLabel),
                      ),
                  ],
                ),
                onTap: () => StoreNavigator.pushDetail(context, snap.name),
              );
            },
          ),
        ),
      ],
    );
  }
}
