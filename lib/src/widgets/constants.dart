import 'package:flutter/material.dart';

const kGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 550,
  childAspectRatio: 2.7,
  mainAxisSpacing: 12,
  crossAxisSpacing: 12,
);

// TODO: add proper neutral colors to yaru
const kShimmerBaseLight = Color.fromARGB(120, 228, 228, 228);
const kShimmerBaseDark = Color.fromARGB(255, 51, 51, 51);
const kShimmerHighLightLight = Color.fromARGB(200, 247, 247, 247);
const kShimmerHighLightDark = Color.fromARGB(255, 57, 57, 57);
