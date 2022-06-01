import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dpkg/dpkg.dart';
import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';
import 'package:software/deb_installer_app.dart';
import 'package:software/services/color_generator.dart';
import 'package:software/store_app.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

void main(List<String> args) async {
  if (!args.first.endsWith('.deb')) {
    print('Error: must provide a Debian file as first argument!');
    exit(-1);
  }
  final debBinaryFile = DebBinaryFile(args.first);
  try {
    runApp(DebInstallerApp(debBinaryFile: debBinaryFile));
  } finally {
    debBinaryFile.close();
  }

  registerService<ColorGenerator>(DominantColorGenerator.new);
  registerService<SnapdClient>(SnapdClient.new, dispose: (s) => s.close());
  registerService<Connectivity>(Connectivity.new);
  runApp(const StoreApp());
}
