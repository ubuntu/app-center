import 'package:app_center/apps/app_details_state.dart';
import 'package:app_center/apps/apps_utils.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/mapping/package_source_descriptor.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yaru/yaru.dart';

const kMissingValue = '—';

String formatAppDate(DateTime date) => DateFormat.yMMMd().format(date);

extension ActionKindL10n on ActionKind {
  String localize(AppLocalizations l10n) => switch (this) {
    ActionKind.install => l10n.snapActionInstallLabel,
    ActionKind.update => l10n.snapActionUpdateLabel,
    ActionKind.open => l10n.snapActionOpenLabel,
    ActionKind.uninstall => l10n.snapActionRemoveLabel,
    ActionKind.switchChannel => l10n.snapActionSwitchChannelLabel,
    ActionKind.cancel => l10n.snapActionCancelLabel,
  };
}

extension OperationKindL10n on OperationKind {
  String localize(AppLocalizations l10n) => switch (this) {
    OperationKind.install => l10n.snapActionInstallingLabel,
    OperationKind.update => l10n.snapActionUpdatingLabel,
    OperationKind.remove => l10n.snapActionRemovingLabel,
    OperationKind.switchChannel => l10n.snapActionSwitchChannelLabel,
  };
}

extension PackageFormatL10n on PackageFormat {
  String localize(AppLocalizations l10n) => switch (this) {
    PackageFormat.snap => l10n.managePagePackageTypeSnap,
    PackageFormat.deb => l10n.managePagePackageTypeDeb,
  };
}

extension PublisherValidationL10n on PublisherValidation {
  String? localize(AppLocalizations l10n) => switch (this) {
    PublisherValidation.verified =>
      l10n.appDetailsVerifiedPublisherSemanticLabel,
    PublisherValidation.starred => l10n.appDetailsStarredPublisherSemanticLabel,
    PublisherValidation.none => null,
  };

  String? localizeTooltip(AppLocalizations l10n) => switch (this) {
    PublisherValidation.verified => l10n.appDetailsVerifiedPublisherTooltip,
    PublisherValidation.starred => l10n.appDetailsStarredPublisherTooltip,
    PublisherValidation.none => null,
  };
}

class ConfinementLabel extends StatelessWidget {
  const ConfinementLabel(this.confinement, {super.key});

  final AppConfinement confinement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Tooltip(
      constraints: const BoxConstraints(maxWidth: 200),
      message: confinement.localizeTooltip(l10n) ?? '',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (confinement == AppConfinement.strict) ...const [
            Icon(YaruIcons.shield, size: 12),
            SizedBox(width: 2),
          ],
          Text(confinement.localize(l10n)),
        ],
      ),
    );
  }
}

/// Publisher validation icon with a tooltip explaining what it means.
class PublisherBadge extends StatefulWidget {
  const PublisherBadge(
    this.validation, {
    this.size,
    this.focusable = false,
    super.key,
  });

  final PublisherValidation validation;
  final double? size;

  /// Whether keyboard focus can reach the badge to show its tooltip.
  final bool focusable;

  @override
  State<PublisherBadge> createState() => _PublisherBadgeState();
}

class _PublisherBadgeState extends State<PublisherBadge> {
  final _tooltipKey = GlobalKey<TooltipState>();

  void _onFocusChange(bool focused) {
    if (focused) {
      _tooltipKey.currentState?.ensureTooltipVisible();
    } else {
      Tooltip.dismissAllToolTips();
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.validation.localizeTooltip(
      AppLocalizations.of(context),
    );
    if (message == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final verified = widget.validation == PublisherValidation.verified;
    final badge = Tooltip(
      key: _tooltipKey,
      message: message,
      constraints: const BoxConstraints(maxWidth: 200),
      // The icon's semantic label already reads out the message.
      excludeFromSemantics: true,
      child: Icon(
        verified ? Icons.verified : Icons.stars,
        size: widget.size,
        semanticLabel: message,
        color: MediaQuery.highContrastOf(context)
            ? theme.hintColor
            : verified
            ? theme.colorScheme.success
            : theme.colorScheme.warning,
      ),
    );

    if (!widget.focusable) return badge;
    return YaruFocusBorder.primary(
      child: Focus(onFocusChange: _onFocusChange, child: badge),
    );
  }
}
