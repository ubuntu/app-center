import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key, this.query});

  final String? query;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const YaruBackButton(),
        Padding(
          padding: const EdgeInsets.all(kYaruPagePadding),
          child: Text('Search results for: $query'),
        ),
      ],
    );
  }
}
