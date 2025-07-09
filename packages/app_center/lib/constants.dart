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

const kHyperlinkDark = Color.fromRGBO(102, 153, 204, 1);
const kHyperlinkLight = Color.fromRGBO(0, 102, 204, 1);

const kLoaderHeight = 16.0;
const kLoaderMediumHeight = 32.0;
const kSearchFieldIconConstraints = BoxConstraints(
  minWidth: 32,
  minHeight: 32,
  maxWidth: 32,
  maxHeight: 32,
);
const kSearchFieldContentPadding = EdgeInsets.all(12);
const kSearchFieldPrefixIcon = Icon(YaruIcons.search, size: 16);

// URLs
const localDebInfoUrl =
    'https://ubuntu.com/server/docs/third-party-repository-usage';
const debManageDocsUrl =
    'https://documentation.ubuntu.com/server/tutorial/managing-software/#installing-deb-packages';
const snapStoreBaseUrl = 'https://snapcraft.io';
