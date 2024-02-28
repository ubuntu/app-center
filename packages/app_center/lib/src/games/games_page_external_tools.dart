import 'package:app_center/games.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/src/snapd/snap_category_enum.dart';
import 'package:app_center/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

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
              ],
            ),
          ),
          Padding(
            padding: ResponsiveLayout.of(context).padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: SnapCategoryEnum.games.bannerColors,
                    ),
                  ),
                  height: 180,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.externalResources,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                l10n.externalResourcesDisclaimer,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: kPagePadding,
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                return const _Tools();
              },
            ),
          ),
          const SizedBox(
            height: kPagePadding,
          )
        ],
      ),
    );
  }
}

class _Tools extends ConsumerWidget {
  const _Tools();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveLayoutScrollView(
      slivers: [
        AppCardGrid.fromTools(tools: tools),
      ],
    );
  }
}

//TODO: should we localize this stuff?
List<Tool> tools = [
  Tool(
      'ProtonDB',
      'Game compatibility database',
      'bdefore',
      'https://cdn-1.webcatalog.io/catalog/protondb/protondb-icon-filled-256.webp?v=1675595106939',
      'https://protondb.com'),
  Tool(
      'Bottles',
      'Run Windows software and games on Linux',
      'bottlesdevs',
      'https://www.gitbook.com/cdn-cgi/image/width=36,dpr=2,height=36,fit=contain,format=auto/https%3A%2F%2F1775285778-files.gitbook.io%2F~%2Ffiles%2Fv0%2Fb%2Fgitbook-legacy-files%2Fo%2Fspaces%252F-MQH3F0OVam8XE3i-Jc-%252Favatar-1626860267647.png%3Fgeneration%3D1626860267866982%26alt%3Dmedia',
      'https://usebottles.com'),
  Tool(
      'Wine',
      'Run Microsoft Windows programs on Linux',
      'WineHQ',
      'https://static.macupdate.com/products/17376/l/wine-logo.png?v=1638440531',
      'https://www.winehq.org/'),
  Tool('Lutris', 'Launcher, hub, and game tweaks', 'Lutris',
      'https://lutris.net/static/images/logo.png', 'https://lutris.net/'),
  Tool('GameMode', 'Game optimizer and performance tweaks', 'Feral Interactive',
      '', 'https://github.com/FeralInteractive/gamemode'),
  Tool('MangoHUD', 'Game HUD and overlay', 'flightlessmango', '',
      'https://github.com/flightlessmango/MangoHud'),
  Tool(
      'AreWeAntiCheatYet?',
      'Crowd-sourced anti-cheat status for Linux games',
      'Starz0r & Curve',
      'https://areweanticheatyet.com/icon.webp',
      'https://areweanticheatyet.com/'),
  Tool(
      'Unreal Engine',
      'Game engine, real-time 3D creation tool',
      'Epic Games',
      'https://alternative.me/media/256/unreal-engine-4-icon-n9l5dnli0fo5ghgo-c.png',
      'https://www.unrealengine.com/'),
  Tool(
      'Unity Engine',
      'Cross-platform game engine',
      'Unity Technologies',
      'https://engine.needle.tools/docs/imgs/unity-logo.webp',
      'https://unity.com/'),
  Tool(
      'GamingOnLinux',
      'Blog with information on Linux Gaming',
      'Liam Dawe',
      'https://www.gamingonlinux.com/templates/default/images/logos/icon_mouse.png',
      'https://www.gamingonlinux.com/'),
  Tool(
      'Proton GE',
      'Compatibility tool based on Steam Play',
      'GloriousEggroll',
      'https://avatars.githubusercontent.com/u/11287837?v=4',
      'https://github.com/GloriousEggroll/proton-ge-custom'),
];
