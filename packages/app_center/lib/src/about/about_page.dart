import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github/github.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '/constants.dart';
import '/l10n.dart';
import '/layout.dart';
import '/widgets.dart';
import 'about_providers.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static IconData icon(bool selected) =>
      selected ? YaruIcons.question_filled : YaruIcons.question;
  static String label(BuildContext context) =>
      AppLocalizations.of(context).aboutPageLabel;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.all(kPagePadding),
          sliver: SliverToBoxAdapter(child: _AboutHeader()),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(kPagePadding),
          sliver: SliverToBoxAdapter(
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: const _ContributorView(repo: kGitHubRepo),
              ),
            ),
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.all(kPagePadding),
          sliver: SliverToBoxAdapter(child: _CommunityView()),
        ),
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.all(kPagePadding),
            child: _AboutFooter(),
          ),
        ),
      ],
    );
  }
}

class _AboutHeader extends ConsumerWidget {
  const _AboutHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/app-center.png'),
        const SizedBox(width: 32),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kAppName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ref.watch(versionProvider).maybeWhen(
                  data: (v) => Text(l10n.aboutPageVersionLabel(v)),
                  orElse: () => const SizedBox.shrink(),
                ),
          ],
        ),
      ],
    );
  }
}

class _AboutFooter extends StatelessWidget {
  const _AboutFooter();

  @override
  Widget build(BuildContext context) {
    // TODO: terms and conditions, privacy policy
    return Align(
      alignment: AlignmentDirectional.bottomStart,
      child: MarkdownBody(
        data: '©️ ${DateTime.now().year} Canonical Ltd.',
      ),
    );
  }
}

class _ContributorView extends ConsumerWidget {
  const _ContributorView({required this.repo});

  final String repo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(contributorsProvider(repo));
    final light = Theme.of(context).brightness == Brightness.light;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.aboutPageContributorTitle),
        const SizedBox(height: 8),
        state.when(
          data: (contributors) => _ContributorWrap(contributors),
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => Shimmer.fromColors(
            baseColor: light ? kShimmerBaseLight : kShimmerBaseDark,
            highlightColor:
                light ? kShimmerHighLightLight : kShimmerHighLightDark,
            child: _ContributorWrap(List<Contributor?>.filled(36, null)),
          ),
        ),
      ],
    );
  }
}

class _ContributorWrap extends StatelessWidget {
  const _ContributorWrap(this.contributors);

  final List<Contributor?> contributors;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final contributor in contributors)
          Tooltip(
            message: contributor?.login ?? '',
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: contributor?.htmlUrl != null
                  ? () => launchUrlString(contributor?.htmlUrl ?? '')
                  : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AppIcon(
                  iconUrl: contributor?.avatarUrl,
                  size: 32,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CommunityView extends StatelessWidget {
  const _CommunityView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.aboutPageCommunityTitle),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _CommunityTile(
                title: l10n.aboutPageContributeLabel,
                subtitle: l10n.aboutPageGitHubLabel,
                href: 'https://github.com/$kGitHubRepo',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CommunityTile extends StatelessWidget {
  const _CommunityTile({
    required this.title,
    required this.subtitle,
    required this.href,
  });

  final String title;
  final String subtitle;
  final String href;

  @override
  Widget build(BuildContext context) {
    return YaruTile(
      // TODO: icon
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: MarkdownBody(
        data: '[$subtitle]($href)',
        onTapLink: (_, href, __) => launchUrlString(href!),
      ),
      padding: EdgeInsets.zero,
    );
  }
}
