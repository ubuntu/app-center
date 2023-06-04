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

import 'package:software/l10n/l10n.dart';

enum PackageState {
  installing,
  removing,
  upgrading,
  downloading,
  processing,
  ready;

  String localize(AppLocalizations l10n) => switch (this) {
        PackageState.installing => l10n.installing,
        PackageState.removing => l10n.removing,
        PackageState.upgrading => l10n.upgrading,
        PackageState.downloading => l10n.downloading,
        PackageState.processing => l10n.processing,
        PackageState.ready => l10n.ready
      };
}
