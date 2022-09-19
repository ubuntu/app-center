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
import 'package:yaru_icons/yaru_icons.dart';

class AppInfos extends StatelessWidget {
  const AppInfos({
    Key? key,
    required this.strict,
    required this.confinementName,
    required this.license,
    required this.installDate,
    required this.installDateIsoNorm,
    required this.version,
  }) : super(key: key);

  final bool strict;
  final String confinementName;
  final String license;
  final String installDate;
  final String installDateIsoNorm;
  final String version;

  @override
  Widget build(BuildContext context) {
    const headerStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        _Confinement(
          headerStyle: headerStyle,
          strict: strict,
          confinementName: confinementName,
        ),
        const SizedBox(height: 40, width: 30, child: VerticalDivider()),
        _License(headerStyle: headerStyle, license: license),
        const SizedBox(height: 40, width: 30, child: VerticalDivider()),
        _InstallDate(
          installDate: installDate,
          headerStyle: headerStyle,
          installDateIsoNorm: installDateIsoNorm,
          version: version,
        ),
      ],
    );
  }
}

class _InstallDate extends StatelessWidget {
  const _InstallDate({
    Key? key,
    required this.installDate,
    required this.headerStyle,
    required this.installDateIsoNorm,
    required this.version,
  }) : super(key: key);

  final String installDate;
  final TextStyle headerStyle;
  final String installDateIsoNorm;
  final String version;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            installDate.isEmpty
                ? context.l10n.version
                : context.l10n.installDate,
            overflow: TextOverflow.ellipsis,
            style: headerStyle,
          ),
        ),
        Flexible(
          child: Tooltip(
            message: installDateIsoNorm,
            child: Text(
              installDate.isEmpty ? version : installDate,
              overflow: TextOverflow.ellipsis,
              style: headerStyle.copyWith(fontWeight: FontWeight.normal),
            ),
          ),
        ),
      ],
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(context.l10n.license, style: headerStyle),
        ),
        Flexible(
          child: Tooltip(
            message: license,
            child: Text(
              license.split(' ').first,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        )
      ],
    );
  }
}

class _Confinement extends StatelessWidget {
  const _Confinement({
    Key? key,
    required this.headerStyle,
    required this.strict,
    required this.confinementName,
  }) : super(key: key);

  final TextStyle headerStyle;
  final bool strict;
  final String confinementName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            context.l10n.confinement,
            style: headerStyle,
          ),
        ),
        Flexible(
          child: Row(
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
        ),
      ],
    );
  }
}
