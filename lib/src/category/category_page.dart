import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/layout.dart';
import '/snapd.dart';
import '/store.dart';
import '/widgets.dart';
import 'category_provider.dart';

class CategoryPage extends ConsumerWidget {
  const CategoryPage({super.key, required this.category});

  final SnapCategoryEnum category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(categoryProvider(category));
    return featured.when(
      data: (data) => Padding(
        padding: const EdgeInsets.symmetric(vertical: kPagePadding),
        child: ResponsiveLayoutScrollView(
          slivers: [
            SnapGrid(
              snaps: data,
              onTap: (snap) =>
                  StoreNavigator.pushDetail(context, name: snap.name),
            ),
          ],
        ),
      ),
      error: (error, stack) => ErrorWidget(error),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}
