import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/snap_service.dart';
import 'package:software/app/common/snap/snap_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SnapControlButton extends StatefulWidget {
  const SnapControlButton({
    super.key,
  });

  static Widget create({
    required BuildContext context,
    required String huskSnapName,
  }) =>
      ChangeNotifierProvider<SnapModel>(
        create: (_) => SnapModel(
          doneMessage: context.l10n.done,
          getService<SnapService>(),
          huskSnapName: huskSnapName,
        ),
        child: const SnapControlButton(),
      );

  @override
  State<SnapControlButton> createState() => _SnapControlButtonState();
}

class _SnapControlButtonState extends State<SnapControlButton> {
  bool _initialized = false;
  @override
  void initState() {
    super.initState();
    context.read<SnapModel>().init().then((value) => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SnapModel>();
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: model.snapChangeInProgress || !_initialized
          ? const SizedBox(
              height: 30,
              child: YaruCircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : (model.snapIsInstalled
              ? OutlinedButton(
                  onPressed: () => model.remove(),
                  child: Text(context.l10n.remove),
                )
              : ElevatedButton(
                  onPressed: () => model.install(),
                  child: Text(context.l10n.install),
                )),
    );
  }
}
