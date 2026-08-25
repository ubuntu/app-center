import 'package:app_center/constants.dart';
import 'package:app_center/drivers/drivers.dart';
import 'package:app_center/error/error.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/packagekit/packagekit.dart';
import 'package:app_center/widgets/widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

/// Lists detected hardware devices and lets the user install, update, or
/// uninstall their driver packages.
class DriversPage extends ConsumerWidget {
  const DriversPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverList = ref.watch(driverListModelProvider);
    final l10n = AppLocalizations.of(context);

    return driverList.when(
      data: (data) => data.sysPaths.isEmpty
          ? _DriversMessageView(message: l10n.driversPageNoDriversFoundMessage)
          : _DriversView(driverList: data),
      error: (error, stackTrace) => error is DriversServiceUnavailableException
          ? _DriversMessageView(message: l10n.driversPageUnsupportedMessage)
          : ErrorView(
              error: error,
              onRetry: () =>
                  ref.read(driverListModelProvider.notifier).refresh(),
            ),
      loading: () => const Center(child: YaruCircularProgressIndicator()),
    );
  }
}

/// A simple centered message.
class _DriversMessageView extends StatelessWidget {
  const _DriversMessageView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kPagePadding),
      child: Align(
        alignment: AlignmentDirectional.topCenter,
        child: Text(
          message,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).hintColor),
        ),
      ),
    );
  }
}

class _DriversView extends StatelessWidget {
  const _DriversView({required this.driverList});

  final DriverList driverList;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final devicesBySection = <DriverSection, List<DriverDeviceInfo>>{
      for (final section in DriverSection.values) section: [],
    };
    for (final sysPath in driverList.sysPaths) {
      final info = driverList.byPath[sysPath];
      if (info == null) continue;
      devicesBySection[info.section]!.add(info);
    }

    return ResponsiveLayoutScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(kPagePadding),
          sliver: SliverList.list(
            children: [
              Semantics(
                header: true,
                focused: true,
                child: Text(
                  l10n.addonsPageAdditionalDriversTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: kPagePadding),
              Text(l10n.driversPageDescription),
              const SizedBox(height: kSectionSpacing),
              _DriverSection(
                title: l10n.driversPageSectionUpdateAvailable,
                devices: devicesBySection[DriverSection.updateAvailable]!,
              ),
              _DriverSection(
                title: l10n.driversPageSectionAvailable,
                devices: devicesBySection[DriverSection.available]!,
              ),
              _DriverSection(
                title: l10n.driversPageSectionInstalled,
                devices: devicesBySection[DriverSection.installed]!,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DriverSection extends StatelessWidget {
  const _DriverSection({required this.title, required this.devices});

  final String title;
  final List<DriverDeviceInfo> devices;

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) return const SizedBox.shrink();

    final outline = Theme.of(context).colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.only(bottom: kSectionSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: kMarginLarge),
          YaruBorderContainer(
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: devices
                  .mapIndexed(
                    (index, device) => DecoratedBox(
                      decoration: BoxDecoration(
                        border: index == 0
                            ? null
                            : Border(top: BorderSide(color: outline)),
                      ),
                      child: _DriverDeviceTile(sysPath: device.sysPath),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverDeviceTile extends ConsumerWidget {
  const _DriverDeviceTile({required this.sysPath});

  final String sysPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceState = ref.watch(driverModelProvider(sysPath));

    return deviceState.when(
      data: (data) => YaruListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Icon(_iconFor(data.info.deviceClass), size: 32),
        title: Text(
          data.info.model.isNotEmpty ? data.info.model : data.info.vendor,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _subtitleFor(context, data.info),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IntrinsicWidth(
          child: _DriverDeviceActions(sysPath: sysPath, state: data),
        ),
      ),
      error: (error, stackTrace) => YaruListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(error.toString()),
      ),
      loading: () => YaruListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: const SizedBox.shrink(),
        trailing: const SizedBox.square(
          dimension: kLoaderMediumHeight,
          child: YaruCircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _DriverDeviceActions extends ConsumerWidget {
  const _DriverDeviceActions({required this.sysPath, required this.state});

  final String sysPath;
  final DriverDeviceState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final model = ref.read(driverModelProvider(sysPath).notifier);
    final isBusyElsewhere = ref.watch(driversBusyProvider);
    final canOperate = !state.isBusy && !isBusyElsewhere;

    if (state.isBusy) {
      final progress = ref.watch(
        packageKitTransactionProgressProvider(state.activeTransactionId),
      );
      return ActiveChangeStatus(
        actionLabel: _busyLabelFor(l10n, state),
        progress: progress ?? 0,
        onCancelPressed: model.cancel,
      );
    }

    if (state.error != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            YaruIcons.error,
            color: Theme.of(context).colorScheme.error,
            size: 16,
          ),
          const SizedBox(width: kSpacingSmall),
          Text(l10n.driversPageErrorLabel),
          const SizedBox(width: kSpacing),
          OutlinedButton(
            onPressed: _retryAction(model, state.info, canOperate),
            child: Text(l10n.driversPageRetryLabel),
          ),
        ],
      );
    }

    if (state.requiresRestart) {
      return OutlinedButton(
        onPressed: () => _showRestartRequiredMessage(context, l10n),
        child: Text(l10n.driversPageRestartLabel),
      );
    }

    final installedOption = state.info.installedOption;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (installedOption != null && installedOption.hasUpdate)
          OutlinedButton(
            onPressed: canOperate ? model.updateDriver : null,
            child: Text(l10n.snapActionUpdateLabel),
          )
        else if (installedOption == null)
          OutlinedButton(
            onPressed: canOperate
                ? () => state.info.hasBranchChoice
                      ? showDriverBranchSwitchDialog(context, sysPath)
                      : model.install(
                          _recommendedOption(state.info).packageName,
                        )
                : null,
            child: Text(l10n.snapActionInstallLabel),
          ),
        if (installedOption != null) ...[
          const SizedBox(width: kSpacing),
          _MoreActionsButton(
            canOperate: canOperate,
            showSwitchBranch: state.info.hasBranchChoice,
            onSwitchBranch: () =>
                showDriverBranchSwitchDialog(context, sysPath),
            onUninstall: model.uninstall,
          ),
        ],
      ],
    );
  }
}

class _MoreActionsButton extends StatelessWidget {
  const _MoreActionsButton({
    required this.canOperate,
    required this.showSwitchBranch,
    required this.onSwitchBranch,
    required this.onUninstall,
  });

  final bool canOperate;
  final bool showSwitchBranch;
  final VoidCallback onSwitchBranch;
  final VoidCallback onUninstall;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return YaruPopupMenuButton<_DriverMenuAction>(
      showArrow: false,
      semanticLabel: l10n.appMoreActionsSemanticLabel,
      childPadding: const EdgeInsets.symmetric(horizontal: 2),
      itemBuilder: (context) => [
        if (showSwitchBranch)
          PopupMenuItem(
            value: _DriverMenuAction.switchBranch,
            enabled: canOperate,
            child: IntrinsicWidth(
              child: ListTile(
                mouseCursor: SystemMouseCursors.click,
                enabled: canOperate,
                title: Text(l10n.driversPageSwitchBranchLabel),
              ),
            ),
          ),
        PopupMenuItem(
          value: _DriverMenuAction.uninstall,
          enabled: canOperate,
          child: IntrinsicWidth(
            child: ListTile(
              mouseCursor: SystemMouseCursors.click,
              enabled: canOperate,
              title: Text(l10n.snapActionRemoveLabel),
            ),
          ),
        ),
      ],
      onSelected: (action) {
        switch (action) {
          case _DriverMenuAction.switchBranch:
            onSwitchBranch();
          case _DriverMenuAction.uninstall:
            onUninstall();
        }
      },
      child: const Icon(YaruIcons.view_more),
    );
  }
}

enum _DriverMenuAction { switchBranch, uninstall }

void _showRestartRequiredMessage(BuildContext context, AppLocalizations l10n) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.driversPageRestartRequiredMessage)),
  );
}

String _busyLabelFor(AppLocalizations l10n, DriverDeviceState state) =>
    switch (state.activeActionKind) {
      DriverActionKind.install => l10n.snapActionInstallingLabel,
      DriverActionKind.update => l10n.snapActionUpdatingLabel,
      DriverActionKind.uninstall => l10n.snapActionRemovingLabel,
      DriverActionKind.switchBranch => l10n.driversPageSwitchingBranchLabel,
      null => l10n.snapActionInstallingLabel,
    };

VoidCallback? _retryAction(
  DriverModel model,
  DriverDeviceInfo info,
  bool canOperate,
) {
  if (!canOperate) return null;
  final installed = info.installedOption;
  if (installed == null) {
    return () => model.install(_recommendedOption(info).packageName);
  }
  if (installed.hasUpdate) return model.updateDriver;
  return model.uninstall;
}

DriverBranchOption _recommendedOption(DriverDeviceInfo info) =>
    info.options.firstWhereOrNull((o) => o.recommended) ?? info.options.first;

String _subtitleFor(BuildContext context, DriverDeviceInfo info) {
  final l10n = AppLocalizations.of(context);
  final relevant =
      info.installedOption ??
      info.options.firstWhereOrNull((o) => o.recommended) ??
      info.options.firstOrNull;

  final parts = [_deviceClassLabel(l10n, info.deviceClass)];
  final branchLabel = relevant != null
      ? _branchLabel(l10n, relevant.branch)
      : null;
  if (branchLabel != null) parts.add(branchLabel);
  if (relevant?.version != null) {
    parts.add(l10n.driversPageVersionLabel(relevant!.version!));
  }
  return parts.join(' \u00b7 ');
}

String _deviceClassLabel(
  AppLocalizations l10n,
  DriverDeviceClass deviceClass,
) => switch (deviceClass) {
  DriverDeviceClass.graphics => l10n.driversPageDeviceClassGraphics,
  DriverDeviceClass.network => l10n.driversPageDeviceClassNetwork,
  DriverDeviceClass.camera => l10n.driversPageDeviceClassCamera,
  DriverDeviceClass.usb => l10n.driversPageDeviceClassUsb,
  DriverDeviceClass.storage => l10n.driversPageDeviceClassStorage,
  DriverDeviceClass.audio => l10n.driversPageDeviceClassAudio,
  DriverDeviceClass.other => l10n.driversPageDeviceClassOther,
};

String? _branchLabel(AppLocalizations l10n, DriverBranch branch) =>
    switch (branch) {
      DriverBranch.production => l10n.driversPageBranchProduction,
      DriverBranch.lts => l10n.driversPageBranchLts,
      DriverBranch.newFeature => l10n.driversPageBranchNewFeature,
      DriverBranch.legacy || DriverBranch.unknown => null,
    };

IconData _iconFor(DriverDeviceClass deviceClass) => switch (deviceClass) {
  DriverDeviceClass.graphics => YaruIcons.chip,
  DriverDeviceClass.network => YaruIcons.network_wired,
  DriverDeviceClass.camera => YaruIcons.camera_web,
  DriverDeviceClass.usb => YaruIcons.usb_stick,
  DriverDeviceClass.storage => YaruIcons.drive_harddisk_usb,
  DriverDeviceClass.audio => YaruIcons.audio_card,
  DriverDeviceClass.other => YaruIcons.chip,
};
