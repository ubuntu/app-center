import 'package:flutter/material.dart';

const kAppName = 'App Store';
const kGitHubRepo = 'ubuntu/software';

const kNaviRailWidth = 205.0;

const kGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 550,
  mainAxisExtent: 120,
  mainAxisSpacing: 12,
  crossAxisSpacing: 12,
);

// TODO: add proper neutral colors to yaru
const kShimmerBaseLight = Color.fromARGB(120, 228, 228, 228);
const kShimmerBaseDark = Color.fromARGB(255, 51, 51, 51);
const kShimmerHighLightLight = Color.fromARGB(200, 247, 247, 247);
const kShimmerHighLightDark = Color.fromARGB(255, 57, 57, 57);
