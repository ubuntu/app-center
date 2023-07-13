import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/l10n.dart';
import '/store.dart';
import '/widgets.dart';
import 'explore_provider.dart';

class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  static IconData get icon => Icons.explore;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).explorePageLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredProvider);
    return featured.when(
      data: (data) => SnapGrid(
        snaps: data,
        onTap: (snap) => StoreRouter.pushDetail(context, snap.name),
      ),
      error: (error, stack) => ErrorWidget(error),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}
