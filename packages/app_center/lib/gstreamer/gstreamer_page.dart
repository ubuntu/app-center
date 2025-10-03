import 'package:app_center/error/error_view.dart';
import 'package:app_center/gstreamer/gstreamer.dart';
import 'package:app_center/gstreamer/gstreamer_model.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

class GStreamerPage extends ConsumerWidget {
  const GStreamerPage({required this.resources, super.key});

  final List<GstResource> resources;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return ResponsiveLayoutBuilder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: kPagePadding) +
            ResponsiveLayout.of(context).padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: kPagePadding),
            Semantics(
              focused: true,
              header: true,
              child: Text(
                l10n.codecPageTitle,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: kPagePadding),
            Text(l10n.codecPageDescription),
            const SizedBox(height: kPagePadding),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    resources.map((r) => Text('\u2022  ${r.name}')).toList(),
              ),
            ),
            const SizedBox(height: kPagePadding),
            Text(l10n.codecProprietaryDisclaimer),
            const SizedBox(height: kPagePadding),
            _GstreamerActions(resources: resources),
          ],
        ),
      ),
    );
  }
}

class _GstreamerActions extends ConsumerWidget {
  const _GstreamerActions({required this.resources});

  final List<GstResource> resources;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final gstreamer = ref.watch(gstreamerModelProvider(resources));

    return gstreamer.when(
      data: (_) => YaruSplitButton(
        onPressed: gstreamer.value == null
            ? () => ref
                .read(gstreamerModelProvider(resources).notifier)
                .installAll()
            : null,
        child: Text(l10n.codecInstallAllButton),
      ),
      error: (error, stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(gstreamerModelProvider(resources)),
      ),
      loading: SizedBox.shrink,
    );
  }
}
