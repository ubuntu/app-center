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
    final manageModel = ref.watch(manageModelProvider);
    final updatesModel = ref.watch(updatesModelProvider);
    return manageModel.state.when(
      data: (_) => _ManageView(
        manageModel: manageModel,
        updatesModel: updatesModel,
      ),
      error: (error, stack) => ErrorWidget(error),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _ManageView extends ConsumerWidget {
  const _ManageView({required this.manageModel, required this.updatesModel});
  final ManageModel manageModel;
  final UpdatesModel updatesModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        if (manageModel.refreshableSnaps.isNotEmpty)
          PushButton.elevated(
            onPressed: updatesModel.updateAll,
            child: Text(l10n.managePageUpdateAllLabel),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(kPagePadding),
            itemCount: manageModel.refreshableSnaps.length +
                manageModel.nonRefreshableSnaps.length +
                (manageModel.refreshableSnaps.isNotEmpty ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == manageModel.refreshableSnaps.length && index > 0) {
                return const Divider();
              }
              final refreshableSnapsOffset =
                  manageModel.refreshableSnaps.isNotEmpty
                      ? manageModel.refreshableSnaps.length + 1
                      : 0;
              final snap = index < manageModel.refreshableSnaps.length
                  ? manageModel.refreshableSnaps.elementAt(index)
                  : manageModel.nonRefreshableSnaps
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
