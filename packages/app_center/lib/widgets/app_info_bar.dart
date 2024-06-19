import 'package:app_center/layout.dart';
import 'package:flutter/material.dart';

typedef AppInfo = ({String label, Widget value});

class AppInfoBar extends StatelessWidget {
  const AppInfoBar({
    required this.appInfos,
    required this.layout,
    super.key,
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
                    SelectionArea(
                      child: DefaultTextStyle.merge(
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        child: info.value,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
