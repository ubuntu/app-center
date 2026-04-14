import 'package:app_center/deb/deb_model.dart';
import 'package:app_center/deb/local_deb_model.dart';
import 'package:app_center/layout.dart';
import 'package:app_center/snapd/snapd.dart';
import 'package:app_center/widgets/app_icon.dart';
import 'package:app_center/widgets/app_title.dart';
import 'package:flutter/material.dart';

/// Title bar for an app. Usually with an app icon, title, and action buttons.
class AppTitleBar extends StatelessWidget {
  const AppTitleBar({
    required this.title,
    this.banner,
    this.actions,
    this.iconUrl,
    this.iconWidget,
    super.key,
  });

  factory AppTitleBar.fromSnap(
    SnapData snapData, {
    Widget? actions,
    Widget? banner,
  }) =>
      AppTitleBar(
        iconUrl: snapData.snap.iconUrl,
        title: AppTitle.fromSnap(
          snapData.snap,
          large: true,
        ),
        actions: actions,
        banner: banner,
      );

  factory AppTitleBar.fromDeb(
    DebData debData, {
    Widget? actions,
    Widget? banner,
  }) =>
      AppTitleBar(
        iconWidget: DebAppIcon(component: debData.component, size: 96),
        title: AppTitle.fromDeb(
          debData.component,
          large: true,
        ),
        actions: actions,
        banner: banner,
      );

  factory AppTitleBar.fromLocalDeb(
    LocalDebData localDebData, {
    Widget? actions,
    Widget? banner,
  }) =>
      AppTitleBar(
        title: AppTitle.fromLocalDeb(
          localDebData,
          large: true,
        ),
        actions: actions,
        banner: banner,
      );

  /// [AppTitle] widget for the app.
  final Widget title;

  /// Optional banner to display below the app title.
  final Widget? banner;

  /// Optional widget for app actions like report and share buttons.
  final Widget? actions;

  /// Optional URL to use for the app's icon.
  final String? iconUrl;

  /// Optional pre-built icon widget (takes precedence over [iconUrl]).
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            iconWidget ?? AppIcon(iconUrl: iconUrl, size: 96),
            const SizedBox(width: 16),
            Expanded(
              child: Semantics(
                header: true,
                focused: true,
                child: title,
              ),
            ),
            if (actions != null) actions!,
          ],
        ),
        if (banner != null) ...[
          const SizedBox(height: kPagePadding),
          banner!,
        ],
      ],
    );
  }
}
