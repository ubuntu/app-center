import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class StoreSplashScreen extends StatefulWidget {
  const StoreSplashScreen({
    super.key,
  });

  @override
  State<StoreSplashScreen> createState() => _StoreSplashScreenState();
}

class _StoreSplashScreenState extends State<StoreSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    _animationController.addListener(() => setState(() {}));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 128,
                height: 184,
                child: LiquidLinearProgressIndicator(
                  value: _animationController.value,
                  backgroundColor: theme.primaryColor.withOpacity(0.7),
                  valueColor: const AlwaysStoppedAnimation(
                    Colors.white,
                  ),
                  direction: Axis.vertical,
                  borderRadius: 0,
                ),
              ),
              Icon(
                YaruIcons.ubuntu_logo_large,
                size: 220,
                color: theme.primaryColor.withOpacity(0.9),
              )
            ],
          ),
          const SizedBox(
            height: kYaruPagePadding,
          ),
          Center(
            child: Text(
              context.l10n.justAMoment,
              style: theme.textTheme.headline4,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
          ),
          const SizedBox(
            height: 120,
          ),
        ],
      ),
    );
  }
}
