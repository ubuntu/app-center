import 'package:flutter/material.dart';

class ExpandableContainerTitle extends StatelessWidget {
  final String title;

  const ExpandableContainerTitle(this.title, {super.key});

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
