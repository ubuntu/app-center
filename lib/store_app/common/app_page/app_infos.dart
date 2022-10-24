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
import 'package:software/l10n/l10n.dart';
import 'package:software/store_app/common/constants.dart';
import 'package:yaru_icons/yaru_icons.dart';

const headerStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);

class AppInfos extends StatelessWidget {
  const AppInfos({
    Key? key,
    required this.strict,
    required this.confinementName,
    required this.license,
    required this.installDate,
    required this.installDateIsoNorm,
    required this.version,
    this.versionChanged,
    this.alignment = Alignment.center,
  }) : super(key: key);

  final bool strict;
  final String confinementName;
  final String license;
  final String installDate;
  final String installDateIsoNorm;
  final String version;
  final bool? versionChanged;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Wrap(
        children: [
          _Confinement(
            strict: strict,
            confinementName: confinementName,
          ),
          const SizedBox(height: 40, width: 30, child: VerticalDivider()),
          _License(headerStyle: headerStyle, license: license),
          const SizedBox(height: 40, width: 30, child: VerticalDivider()),
          _Version(
            version: version,
            versionChanged: versionChanged,
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({
    Key? key,
    required this.header,
    required this.child,
    required this.tooltipMessage,
  }) : super(key: key);

  final String header;
  final String tooltipMessage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipMessage,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            header,
            overflow: TextOverflow.ellipsis,
            style: headerStyle,
          ),
          SizedBox(
            width: 100,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _Version extends StatelessWidget {
  const _Version({
    Key? key,
    required this.version,
    this.versionChanged,
  }) : super(key: key);

  final String version;
  final bool? versionChanged;

  @override
  Widget build(BuildContext context) {
    return _InfoColumn(
      header: context.l10n.version,
      tooltipMessage: version,
      child: Text(
        version,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: headerStyle.copyWith(
          fontWeight: FontWeight.normal,
          color: versionChanged == true
              ? Theme.of(context).brightness == Brightness.light
                  ? kGreenLight
                  : kGreenDark
              : null,
        ),
      ),
    );
  }
}

class _License extends StatelessWidget {
  const _License({
    Key? key,
    required this.headerStyle,
    required this.license,
  }) : super(key: key);

  final TextStyle headerStyle;
  final String license;

  @override
  Widget build(BuildContext context) {
    return _InfoColumn(
      header: context.l10n.license,
      tooltipMessage: license,
      child: Text(
        license,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _Confinement extends StatelessWidget {
  const _Confinement({
    Key? key,
    required this.strict,
    required this.confinementName,
  }) : super(key: key);

  final bool strict;
  final String confinementName;

  @override
  Widget build(BuildContext context) {
    return _InfoColumn(
      header: context.l10n.confinement,
      tooltipMessage: confinementName,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            strict ? YaruIcons.shield : YaruIcons.warning,
            size: 18,
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
