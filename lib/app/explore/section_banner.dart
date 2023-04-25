import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:software/app/common/app_finding.dart';
import 'package:software/app/common/app_icon.dart';
import 'package:software/app/common/base_plate.dart';
import 'package:software/app/common/snap/snap_page.dart';
import 'package:software/app/common/snap/snap_section.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/snapx.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../common/constants.dart';

class SectionBanner extends StatelessWidget {
  const SectionBanner({
    super.key,
    required this.apps,
    required this.section,
    required this.gradientColors,
  });

  final List<AppFinding?>? apps;
  final SnapSection section;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    if (apps == null || apps!.isEmpty || apps!.any((app) => app == null)) {
      return const LoadingSectionBanner();
    }

    final firstGradientColorIsBright = ThemeData.estimateBrightnessForColor(
          gradientColors.first,
        ) ==
        Brightness.light;

    final title = Text(
      section.localize(context.l10n),
      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
        color: firstGradientColorIsBright ? YaruColors.inkstone : Colors.white,
        fontWeight: FontWeight.w500,
        shadows: [
          if (!firstGradientColorIsBright)
            Shadow(
              offset: const Offset(0, 1),
              blurRadius: 1.0,
              color: Colors.black.withOpacity(
                0.4,
              ), //color of shadow with opacity
            )
          else
            Shadow(
              offset: const Offset(0, 1),
              blurRadius: 1.0,
              color: Colors.white.withOpacity(
                0.9,
              ),
            )
        ],
      ),
    );

    final subSlogan = Text(
      section.slogan(context.l10n),
      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
        color: firstGradientColorIsBright ? YaruColors.inkstone : Colors.white,
        fontWeight: FontWeight.w100,
        shadows: [
          if (!firstGradientColorIsBright)
            Shadow(
              offset: const Offset(0, 1),
              blurRadius: 1.0,
              color: Colors.black.withOpacity(
                0.4,
              ), //color of shadow with opacity
            )
          else
            Shadow(
              offset: const Offset(0, 1),
              blurRadius: 1.0,
              color: Colors.white.withOpacity(
                0.9,
              ),
            )
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(
        top: 5,
        left: kPagePadding,
        right: kPagePadding,
        bottom: kPagePadding - 5,
      ),
      child: Container(
        padding: const EdgeInsets.all(30),
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: gradientColors,
          ),
        ),
        child: SizedBox(
          width: 800,
          child: Wrap(
            runSpacing: kYaruPagePadding,
            runAlignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  subSlogan,
                ],
              ),
              Wrap(
                spacing: 10,
                children: apps!
                    .map(
                      (e) => _PlatedIcon(
                        app: e!,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlatedIcon extends StatefulWidget {
  const _PlatedIcon({
    // ignore: unused_element
    super.key,
    required this.app,
  });

  final AppFinding app;

  @override
  State<_PlatedIcon> createState() => _PlatedIconState();
}

class _PlatedIconState extends State<_PlatedIcon> {
  bool hovered = false;
  final dur = const Duration(milliseconds: 100);
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: widget.app.snap!.name,
      verticalOffset: 45.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => SnapPage.push(
            context: context,
            snap: widget.app.snap!,
            appstream: widget.app.appstream,
          ),
          onHover: (value) => setState(() => hovered = value),
          child: BasePlate(
            hovered: hovered,
            child: AppIcon(
              iconUrl: widget.app.snap!.iconUrl,
              loadingBaseColor:
                  dark ? const Color.fromARGB(255, 236, 236, 236) : null,
              loadingHighlight:
                  dark ? const Color.fromARGB(255, 211, 211, 211) : null,
              size: 50,
            ),
          ),
        ),
      ),
    );
  }
}

class LoadingSectionBanner extends StatelessWidget {
  const LoadingSectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var light = theme.brightness == Brightness.light;
    final shimmerBase =
        light ? const Color.fromARGB(120, 228, 228, 228) : YaruColors.jet;
    final shimmerHighLight =
        light ? const Color.fromARGB(200, 247, 247, 247) : YaruColors.coolGrey;
    return Shimmer.fromColors(
      baseColor: shimmerBase,
      highlightColor: shimmerHighLight,
      child: Container(
        margin: const EdgeInsets.only(
          top: 5,
          left: kPagePadding,
          right: kPagePadding,
          bottom: kPagePadding - 5,
        ),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kYaruContainerRadius),
          color: Theme.of(context).colorScheme.surface,
        ),
        height: 220,
        // width: 800,
      ),
    );
  }
}
