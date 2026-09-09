import 'package:app_center/drivers/drivers.dart';
import 'package:app_center/l10n.dart';
import 'package:app_center/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:yaru/yaru.dart';

/// Shows a confirmation dialog before uninstalling the driver installed for
/// the device at [sysPath].
Future<void> showDriverUninstallDialog(
  BuildContext context,
  String sysPath,
) => showDialog(
  context: context,
  builder: (_) => DriverUninstallDialog(sysPath: sysPath),
);

class DriverUninstallDialog extends ConsumerStatefulWidget {
  const DriverUninstallDialog({required this.sysPath, super.key});

  final String sysPath;

  @override
  ConsumerState<DriverUninstallDialog> createState() =>
      _DriverUninstallDialogState();
}

class _DriverUninstallDialogState extends ConsumerState<DriverUninstallDialog> {
  bool _acknowledged = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SimpleDialog(
      contentPadding: const EdgeInsets.all(20),
      titlePadding: EdgeInsets.zero,
      title: YaruDialogTitleBar(
        title: Text(l10n.driversPageUninstallTitle),
      ),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: kMaxDialogWidth,
            maxWidth: kMaxDialogWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              YaruInfoBox(
                yaruInfoType: YaruInfoType.warning,
                title: Text(l10n.driversPageUninstallWarningTitle),
                subtitle: Text(l10n.driversPageUninstallWarningMessage),
              ),
              const SizedBox(height: kSpacing),
              CheckboxListTile(
                value: _acknowledged,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (value) =>
                    setState(() => _acknowledged = value ?? false),
                title: Text(l10n.driversPageUninstallAcknowledgeLabel),
              ),
              const SizedBox(height: kPagePadding),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PushButton.outlined(
                    onPressed: _acknowledged
                        ? () {
                            ref
                                .read(
                                  driverModelProvider(widget.sysPath).notifier,
                                )
                                .uninstall();
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: Text(l10n.snapActionRemoveLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
