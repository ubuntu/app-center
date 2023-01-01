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
  left: kPagePadding - 5,
  right: kPagePadding - 5,
);
const kHeaderPadding = EdgeInsets.only(
  top: kPagePadding,
  left: kPagePadding,
  bottom: kPagePadding - 5,
);
const kIconPadding = EdgeInsets.only(top: 8, bottom: 8, right: 5);
const kDialogWidth = 450.0;
const kGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  mainAxisExtent: 150,
  mainAxisSpacing: 10,
  crossAxisSpacing: 10,
  maxCrossAxisExtent: 550,
);
const kSnapcraftColor = Color(0xFFE95420);
const kDebianColor = Color(0xFFdb2264);
const kGreenLight = Color.fromARGB(255, 51, 121, 63);
const kGreenDark = Color.fromARGB(255, 128, 211, 143);
const kStarColor = Color(0xFFf99b11);
const kStarDevColor = Color(0xFFb24a26);
const kCheckForUpdateTimeOutInMinutes = 30;
const kFakeReviewText =
    'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.';

const kBorderContainerBgDark = Color.fromARGB(255, 46, 46, 46);
const badgeTextStyle = TextStyle(color: Colors.white, fontSize: 10);
