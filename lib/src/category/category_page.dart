import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/routes.dart';
import '/widgets.dart';
import 'category_provider.dart';

class CategoryPage extends ConsumerWidget {
  const CategoryPage({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(categoryProvider(category));
    return featured.when(
      data: (data) => SnapGrid(
        snaps: data,
        onTap: (snap) => Routes.pushDetail(context, snap.name),
      ),
      error: (error, stack) => ErrorWidget(error),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}
