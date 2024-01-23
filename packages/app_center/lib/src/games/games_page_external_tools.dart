import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

// TODO: break down into smaller widgets
class ExternalTools extends StatelessWidget {
  const ExternalTools({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ResponsiveLayoutBuilder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kPagePadding) +
                ResponsiveLayout.of(context).padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Navigator.of(context).canPop()) const YaruBackButton(),
                Text(
                  'External Tools',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                return const _Tools();
              }
            )
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kPagePadding) +
                ResponsiveLayout.of(context).padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Disclaimer: These are all recommended external tools. These aren't owned nor distributed by Canonical.", //TODO: l10n
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tools extends ConsumerWidget {
  const _Tools();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ResponsiveLayoutScrollView(
              slivers: [
                AppCardGrid.fromTools(
                  tools: tools,
                ),
              ],
    );
  }
}

List<Tool> tools = [
  Tool('ProtonDB', 'Game compatibility database', 'bdefore', 'https://cdn-1.webcatalog.io/catalog/protondb/protondb-icon-filled-256.webp?v=1675595106939', 'https://protondb.com'),
  Tool('Bottles', 'Run Windows software and games on Linux', 'bottlesdevs', 'https://www.gitbook.com/cdn-cgi/image/width=36,dpr=2,height=36,fit=contain,format=auto/https%3A%2F%2F1775285778-files.gitbook.io%2F~%2Ffiles%2Fv0%2Fb%2Fgitbook-legacy-files%2Fo%2Fspaces%252F-MQH3F0OVam8XE3i-Jc-%252Favatar-1626860267647.png%3Fgeneration%3D1626860267866982%26alt%3Dmedia', 'https://usebottles.com'),
  Tool('Wine', 'Run Microsoft Windows programs on Linux', 'WineHQ', 'https://static.macupdate.com/products/17376/l/wine-logo.png?v=1638440531', 'https://www.winehq.org/')
];
