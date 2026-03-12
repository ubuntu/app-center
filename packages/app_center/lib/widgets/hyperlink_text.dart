import 'package:app_center/constants.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:yaru/yaru.dart';

/// A [Text] widget formatted as an accessible hyperlink.
class HyperlinkText extends StatelessWidget {
  const HyperlinkText({required this.text, required this.link, super.key});

  /// The data of the [Text] underlying widget.
  final String text;

  /// URL to open on click.
  final String link;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final hyperlinkColor = MediaQuery.highContrastOf(context)
        ? theme.colorScheme.primary
        : brightness == Brightness.dark
            ? kHyperlinkDark
            : kHyperlinkLight;
    final textStyle = DefaultTextStyle.of(context);

    return YaruFocusBorder(
      child: Semantics(
        link: true,
        child: InkWell(
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onTap: () => launchUrlString(link),
          child: Text(
            text,
            style: textStyle.style.copyWith(
              color: hyperlinkColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}
