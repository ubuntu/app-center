import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';
import 'package:software/app/common/base_plate.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/snapx.dart';
import 'package:software/app/common/app_icon.dart';
import 'package:software/app/common/snap/snap_page.dart';
import 'package:software/app/common/snap/snap_section.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../common/constants.dart';

class SectionBanner extends StatelessWidget {
  const SectionBanner({
    super.key,
    required this.snaps,
    required this.section,
    required this.gradientColors,
  });

  final List<Snap> snaps;
  final SnapSection section;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 230),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 5,
          left: kPagePadding,
          right: kPagePadding,
          bottom: kPagePadding - 5,
        ),
        child: Container(
          padding: const EdgeInsets.all(kYaruPagePadding),
          width: 20000,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: gradientColors,
            ),
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            runAlignment: WrapAlignment.start,
            runSpacing: 20,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints.loose(const Size(250, 1000)),
                child: Text(
                  section.slogan(context.l10n),
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 1), //position of shadow
                        blurRadius: 1.0, //blur intensity of shadow
                        color: Colors.black
                            .withOpacity(0.4), //color of shadow with opacity
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 80,
              ),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: kYaruPagePadding,
                children: snaps
                    .map(
                      (e) => _PlatedIcon(
                        snap: e,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(
                height: kYaruPagePadding,
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
    required this.snap,
  });

  final Snap snap;

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
      message: widget.snap.name,
      verticalOffset: 45.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => SnapPage.push(context: context, snap: widget.snap),
          onHover: (value) => setState(() => hovered = value),
          child: BasePlate(
            hovered: hovered,
            child: AppIcon(
              iconUrl: widget.snap.iconUrl,
              loadingBaseColor:
                  dark ? const Color.fromARGB(255, 236, 236, 236) : null,
              loadingHighlight:
                  dark ? const Color.fromARGB(255, 211, 211, 211) : null,
              size: 65,
            ),
          ),
        ),
      ),
    );
  }
}
