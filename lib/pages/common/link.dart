import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Link extends StatelessWidget {
  const Link(
      {required this.url, required this.linkText, this.textStyle, super.key});

  final String url;
  final String linkText;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: () async => await launchUrl(Uri.parse(url)),
      child: Text(
        linkText,
        style: textStyle ??
            Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
