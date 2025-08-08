import 'package:app_center/constants.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// A [Text] widget formatted as an accessible hyperlink.
class HyperlinkText extends StatefulWidget {
  const HyperlinkText({required this.text, required this.link, super.key});

  /// The data of the [Text] underlying widget.
  final String text;

  /// URL to open on click.
  final String link;

  @override
  State<HyperlinkText> createState() => _HyperlinkTextState();
}

class _HyperlinkTextState extends State<HyperlinkText> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final hyperlinkColor = MediaQuery.highContrastOf(context)
        ? theme.colorScheme.primary
        : brightness == Brightness.dark
            ? kHyperlinkDark
            : kHyperlinkLight;

    return Semantics(
      link: true,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: focused ? theme.primaryColor : Colors.transparent,
              width: 2,
              strokeAlign: 2,
            ),
          ),
        ),
        child: InkWell(
          onTap: () async {
            await launchUrlString(widget.link);
          },
          focusColor: Colors.transparent,
          onFocusChange: (value) {
            setState(() {
              focused = value;
            });
          },
          child: Text(
            widget.text,
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: hyperlinkColor,
            ),
          ),
        ),
      ),
    );
  }
}
