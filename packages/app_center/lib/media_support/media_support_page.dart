import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class MediaSupportPage extends StatelessWidget {
  const MediaSupportPage({super.key});

  static String label(BuildContext context) =>
      AppLocalizations.of(context).addonsPageMediaSupportTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ResponsiveLayoutScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(kPagePadding),
          sliver: SliverList.list(
            children: [
              Text(l10n.mediaSupportPageDescription),
              const SizedBox(height: kPagePadding),
              YaruBorderContainer(
                child: YaruListTile(
                  title: Text(l10n.mediaSupportPageAdditionalMediaTitle),
                  subtitle: Text('3.5 MB'),
                  trailing: OutlinedButton(
                    onPressed: null,
                    child: Text(l10n.mediaSupportPageInstallButton),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
