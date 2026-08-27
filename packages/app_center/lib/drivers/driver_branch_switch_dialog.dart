import 'package:app_center/drivers/drivers.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru/yaru.dart';

/// Shows the "Switch branch" dialog for the device at [sysPath], letting the
/// user install a driver package (if none is installed yet) or switch the
/// currently-installed package to a different [DriverBranch].
Future<void> showDriverBranchSwitchDialog(
  BuildContext context,
  String sysPath,
) => showDialog(
  context: context,
  builder: (_) => DriverBranchSwitchDialog(sysPath: sysPath),
);

class DriverBranchSwitchDialog extends ConsumerStatefulWidget {
  const DriverBranchSwitchDialog({required this.sysPath, super.key});

  final String sysPath;

  @override
  ConsumerState<DriverBranchSwitchDialog> createState() =>
      _DriverBranchSwitchDialogState();
}

class _DriverBranchSwitchDialogState
    extends ConsumerState<DriverBranchSwitchDialog> {
  DriverBranch? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final deviceState = ref.watch(driverModelProvider(widget.sysPath));

    return deviceState.when(
      data: (data) {
        final info = data.info;
        final options = info.branchOptions;
        final installedOption = info.installedOption;

        final fallbackBranch = options
            .firstWhere((o) => o.recommended, orElse: () => options.first)
            .branch;
        _selected ??=
            (installedOption != null && installedOption.branch.isSelectable)
            ? installedOption.branch
            : fallbackBranch;

        final selectedOption = options.firstWhere(
          (o) => o.branch == _selected,
        );
        final showLessStableWarning =
            installedOption != null &&
            selectedOption.branch.stabilityRank <
                installedOption.branch.stabilityRank;

        return SimpleDialog(
          contentPadding: const EdgeInsets.all(20),
          titlePadding: EdgeInsets.zero,
          title: YaruDialogTitleBar(
            title: Text(l10n.driversPageSwitchBranchTitle),
          ),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kMaxDialogWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioGroup<DriverBranch>(
                    groupValue: _selected,
                    onChanged: (branch) => setState(() => _selected = branch),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final option in options)
                          _BranchOptionTile(
                            option: option,
                            installed: installedOption != null,
                          ),
                      ],
                    ),
                  ),
                  if (showLessStableWarning) ...[
                    const SizedBox(height: kSpacing),
                    _LessStableWarning(l10n: l10n),
                  ],
                  const SizedBox(height: kPagePadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (installedOption == null)
                        PushButton.elevated(
                          onPressed: () {
                            ref
                                .read(
                                  driverModelProvider(widget.sysPath).notifier,
                                )
                                .install(selectedOption.packageName);
                            Navigator.of(context).pop();
                          },
                          child: Text(l10n.snapActionInstallLabel),
                        )
                      else
                        PushButton.outlined(
                          onPressed:
                              selectedOption.branch != installedOption.branch
                              ? () {
                                  ref
                                      .read(
                                        driverModelProvider(
                                          widget.sysPath,
                                        ).notifier,
                                      )
                                      .switchBranch(selectedOption.packageName);
                                  Navigator.of(context).pop();
                                }
                              : null,
                          child: Text(l10n.driversPageSwitchLabel),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}

class _BranchOptionTile extends StatelessWidget {
  const _BranchOptionTile({
    required this.option,
    required this.installed,
  });

  final DriverBranchOption option;
  final bool installed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = option.recommended
        ? l10n.driversPageSwitchBranchRecommendedLabel(
            _branchLabel(l10n, option.branch),
          )
        : _branchLabel(l10n, option.branch);

    final descriptionParts = [_branchDescription(l10n, option.branch)];
    if (!installed && option.version != null) {
      descriptionParts.add(l10n.driversPageVersionLabel(option.version!));
    }

    return RadioListTile<DriverBranch>(
      value: option.branch,
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label),
      subtitle: Text(descriptionParts.join(' \u00b7 ')),
    );
  }
}

class _LessStableWarning extends StatelessWidget {
  const _LessStableWarning({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return YaruInfoBox(
      yaruInfoType: YaruInfoType.warning,
      title: Text(l10n.driversPageSwitchBranchLessStableWarningTitle),
      subtitle: Text(l10n.driversPageSwitchBranchLessStableWarningMessage),
    );
  }
}

String _branchLabel(AppLocalizations l10n, DriverBranch branch) =>
    switch (branch) {
      DriverBranch.production => l10n.driversPageBranchProduction,
      DriverBranch.lts => l10n.driversPageBranchLts,
      DriverBranch.newFeature => l10n.driversPageBranchNewFeature,
      DriverBranch.legacy || DriverBranch.unknown => '',
    };

String _branchDescription(
  AppLocalizations l10n,
  DriverBranch branch,
) => switch (branch) {
  DriverBranch.production => l10n.driversPageSwitchBranchProductionDescription,
  DriverBranch.lts => l10n.driversPageSwitchBranchLtsDescription,
  DriverBranch.newFeature => l10n.driversPageSwitchBranchNewFeatureDescription,
  DriverBranch.legacy || DriverBranch.unknown => '',
};
