import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
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
      data: (data) => _CategoryView(data),
      error: (error, stack) => ErrorWidget(error),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _CategoryView extends ConsumerWidget {
  const _CategoryView(this.snaps);

  final List<Snap> snaps;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(kYaruPagePadding),
      gridDelegate: kGridDelegate,
      itemCount: snaps.length,
      itemBuilder: (context, index) {
        final snap = snaps[index];
        return SnapCard(
          key: ValueKey(snap.id),
          snap: snap,
          onTap: () =>
              Navigator.pushNamed(context, Routes.detail, arguments: snap),
        );
      },
    );
  }
}
