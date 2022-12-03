import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class UpdatesSplashScreen extends StatefulWidget {
  const UpdatesSplashScreen({
    // ignore: unused_element
    super.key,
    this.percentage,
    required this.icon,
    this.expanded = true,
  });

  final int? percentage;
  final IconData icon;
  final bool expanded;

  @override
  State<UpdatesSplashScreen> createState() => _UpdatesSplashScreenState();
}

class _UpdatesSplashScreenState extends State<UpdatesSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _animationController.addListener(() => setState(() {}));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var center = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 145,
                height: 185,
                child: LiquidLinearProgressIndicator(
                  value: _animationController.value,
                  backgroundColor: Colors.white.withOpacity(0.5),
                  valueColor: AlwaysStoppedAnimation(
                    Theme.of(context).primaryColor,
                  ),
                  direction: Axis.vertical,
                  borderRadius: 20,
                ),
              ),
              Icon(
                widget.icon,
                size: 120,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
          const SizedBox(
            height: kYaruPagePadding,
          ),
          Center(
            child: Text(
              context.l10n.justAMoment,
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
          ),
          const SizedBox(
            height: kYaruPagePadding / 4,
          ),
          Center(
            child: Text(
              context.l10n.checkingForUpdates,
              style: Theme.of(context).textTheme.headline6!.copyWith(
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
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
    return widget.expanded
        ? Expanded(
            child: center,
          )
        : center;
  }
}
