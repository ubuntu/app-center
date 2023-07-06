import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/l10n.dart';
import 'about_provider.dart';

Future<void> showAboutDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => const AboutDialog(),
  );
}

class AboutDialog extends ConsumerWidget {
  const AboutDialog({super.key});

  static IconData get icon => YaruIcons.question;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).aboutDialogLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      clipBehavior: Clip.antiAlias,
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      title: YaruDialogTitleBar(title: Text(l10n.aboutDialogTitle)),
      content: const SizedBox(
        width: 500,
        child: _ContributorListView(repo: 'ubuntu/software'),
      ),
    );
  }
}

class _ContributorListView extends ConsumerWidget {
  const _ContributorListView({required this.repo});

  final String repo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(contributorsProvider(repo));
    return state.when(
      data: (contributors) => ListView.separated(
        padding: const EdgeInsets.all(kYaruPagePadding),
        itemCount: contributors.length,
        itemBuilder: (context, index) {
          final contributor = contributors[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: contributor.avatarUrl != null
                  ? NetworkImage(contributor.avatarUrl!)
                  : null,
            ),
            title: Text(contributor.login ?? ''),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: kYaruPagePadding),
      ),
      error: (error, stackTrace) => ErrorWidget(error),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}
