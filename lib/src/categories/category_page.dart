import 'package:app_store/src/detail/detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

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
    return ListView.builder(
      itemCount: snaps.length,
      itemBuilder: (context, index) {
        final snap = snaps[index];
        return ListTile(
          key: ValueKey(snap.id),
          title: Text(snap.name),
          subtitle: Text(snap.summary),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => DetailPage(snap: snap)),
          ),
        );
      },
    );
  }
}
