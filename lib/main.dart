import 'package:flutter/material.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/color_generator.dart';
import 'package:software/store_app.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

void main() async {
  registerService<ColorGenerator>(DominantColorGenerator.new);
  registerService<SnapdClient>(SnapdClient.new, dispose: (s) => s.close());
  runApp(const StoreApp());
}
