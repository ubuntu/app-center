import 'package:flutter/material.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AdditionalInformation extends StatelessWidget {
  const AdditionalInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return YaruExpandable(
      header: Text(
        context.l10n.additionalInformation,
        style: Theme.of(context).textTheme.headline6,
      ),
      child: SizedBox(
        height: 500,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: GridView(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisExtent: 100,
            ),
            children: const [],
          ),
        ),
      ),
    );
  }
}
