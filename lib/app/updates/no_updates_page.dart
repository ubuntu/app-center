import 'package:flutter/material.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/app/common/constants.dart';
import 'package:yaru_icons/yaru_icons.dart';

class NoUpdatesPage extends StatelessWidget {
  const NoUpdatesPage({
    Key? key,
    this.expand = true,
  }) : super(key: key);

  final bool expand;

  @override
  Widget build(BuildContext context) {
    final page = Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              YaruAnimatedOkIcon(
                size: 90,
                filled: true,
                color: Theme.of(context).brightness == Brightness.light
                    ? kGreenLight
                    : kGreenDark,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                context.l10n.noUpdates,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ],
      ),
    );

    return expand
        ? Expanded(
            child: page,
          )
        : page;
  }
}
