import 'package:collection/collection.dart';
import 'package:data_size/data_size.dart';
import 'package:flutter/material.dart';
import 'package:software/app/common/border_container.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import 'package_model.dart';

class InstallDepsDialog extends StatelessWidget {
  final VoidCallback onInstall;
  final String packageName;
  final List<PackageDependecy> dependencies;

  const InstallDepsDialog({
    super.key,
    required this.onInstall,
    required this.packageName,
    required this.dependencies,
  });

  @override
  Widget build(BuildContext context) {
    return _DepsDialog(
      onConfirm: onInstall,
      dependencies: dependencies,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.dependenciesInstallListing(
              dependencies.length,
              dependencies.map((d) => d.size).sum.formatByteSize(),
              packageName,
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            context.l10n.dependenciesQuestion,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      confirmLabel: context.l10n.install,
      packageName: packageName,
    );
  }
}

class RemoveDepsDialog extends StatefulWidget {
  final void Function(bool) onRemove;
  final String packageName;
  final List<PackageDependecy> dependencies;

  const RemoveDepsDialog({
    super.key,
    required this.onRemove,
    required this.packageName,
    required this.dependencies,
  });

  @override
  State<RemoveDepsDialog> createState() => _RemoveDepsDialogState();
}

class _RemoveDepsDialogState extends State<RemoveDepsDialog> {
  bool autoremove = true;
  @override
  Widget build(BuildContext context) {
    return _DepsDialog(
      onConfirm: () => widget.onRemove(autoremove),
      dependencies: widget.dependencies,
      body: Text(
        context.l10n.dependenciesRemoveListing(
          widget.dependencies.length,
          widget.dependencies.map((d) => d.size).sum.formatByteSize(),
          widget.packageName,
        ),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      footer: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            YaruCheckbox(
              value: autoremove,
              onChanged: (value) => setState(() => autoremove = value ?? true),
            ),
            Text(
              context.l10n.dependenciesAutoremove,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      confirmLabel: autoremove ? context.l10n.removeAll : context.l10n.remove,
      packageName: widget.packageName,
    );
  }
}

class _DepsDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final String packageName;
  final Widget body;
  final Widget? footer;
  final String confirmLabel;
  final List<PackageDependecy> dependencies;

  const _DepsDialog({
    required this.onConfirm,
    required this.dependencies,
    required this.body,
    this.footer,
    required this.confirmLabel,
    required this.packageName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: SizedBox(
        width: 500,
        child: YaruDialogTitleBar(
          title: Text(context.l10n.dependencies),
        ),
      ),
      titlePadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: kYaruPagePadding / 2),
            child: body,
          ),
          Flexible(
            child: SingleChildScrollView(
              child: YaruExpandable(
                expandButtonPosition: YaruExpandableButtonPosition.start,
                header: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(
                    context.l10n.dependencies,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                child: BorderContainer(
                  child: Column(
                    children: [
                      for (var d in dependencies)
                        ListTile(
                          title: Text(d.id.name),
                          subtitle: Text(
                            d.summary ?? context.l10n.unknown,
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          leading: Icon(
                            YaruIcons.package_deb,
                            color: theme.colorScheme.onSurface,
                          ),
                          trailing: Text(d.size.formatByteSize()),
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (footer != null) footer!,
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: Text(confirmLabel),
        )
      ],
    );
  }
}
