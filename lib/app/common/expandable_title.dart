import 'package:flutter/material.dart';

class YaruExpandableTitle extends StatelessWidget {
  final String title;

  const YaruExpandableTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 17),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}
