import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PreviewBanner extends StatefulWidget {
  const PreviewBanner({
    super.key,
    required this.title,
    this.onTap,
    this.padding = const EdgeInsets.all(kYaruPagePadding),
    this.subtitle,
    required this.subTitle,
    this.icon,
    required this.description,
    required this.controlWidget,
  });

  final String title;
  final String subTitle;
  final String description;
  final void Function()? onTap;
  final EdgeInsets padding;
  final Widget? subtitle;
  final Widget? icon;
  final Widget controlWidget;

  @override
  State<PreviewBanner> createState() => _PreviewBannerState();
}

class _PreviewBannerState extends State<PreviewBanner> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final title = Text(
      widget.title,
      overflow: TextOverflow.ellipsis,
    );

    return YaruBanner.tile(
      padding: _hovered
          ? const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10)
          : widget.padding,
      onHover: (hovered) => setState(() => _hovered = hovered),
      title: title,
      subtitle: _hovered
          ? Text(
              widget.description,
              overflow: TextOverflow.ellipsis,
            )
          : (widget.subtitle ??
              Text(
                widget.subTitle,
                overflow: TextOverflow.ellipsis,
              )),
      icon: _hovered ? widget.controlWidget : widget.icon,
      onTap: widget.onTap,
    );
  }
}
