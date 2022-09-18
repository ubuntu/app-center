import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AppMedia extends StatelessWidget {
  const AppMedia({
    Key? key,
    required this.media,
  }) : super(key: key);

  final List<String> media;

  @override
  Widget build(BuildContext context) {
    return YaruCarousel(
      nextIcon: const Icon(YaruIcons.go_next),
      previousIcon: const Icon(YaruIcons.go_previous),
      navigationControls: media.length > 1,
      viewportFraction: 1,
      width: 280,
      children: [
        for (final url in media)
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              excludeFromSemantics: true,
              onTap: () => showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: YaruSafeImage(
                        url: url,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                        fallBackIconData: YaruIcons.image,
                      ),
                    )
                  ],
                ),
              ),
              child: YaruSafeImage(
                url: url,
                fallBackIconData: YaruIcons.image,
              ),
            ),
          )
      ],
    );
  }
}
