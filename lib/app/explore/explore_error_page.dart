import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/app/common/search_field.dart';
import 'package:software/app/explore/explore_header.dart';
import 'package:software/app/explore/explore_model.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class ExploreErrorPage extends StatelessWidget {
  const ExploreErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchQuery = context.select((ExploreModel m) => m.searchQuery);
    final setSearchQuery = context.read<ExploreModel>().setSearchQuery;
    final errorMessage = context.select((ExploreModel m) => m.errorMessage);

    final page = ListView(
      padding: const EdgeInsets.all(kYaruPagePadding),
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SelectableText(
              errorMessage ?? '',
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        )
      ],
    );

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: SearchField(
          searchQuery: searchQuery,
          onChanged: setSearchQuery,
        ),
      ),
      body: Column(
        children: [const ExploreHeader(), Expanded(child: page)],
      ),
    );
  }
}
