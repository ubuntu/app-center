import 'package:flutter/material.dart';

class YaruExpandableTitle extends StatelessWidget {
  final String title;

  final Key? titleKey;

  const YaruExpandableTitle(
    this.title, {
    this.titleKey,
  }) : super(key: titleKey);

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
