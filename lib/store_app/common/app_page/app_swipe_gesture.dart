import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';

const double _kButtonSize = 50;
const double _kMaxExtent = 800;

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
  double xPosition = 0;
  double yPosition = 0;

  double currentExtent = 0;

  bool isVisible = false;

  void onPanUpdate(DragUpdateDetails details) {
    if (details.delta.dx > 0 &&
        details.delta.dy < 50 &&
        details.delta.dy > -50 &&
        currentExtent <= _kMaxExtent) {
      currentExtent += details.delta.dx;
      setState(() {
        xPosition += details.delta.dx * 0.2;
      });
    }
    if (details.delta.dx < 0 &&
        details.delta.dy < 50 &&
        details.delta.dy > -50 &&
        currentExtent >= -_kButtonSize) {
      currentExtent -= -details.delta.dx;
      setState(() {
        xPosition -= -details.delta.dx * 0.2;
      });
    }
  }

  void onPanStart(DragStartDetails details) {
    currentExtent = 0;
    xPosition = 0 - _kButtonSize;
    yPosition =
        (MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height -
                _kButtonSize) /
            2;
    setState(() {
      isVisible = true;
    });
  }

  void onPanEnd(DragEndDetails details) {
    if (currentExtent > (_kMaxExtent / 2)) {
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
              child: SizedBox(
                width: _kButtonSize,
                height: _kButtonSize,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.grey[100]
                            : Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_kButtonSize),
                    ),
                  ),
                  child: const Icon(
                    YaruIcons.go_previous,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
