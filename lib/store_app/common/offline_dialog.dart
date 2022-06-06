import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/snap_model.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class OfflineDialog extends StatelessWidget {
  const OfflineDialog({Key? key, required this.snapApp}) : super(key: key);

  static Widget createFromValue({
    required BuildContext context,
    required SnapModel value,
    required SnapApp snapApp,
  }) =>
      ChangeNotifierProvider<SnapModel>.value(
        value: value,
        child: OfflineDialog(
          snapApp: snapApp,
        ),
      );

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
                  context.l10n.remove,
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
            onPressed: () => model.open(),
            child: Text(context.l10n.open),
          ),
        ),
      ],
    );
  }
}
