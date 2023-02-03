import 'package:flutter/material.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_icons/yaru_icons.dart';

class ThemeTile extends StatelessWidget {
  const ThemeTile(this.themeMode, {super.key});

  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    const height = 100.0;
    const width = 150.0;
    var borderRadius2 = BorderRadius.circular(12);
    var lightContainer = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius2,
      ),
    );
    var darkContainer = Container(
      decoration: BoxDecoration(
        color: YaruColors.coolGrey,
        borderRadius: borderRadius2,
      ),
    );
    var titleBar = Container(
      height: 20,
      decoration: BoxDecoration(
        color: themeMode == ThemeMode.dark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
      ),
    );
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Card(
          elevation: 5,
          child: SizedBox(
            height: height,
            width: width,
            child: themeMode == ThemeMode.system
                ? Stack(
                    children: [
                      lightContainer,
                      ClipPath(
                        clipBehavior: Clip.antiAlias,
                        clipper: _CustomClipPath(
                          height: height,
                          width: width,
                        ),
                        child: darkContainer,
                      ),
                      titleBar
                    ],
                  )
                : (themeMode == ThemeMode.light
                    ? Stack(
                        children: [lightContainer, titleBar],
                      )
                    : Stack(
                        children: [darkContainer, titleBar],
                      )),
          ),
        ),
        Positioned(
          right: 8,
          top: 5,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                YaruIcons.window_minimize,
                color:
                    themeMode == ThemeMode.dark ? Colors.white : Colors.black,
                size: 15,
              ),
              Icon(
                YaruIcons.window_maximize,
                size: 15,
                color:
                    themeMode == ThemeMode.dark ? Colors.white : Colors.black,
              ),
              Icon(
                YaruIcons.window_close,
                size: 15,
                color:
                    themeMode == ThemeMode.dark ? Colors.white : Colors.black,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CustomClipPath extends CustomClipper<Path> {
  _CustomClipPath({required this.height, required this.width});

  final double height;
  final double width;

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, width);
    path.lineTo(width, height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
