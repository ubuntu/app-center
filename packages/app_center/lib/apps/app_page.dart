import 'package:app_center/apps/app_title_bar.dart';
import 'package:app_center/layout.dart';
import 'package:flutter/material.dart';

/// A page layout to display a single app and its associated actions.
class AppPage extends StatelessWidget {
  const AppPage({
    required this.titleBar,
    required this.actionBar,
    required this.infoBar,
    required this.body,
    super.key,
  });

  /// [AppTitleBar] to use for the top-most section of the app page.
  final Widget titleBar;

  /// Widget for package-specific actions like install, uninstall, etc.
  final Widget actionBar;

  /// App info bar for app metadata.
  final Widget infoBar;

  /// Extended app description and image content.
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      builder: (context) {
        final layout = ResponsiveLayout.of(context);

        return Column(
          children: [
            const SizedBox(height: kPagePadding),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: SizedBox(
                    width: layout.totalWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: kPagePadding),
                        titleBar,
                        const SizedBox(height: kPagePadding),
                        actionBar,
                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 32),
                        infoBar,
                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 32),
                        body,
                        const SizedBox(height: kPagePadding),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
