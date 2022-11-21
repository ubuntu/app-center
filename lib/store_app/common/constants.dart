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

const kPagePadding = 20.0;
const kGridPadding = EdgeInsets.only(
  bottom: kPagePadding,
  left: kPagePadding,
  right: kPagePadding,
);
const kHeaderPadding =
    EdgeInsets.only(top: kPagePadding, left: 25, bottom: kPagePadding);
const kIconPadding = EdgeInsets.only(top: 8, bottom: 8, right: 5);
const kDialogWidth = 450.0;
const kGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  mainAxisExtent: 110,
  mainAxisSpacing: 15,
  crossAxisSpacing: 15,
  maxCrossAxisExtent: 550,
);
const kGreenLight = Color.fromARGB(255, 51, 121, 63);
const kGreenDark = Color.fromARGB(255, 128, 211, 143);
const kCheckForUpdateTimeOutInMinutes = 30;
