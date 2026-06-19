import 'package:app_center/apps/app_page.dart';
import 'package:app_center/apps/app_title_bar.dart';
import 'package:app_center/constants.dart';
import 'package:app_center/error/error.dart';
import 'package:app_center/extensions/string_extensions.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/local_snap_providers.dart';
import 'package:app_center/manage/quit_to_update_notice.dart';
import 'package:app_center/ratings/ratings.dart';
import 'package:app_center/ratings/ratings_data.dart';
import 'package:app_center/snapd/snap_report.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/snapd/snapd_cache.dart';
import 'package:app_center/store/store_app.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snapd/snapd.dart';
import 'package:yaru/yaru.dart';

typedef SnapInfo = ({Widget label, Widget value});

class SnapPage extends ConsumerWidget {
  const SnapPage({required this.snapName, super.key});

  final String snapName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = ref.watch(snapModelProvider(snapName));

    final snapDataNotFound =
        snap.hasError && snap.error is SnapDataNotFoundException;
    if (snapDataNotFound) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          ref.invalidate(filteredLocalSnapsProvider);
          Navigator.pop(context);
        }
      });
      return const Center(child: YaruCircularProgressIndicator());
    }

    return snap.when(
      data: (snapData) => ResponsiveLayoutBuilder(
        builder: (_) {
          return _SnapView(snapData: snapData);
        },
      ),
      error: (error, stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(storeSnapProvider(snapName)),
      ),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

class _SnapView extends StatelessWidget {
  const _SnapView({required this.snapData});

  final SnapData snapData;

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveLayout.of(context);

    return AppPage(
      titleBar: AppTitleBar.fromSnap(
        snapData,
        actions: _IconRow(snapData: snapData),
      ),
      actionBar: _ActionBar(snapData: snapData),
      infoBar: SnapInfoBar(snapData: snapData),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (snapData.hasGallery) ...[
            ScreenshotGallery(
              title: snapData.storeSnap!.titleOrName,
              urls: snapData.storeSnap!.screenshotUrls,
              height: layout.totalWidth / 2,
            ),
            const SizedBox(height: kSectionSpacing),
          ],
          Text(
            snapData.snap.summary,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: kPagePadding),
          MarkdownBody(
            selectable: true,
            data: snapData.snap.description.escapedMarkdown(),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.snapData});

  final SnapData snapData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapLauncher = snapData.localSnap == null
        ? null
        : ref.watch(launchProvider(snapData.localSnap!));
    final primaryAction = snapData.primaryAction(snapLauncher);
    final ratingsModel = ref.watch(ratingsModelProvider(snapData.name));

    return Wrap(
      runSpacing: kSpacing,
      spacing: kSpacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (primaryAction != null)
          _PrimaryActionButton(
            snapName: snapData.name,
            isPrimary: true,
          ),
        if (snapData.isInstalled)
          ...[
            _UninstallButton(snapData: snapData),
            ratingsModel.whenOrNull(
              data: (ratingsData) => _RatingsActionButtons(
                ratingsData: ratingsData,
                snap: snapData.snap,
              ),
            ),
          ].nonNulls,
        _MoreActionsButton(snapData: snapData),
      ],
    );
  }
}

class _PrimaryActionButton extends ConsumerWidget {
  const _PrimaryActionButton({
    required this.snapName,
    required this.isPrimary,
  });

  final String snapName;
  final bool isPrimary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snapModel = ref.watch(snapModelProvider(snapName));
    if (!snapModel.hasValue) {
      return const Center(
        child: SizedBox.square(
          dimension: kLoaderMediumHeight,
          child: YaruCircularProgressIndicator(),
        ),
      );
    }

    final snapData = snapModel.value!;
    final shouldQuitToUpdate = snapData.localSnap?.refreshInhibit != null;
    final snap = snapData.snap;
    final snapViewModel = ref.watch(snapModelProvider(snap.name).notifier);
    final snapLauncher = snapData.localSnap == null
        ? null
        : ref.watch(launchProvider(snapData.localSnap!));
    final hasActiveChange = snapData.activeChangeId != null;

    final primaryAction = snapData.primaryAction(snapLauncher);

    if (hasActiveChange) {
      return ActiveChangeStatus(
        actionLabel: ref
            .watch(activeChangeProvider(snapData.activeChangeId))
            ?.localize(l10n),
        progress:
            ref
                .watch(activeChangeProvider(snapData.activeChangeId))
                ?.progress ??
            0,
        onCancelPressed: () =>
            ref.read(snapModelProvider(snap.name).notifier).cancel(),
      );
    }

    if (shouldQuitToUpdate) {
      return const QuitToUpdateNotice();
    }

    return (isPrimary ? YaruSplitButton.new : YaruSplitButton.outlined.call)(
      onPressed: snapData.activeChangeId == null
          ? primaryAction?.callback(
              snapData,
              snapViewModel,
              snapLauncher,
              context,
            )
          : null,
      child: Text(
        primaryAction?.label(l10n) ?? SnapAction.open.label(l10n),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _UninstallButton extends ConsumerWidget {
  const _UninstallButton({required this.snapData});

  final SnapData snapData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snapViewModel = ref.watch(snapModelProvider(snapData.name).notifier);

    return OutlinedButton(
      onPressed: snapData.activeChangeId == null
          ? SnapAction.remove.callback(snapData, snapViewModel, null, context)
          : null,
      child: Text(SnapAction.remove.label(l10n)),
    );
  }
}

class _MoreActionsButton extends ConsumerWidget {
  const _MoreActionsButton({required this.snapData});

  final SnapData snapData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final snapLauncher = snapData.localSnap == null
        ? null
        : ref.watch(launchProvider(snapData.localSnap!));
    final snapViewModel = ref.watch(snapModelProvider(snapData.name).notifier);

    final primaryAction = snapData.primaryAction(snapLauncher);
    final secondaryActions = snapData.secondaryActions(snapLauncher)
      ..remove(primaryAction ?? SnapAction.open);

    return secondaryActions.isNotEmpty
        ? YaruPopupMenuButton(
            showArrow: false,
            semanticLabel: l10n.appMoreActionsSemanticLabel,
            childPadding: EdgeInsets.symmetric(horizontal: 2),
            itemBuilder: (context) => [
              ...secondaryActions.map((action) {
                final color = action == SnapAction.remove
                    ? Theme.of(context).colorScheme.error
                    : null;
                return PopupMenuItem(
                  onTap: action.callback(
                    snapData,
                    snapViewModel,
                    snapLauncher,
                    context,
                  ),
                  child: IntrinsicWidth(
                    child: ListTile(
                      mouseCursor: SystemMouseCursors.click,
                      title: Text(
                        action.label(l10n),
                        style: TextStyle(color: color),
                      ),
                    ),
                  ),
                );
              }),
            ],
            onSelected: (value) => {},
            child: Icon(YaruIcons.view_more),
          )
        : const SizedBox.shrink();
  }
}

class _RatingsActionButtons extends ConsumerWidget {
  const _RatingsActionButtons({required this.ratingsData, required this.snap});

  final RatingsData ratingsData;
  final Snap snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingsNotifier = ref.watch(ratingsModelProvider(snap.name).notifier);

    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              bottomLeft: Radius.circular(6),
            ),
            onTap: () {
              ratingsNotifier.castVote(VoteStatus.up);
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                  left: BorderSide(color: Theme.of(context).dividerColor),
                  right: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 0.5,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                ),
              ),
              child: YaruIconButton(
                mouseCursor: SystemMouseCursors.click,
                icon: Icon(
                  ratingsData.voteStatus == VoteStatus.up
                      ? Icons.thumb_up
                      : Icons.thumb_up_outlined,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          ),
          InkWell(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(6),
              bottomRight: Radius.circular(6),
            ),
            onTap: () {
              ratingsNotifier.castVote(VoteStatus.down);
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                  left: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 0.5,
                  ),
                  right: BorderSide(color: Theme.of(context).dividerColor),
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: YaruIconButton(
                mouseCursor: SystemMouseCursors.click,
                icon: Icon(
                  ratingsData.voteStatus == VoteStatus.down
                      ? Icons.thumb_down
                      : Icons.thumb_down_outlined,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconRow extends ConsumerWidget {
  const _IconRow({required this.snapData});

  final SnapData snapData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snap = snapData.storeSnap ?? snapData.localSnap!;
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        if (snap.website != null)
          YaruIconButton(
            icon: Icon(
              YaruIcons.share,
              semanticLabel: l10n.snapPageShareSemanticLabel,
            ),
            onPressed: () {
              final navigationKey = ref.watch(materialAppNavigatorKeyProvider);
              final snapStoreUrl = '$snapStoreBaseUrl/${snapData.name}';

              ScaffoldMessenger.of(navigationKey.currentContext!).showSnackBar(
                SnackBar(
                  content: Text(l10n.snapPageShareLinkCopiedMessage),
                ),
              );
              Clipboard.setData(ClipboardData(text: snapStoreUrl));
            },
          ),
        YaruIconButton(
          icon: Icon(
            YaruIcons.flag,
            semanticLabel: l10n.snapPageReportSemanticLabel,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return ResponsiveLayoutBuilder(
                  builder: (context) =>
                      SnapReport(name: snapData.snap.titleOrName),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
