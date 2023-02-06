/*
 * Copyright (C) 2022 Canonical Ltd
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import 'package:flutter/material.dart';
import 'package:packagekit/packagekit.dart';
import 'package:software/app/common/app_icon.dart';
import 'package:software/app/common/constants.dart';
import 'package:software/app/updates/update_dialog.dart';
import 'package:yaru_colors/yaru_colors.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class CollectionPackageUpdateBanner extends StatelessWidget {
  const CollectionPackageUpdateBanner({
    super.key,
    required this.selected,
    this.onChanged,
    required this.updateId,
    required this.installedId,
    required this.group,
  });

  final bool? selected;
  final Function(bool?)? onChanged;
  final PackageKitPackageId updateId;
  final PackageKitPackageId installedId;
  final PackageKitGroup group;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onTap: () => showDialog(
        context: context,
        builder: (_) => UpdateDialog.create(
          context: context,
          id: updateId,
          installedId: installedId,
        ),
      ),
      title: Text(updateId.name),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              installedId.version,
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const Icon(YaruIcons.pan_end),
          Expanded(
            child: Text(
              updateId.version,
              style: TextStyle(
                overflow: TextOverflow.ellipsis,
                color: Theme.of(context).brightness == Brightness.light
                    ? kGreenLight
                    : kGreenDark,
              ),
            ),
          )
        ],
      ),
      leading:
          group == PackageKitGroup.system || group == PackageKitGroup.security
              ? const _SystemUpdateIcon()
              : const Padding(
                  padding: EdgeInsets.only(bottom: 5, left: 5),
                  child: AppIcon(
                    iconUrl: null,
                    size: 38,
                  ),
                ),
      trailing: YaruCheckbox(
        value: selected,
        onChanged: onChanged,
      ),
    );
  }
}

class _SystemUpdateIcon extends StatelessWidget {
  const _SystemUpdateIcon({
    // ignore: unused_element
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 2,
          left: 13,
          child: Container(
            height: 25,
            width: 25,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
        const Icon(
          YaruIcons.ubuntu_logo_large,
          size: 50,
          color: YaruColors.orange,
        ),
        Positioned(
          top: -2,
          right: 2,
          child: Icon(
            YaruIcons.shield_filled,
            size: 26,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Positioned(
          top: 0,
          right: 2,
          child: Icon(
            YaruIcons.shield_filled,
            size: 25,
            color: Colors.amber[800],
          ),
        )
      ],
    );
  }
}
