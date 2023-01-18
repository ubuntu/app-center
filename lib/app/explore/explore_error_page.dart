import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/app/explore/explore_model.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class ExploreErrorPage extends StatelessWidget {
  const ExploreErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final errorMessage = context.select((ExploreModel m) => m.errorMessage);

    return ListView(
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
  }
}
