import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:software/app/common/app_format.dart';
import 'package:software/app/common/app_format_popup.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/common/indeterminate_circular_progress_icon.dart';
import 'package:software/app/common/search_field.dart';
import 'package:software/app/updates/package_updates_page.dart';
import 'package:software/app/updates/snap_updates_page.dart';
import 'package:software/app/updates/updates_model.dart';
import 'package:software/l10n/l10n.dart';
import 'package:software/services/packagekit/package_service.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({
    super.key,
    required this.windowWidth,
  });

  final double windowWidth;

  static Widget create({
    required BuildContext context,
    required double windowWidth,
  }) {
    return ChangeNotifierProvider<UpdatesModel>(
      create: (context) => UpdatesModel(getService<PackageService>())..init(),
      child: UpdatesPage(windowWidth: windowWidth),
    );
  }

  static Widget createTitle(BuildContext context) => Text(context.l10n.updates);

  static Widget createIcon({
    required BuildContext context,
    required bool selected,
    int? badgeCount,
    bool? processing,
  }) {
    return _UpdatesIcon(
      count: badgeCount ?? 0,
      processing: processing ?? false,
    );
  }

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<UpdatesModel>();

    final appFormatPopup = AppFormatPopup(
      onSelected: (appFormat) => model.appFormat = appFormat,
      appFormat: model.appFormat ?? AppFormat.snap,
      enabledAppFormats: model.enabledAppFormats,
    );

    return Scaffold(
      appBar: YaruWindowTitleBar(
        titleSpacing: 0,
        title: SearchField(
          onChanged: (String value) {},
          searchQuery: '',
        ),
      ),
      body: model.appFormat == AppFormat.packageKit
          ? PackageUpdatesPage.create(
              context: context,
              appFormatPopup: appFormatPopup,
            )
          : SnapUpdatesPage.create(
              context: context,
              appFormatPopup: appFormatPopup,
            ),
    );
  }
}

class _UpdatesIcon extends StatelessWidget {
  const _UpdatesIcon({
    // ignore: unused_element
    super.key,
    required this.count,
    required this.processing,
  });

  final int count;
  final bool processing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (processing && count > 0) {
      return Badge(
        position: BadgePosition.topEnd(),
        badgeColor: count > 0 ? theme.primaryColor : Colors.transparent,
        badgeContent: count > 0
            ? Text(
                count.toString(),
                style: badgeTextStyle,
              )
            : null,
        child: const IndeterminateCircularProgressIcon(),
      );
    } else if (processing && count == 0) {
      return const IndeterminateCircularProgressIcon();
    } else if (!processing && count > 0) {
      return Badge(
        badgeColor: theme.primaryColor,
        badgeContent: Text(
          count.toString(),
          style: badgeTextStyle,
        ),
        child: const Icon(YaruIcons.sync),
      );
    }
    return const Icon(YaruIcons.sync);
  }
}
