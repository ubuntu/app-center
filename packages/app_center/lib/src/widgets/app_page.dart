import 'package:app_center/layout.dart';
import 'package:app_center/widgets.dart';
import 'package:flutter/material.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    required this.appInfos,
    this.header,
    this.children,
    super.key,
  });

  final List<AppInfo> appInfos;
  final Widget? header;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) =>
      ResponsiveLayoutBuilder(builder: _appView);

  Widget _appView(BuildContext context) {
    final layout = ResponsiveLayout.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kPagePadding),
      child: Column(
        children: [
          SizedBox(
            width: layout.totalWidth,
            child: header,
          ),
          const SizedBox(height: kPagePadding),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  width: layout.totalWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppInfoBar(appInfos: appInfos, layout: layout),
                      if (children != null) ...children!,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
