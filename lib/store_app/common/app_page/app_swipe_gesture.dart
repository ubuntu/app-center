import 'package:flutter/material.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:yaru_icons/yaru_icons.dart';

class BackGesture extends StatefulWidget {
  final Widget child;

  const BackGesture({
    super.key,
    required this.child,
  });

  @override
  State<BackGesture> createState() => _BackGestureState();
}

class _BackGestureState extends State<BackGesture> {
  final double width = 50;
  final double height = 50;

  double xPosition = 0;
  double yPosition = 0;

  double currentExtent = 0;

  bool isVisible = false;

  void onPanUpdate(DragUpdateDetails details) {
    if (details.delta.dx > 0 &&
        details.delta.dy < 50 &&
        details.delta.dy > -50 &&
        currentExtent <= kMaxExtent) {
      currentExtent += details.delta.dx;
      setState(() {
        xPosition += details.delta.dx * 0.2;
      });
    }
    if (details.delta.dx < 0 &&
        details.delta.dy < 50 &&
        details.delta.dy > -50 &&
        currentExtent >= -width) {
      currentExtent -= -details.delta.dx;
      setState(() {
        xPosition -= -details.delta.dx * 0.2;
      });
    }
  }

  void onPanStart(DragStartDetails details) {
    currentExtent = 0;
    xPosition = 0 - width;
    yPosition =
        (MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height -
                height) /
            2;
    setState(() {
      isVisible = true;
    });
  }

  void onPanEnd(DragEndDetails details) {
    if (currentExtent > (kMaxExtent / 2)) {
      Navigator.of(context).pop();
    }
    setState(() {
      isVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: onPanUpdate,
      onPanStart: onPanStart,
      onPanEnd: onPanEnd,
      child: Stack(
        children: <Widget>[
          widget.child,
          Positioned(
            top: yPosition,
            left: xPosition,
            child: Visibility(
              visible: isVisible,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[100]
                          : Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width),
                  ),
                  minimumSize: Size(width, height),
                ),
                child: const Icon(
                  YaruIcons.go_previous,
                  size: 20,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
