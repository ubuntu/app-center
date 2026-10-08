import 'package:app_center/addons/firmware_updater_provider.dart';
import 'package:app_center/constants.dart';
import 'package:app_center/drivers/drivers.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/store/store_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

class AddonsPage extends ConsumerWidget {
  const AddonsPage({super.key});

  static IconData icon(bool selected) =>
      selected ? YaruIcons.puzzle_piece_filled : YaruIcons.puzzle_piece;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).addonsPageLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final showDrivers = ref.watch(driversAvailableProvider).value ?? false;
    return ResponsiveLayoutScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(kPagePadding),
          sliver: SliverList.list(
            children: [
              YaruBorderContainer(
                clipBehavior: Clip.hardEdge,
                child: Column(
                  children: [
                    if (showDrivers) ...[
                      YaruListTile(
                        title: Text(l10n.addonsPageAdditionalDriversTitle),
                        subtitle: Text(
                          l10n.addonsPageAdditionalDriversDescription,
                        ),
                        trailing: const Icon(YaruIcons.go_next),
                        onTap: () =>
                            StoreNavigator.pushAdditionalDrivers(context),
                      ),
                      const Divider(height: 1),
                    ],
                    YaruListTile(
                      title: Text(l10n.addonsPageMediaSupportTitle),
                      subtitle: Text(l10n.addonsPageMediaSupportDescription),
                      trailing: const Icon(YaruIcons.go_next),
                      onTap: () => StoreNavigator.pushMediaSupport(context),
                    ),
                    const Divider(height: 1),
                    const _FirmwareTile(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FirmwareTile extends ConsumerWidget {
  const _FirmwareTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(firmwareUpdaterLauncherProvider);
    final launcher = state.valueOrNull;
    // Stay disabled until the first check so we don't wrongly open the store.
    final resolved = state.hasValue || state.hasError;

    return YaruListTile(
      title: Text(l10n.addonsPageFirmwareTitle),
      subtitle: Text(l10n.addonsPageFirmwareDescription),
      trailing: Icon(
        launcher != null ? YaruIcons.external_link : YaruIcons.go_next,
      ),
      onTap: !resolved
          ? null
          : () => launcher != null
                ? launcher.open()
                : StoreNavigator.pushSnap(
                    context,
                    name: kFirmwareUpdaterSnapName,
                  ),
    );
  }
}
