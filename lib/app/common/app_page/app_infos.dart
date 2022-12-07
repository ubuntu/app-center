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
import 'package:software/app/common/constants.dart';
import 'package:yaru_icons/yaru_icons.dart';

const headerStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 14);

class AppInfos extends StatelessWidget {
  const AppInfos({
    Key? key,
    required this.strict,
    required this.confinementName,
    required this.license,
    this.installDate,
    this.installDateIsoNorm,
    required this.version,
    this.versionChanged,
    this.alignment = Alignment.center,
    this.wrapAlignment = WrapAlignment.center,
    this.runAlignment = WrapAlignment.center,
    this.direction = Axis.horizontal,
  }) : super(key: key);

  final bool strict;
  final String confinementName;
  final String license;
  final String? installDate;
  final String? installDateIsoNorm;
  final String version;
  final bool? versionChanged;
  final AlignmentGeometry alignment;
  final WrapAlignment wrapAlignment;
  final WrapAlignment runAlignment;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Wrap(
        alignment: wrapAlignment,
        runAlignment: runAlignment,
        runSpacing: 40,
        direction: direction,
        children: [
          _Confinement(
            strict: strict,
            confinementName: confinementName,
          ),
          _divider(direction),
          _License(headerStyle: headerStyle, license: license),
          _divider(direction),
          _Version(
            version: version,
            versionChanged: versionChanged,
          ),
          if (installDate != null && installDateIsoNorm != null)
            _divider(direction),
          if (installDate != null && installDateIsoNorm != null)
            _InstallDate(
              installDateIsoNorm: installDateIsoNorm!,
              installDate: installDate!,
            )
        ],
      ),
    );
  }

  Widget _divider(Axis direction) => direction == Axis.horizontal
      ? const SizedBox(height: 40, width: 30, child: VerticalDivider())
      : const SizedBox(
          width: 100,
          height: 30,
          child: Divider(),
        );
}

class _InstallDate extends StatelessWidget {
  const _InstallDate({
    Key? key,
    required this.installDateIsoNorm,
    required this.installDate,
  }) : super(key: key);

  final String installDateIsoNorm;
  final String installDate;

  @override
  Widget build(BuildContext context) {
    return _InfoColumn(
      header: context.l10n.installDate,
      tooltipMessage: installDateIsoNorm,
      childWidth: 120,
      child: Text(
        installDate.isNotEmpty ? installDate : context.l10n.notInstalled,
        maxLines: 1,
        overflow: TextOverflow.visible,
        textAlign: TextAlign.center,
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
    this.childWidth,
  }) : super(key: key);

  final String header;
  final String tooltipMessage;
  final Widget child;
  final double? childWidth;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltipMessage,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            header,
            overflow: TextOverflow.ellipsis,
            style: headerStyle,
          ),
          SizedBox(
            width: childWidth ?? 100,
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
