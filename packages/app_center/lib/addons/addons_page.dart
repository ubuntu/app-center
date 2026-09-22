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
    final showDrivers =
        ref.watch(driversAvailableProvider).valueOrNull ?? false;
    return ResponsiveLayoutScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(kPagePadding),
          sliver: SliverList.list(
            children: [
              if (showDrivers)
                YaruBorderContainer(
                  clipBehavior: Clip.hardEdge,
                  child: YaruListTile(
                    title: Text(l10n.addonsPageAdditionalDriversTitle),
                    subtitle: Text(l10n.addonsPageAdditionalDriversDescription),
                    trailing: const Icon(YaruIcons.go_next),
                    onTap: () => StoreNavigator.pushAdditionalDrivers(context),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
