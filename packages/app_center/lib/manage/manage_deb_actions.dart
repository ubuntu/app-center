import 'package:app_center/constants.dart';
import 'package:app_center/deb/deb_model.dart';
import 'package:app_center/deb/deb_providers.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/manage/deb_updates_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

/// Actions for a deb package in the manage page.
class ManageDebActions extends ConsumerWidget {
  const ManageDebActions({
    required this.debId,
    this.showOnlyUpdate = false,
    super.key,
  });

  final String debId;
  final bool showOnlyUpdate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final debModel = ref.watch(debModelProvider(debId));
    final updateInfo = ref.watch(debUpdateInfoProvider(debId));

    if (!debModel.hasValue) {
      return const SizedBox.square(
        dimension: kLoaderMediumHeight,
        child: YaruCircularProgressIndicator(),
      );
    }

    final debData = debModel.value!;
    final hasActiveTransaction = debData.activeTransactionId != null;

    if (hasActiveTransaction) {
      return _ActiveTransactionStatus(
        debId: debId,
        activeTransactionId: debData.activeTransactionId!,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (updateInfo != null && updateInfo.updatePackageId != null)
          OutlinedButton(
            onPressed: () => ref
                .read(debModelProvider(debId).notifier)
                .updateDeb(updateInfo.updatePackageId!),
            child: Text(l10n.snapActionUpdateLabel),
          ),
        if (!showOnlyUpdate) ...[
          if (updateInfo != null) const SizedBox(width: kSpacing),
          OutlinedButton(
            onPressed: () =>
                ref.read(debModelProvider(debId).notifier).removeDeb(),
            child: Text(
              l10n.snapActionRemoveLabel,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ],
    );
  }
}

/// Shows transaction progress with a cancel button.
class _ActiveTransactionStatus extends ConsumerStatefulWidget {
  const _ActiveTransactionStatus({
    required this.debId,
    required this.activeTransactionId,
  });

  final String debId;
  final int activeTransactionId;

  @override
  ConsumerState<_ActiveTransactionStatus> createState() =>
      _ActiveTransactionStatusState();
}

class _ActiveTransactionStatusState
    extends ConsumerState<_ActiveTransactionStatus> {
  bool isCancelling = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final transaction =
        ref.watch(transactionProvider(widget.activeTransactionId)).valueOrNull;
    final percentage = transaction?.percentage ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: kLoaderHeight,
          child: YaruCircularProgressIndicator(
            value: percentage / 100.0,
            strokeWidth: 2,
          ),
        ),
        const SizedBox(width: kSpacingSmall),
        Text(
          l10n.snapActionUpdatingLabel,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: kSpacing),
        OutlinedButton(
          onPressed: isCancelling
              ? null
              : () {
                  setState(() => isCancelling = true);
                  ref
                      .read(debModelProvider(widget.debId).notifier)
                      .cancelTransaction();
                },
          child: Text(l10n.snapActionCancelLabel),
        ),
      ],
    );
  }
}
