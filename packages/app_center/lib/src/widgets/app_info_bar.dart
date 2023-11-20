import 'package:flutter/material.dart';

import '/layout.dart';

typedef AppInfo = ({String label, Widget value});

class AppInfoBar extends StatelessWidget {
  const AppInfoBar({
    super.key,
    required this.appInfos,
    required this.layout,
  });

  final List<AppInfo> appInfos;
  final ResponsiveLayout layout;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: kPagePadding,
      runSpacing: 32,
      children: appInfos
          .map((info) => SizedBox(
                width: (layout.totalWidth -
                        (layout.snapInfoColumnCount - 1) * kPagePadding) /
                    layout.snapInfoColumnCount,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.label),
                    DefaultTextStyle.merge(
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      child: info.value,
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
