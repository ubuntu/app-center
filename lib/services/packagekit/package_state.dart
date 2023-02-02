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

  String localize(AppLocalizations l10n) {
    switch (this) {
      case PackageState.installing:
        return l10n.installing;
      case PackageState.removing:
        return l10n.removing;
      case PackageState.upgrading:
        return l10n.upgrading;
      case PackageState.downloading:
        return l10n.downloading;
      case PackageState.processing:
        return l10n.processing;
      case PackageState.ready:
        return l10n.ready;
    }
  }
}
