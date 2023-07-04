import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/routes.dart';
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
      data: (data) => _ExploreView(data),
      error: (error, stack) => ErrorWidget(error),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _ExploreView extends ConsumerWidget {
  const _ExploreView(this.snaps);

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
          onTap: () =>
              Navigator.pushNamed(context, Routes.detail, arguments: snap),
        );
      },
    );
  }
}
