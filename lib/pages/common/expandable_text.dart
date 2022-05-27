import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText(
      {Key? key,
      required this.text,
      required this.maxLines,
      required this.headerText})
      : super(key: key);

  final String text;
  final String headerText;
  final int maxLines;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => isExpanded = !isExpanded),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.headerText),
                Icon(isExpanded ? YaruIcons.pan_up : YaruIcons.pan_down)
              ],
            ),
            SizedBox(height: 10),
            isExpanded
                ? Text(widget.text)
                : Text(
                    widget.text,
                    maxLines: widget.maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
          ],
        ),
      ),
    );
  }
}
