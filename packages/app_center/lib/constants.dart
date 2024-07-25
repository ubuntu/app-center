import 'package:flutter/material.dart';
import 'package:yaru/icons.dart';

const kAppName = 'App Center';
const kSnapName = 'snap-store';
const kGitHubRepo = 'ubuntu/app-center';

// TODO: add proper neutral colors to yaru
const kShimmerBaseLight = Color.fromARGB(120, 228, 228, 228);
const kShimmerBaseDark = Color.fromARGB(255, 51, 51, 51);
const kShimmerHighLightLight = Color.fromARGB(200, 247, 247, 247);
const kShimmerHighLightDark = Color.fromARGB(255, 57, 57, 57);

const kCircularProgressIndicatorHeight = 16.0;
const kSearchFieldIconConstraints = BoxConstraints(
  minWidth: 32,
  minHeight: 32,
  maxWidth: 32,
  maxHeight: 32,
);
const kSearchFieldStrutStyle = StrutStyle(leading: 0.2);
const kSearchFieldPrefixIcon = Icon(YaruIcons.search, size: 16);
