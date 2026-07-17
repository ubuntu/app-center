import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/store/store_navigator.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class AddonsPage extends StatelessWidget {
  const AddonsPage({super.key});

  static IconData icon(bool selected) =>
      selected ? YaruIcons.puzzle_piece_filled : YaruIcons.puzzle_piece;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).addonsPageLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ResponsiveLayoutScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(kPagePadding),
          sliver: SliverList.list(
            children: [
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
