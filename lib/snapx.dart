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

import 'package:collection/collection.dart';
import 'package:snapd/snapd.dart';

extension SnapX on Snap {
  String? get iconUrl => media.firstWhereOrNull((m) => m.type == 'icon')?.url;
  List<String> get screenshotUrls =>
      media.where((m) => m.type == 'screenshot').map((m) => m.url).toList();
  bool get verified => publisher?.validation == 'verified';
  bool get starredDeveloper => publisher?.validation == 'starred';
  DateTime? get releasedAt => channels.entries.firstOrNull?.value.releasedAt;
}
