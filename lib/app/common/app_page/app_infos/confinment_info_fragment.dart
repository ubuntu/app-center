import 'package:flutter/material.dart';
import 'package:software/app/common/app_page/app_infos/app_info_fragment.dart';
import 'package:software/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';

class ConfinementInfoFragment extends StatelessWidget {
  const ConfinementInfoFragment({
    super.key,
    required this.strict,
    required this.confinementName,
  });

  final bool strict;
  final String confinementName;

  @override
  Widget build(BuildContext context) {
    return AppInfoFragment(
      header: context.l10n.confinement,
      tooltipMessage: confinementName,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            strict ? YaruIcons.shield : YaruIcons.warning,
            size: 16,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            confinementName,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
