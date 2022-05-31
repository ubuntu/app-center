import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/pages/common/snap_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class OfflineDialog extends StatelessWidget {
  const OfflineDialog({Key? key, required this.snapApp}) : super(key: key);

  final SnapApp snapApp;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();
    return SimpleDialog(
      titlePadding: EdgeInsets.zero,
      title: YaruDialogTitle(
        title: snapApp.name,
        closeIconData: YaruIcons.window_close,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
          child: TextButton(
            onPressed:
                model.appChangeInProgress ? null : () => model.removeSnap(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Uninstall',
                  style: TextStyle(
                    color: model.appChangeInProgress
                        ? Theme.of(context).disabledColor
                        : Theme.of(context).errorColor,
                  ),
                ),
                if (model.appChangeInProgress)
                  SizedBox(
                    height: 15,
                    child: YaruCircularProgressIndicator(
                      strokeWidth: 2,
                      color: model.appChangeInProgress
                          ? Theme.of(context).disabledColor
                          : Theme.of(context).errorColor,
                    ),
                  )
              ],
            ),
          ),
        ),
        // if (model.snapIsInstalled)
        Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
            ),
            child: ElevatedButton(
                onPressed: () => model.open(), child: const Text('Open')))
      ],
    );
  }
}
