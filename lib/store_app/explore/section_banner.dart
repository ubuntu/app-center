import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/snapx.dart';
import 'package:software/store_app/common/app_icon.dart';
import 'package:software/store_app/common/snap/snap_page.dart';
import 'package:software/store_app/common/snap/snap_section.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SectionBanner extends StatelessWidget {
  const SectionBanner({
    super.key,
    required this.snaps,
    required this.section,
    this.onTap,
    required this.gradientColors,
  });

  final List<Snap> snaps;
  final SnapSection section;
  final List<Color> gradientColors;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 200),
      child: Padding(
        padding: const EdgeInsets.only(
          left: kYaruPagePadding + 5,
          right: kYaruPagePadding + 5,
          bottom: kYaruPagePadding + 5,
        ),
        child: InkWell(
          onTap: onTap,
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
              runSpacing: 10,
              children: [
                Text(
                  section.slogan(context.l10n),
                  style: Theme.of(context)
                      .textTheme
                      .headline3!
                      .copyWith(color: Colors.white),
                ),
                const SizedBox(
                  width: 100,
                ),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: kYaruPagePadding,
                  children: snaps
                      .map(
                        (e) => InkWell(
                          onTap: () => SnapPage.push(context, e),
                          child: Shadow(
                            child: AppIcon(
                              iconUrl: e.iconUrl,
                              size: 70,
                            ),
                          ),
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
      ),
    );
  }
}

class Shadow extends StatelessWidget {
  const Shadow({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }
}
