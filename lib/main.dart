import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapd/snapd.dart';
import 'package:software/services/color_generator.dart';
// import 'package:software/services/network_service.dart';
import 'package:software/store_app.dart';
import 'package:software/store_model.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

void main() async {
  registerService<ColorGenerator>(DominantColorGenerator.new);
  registerService<SnapdClient>(SnapdClient.new, dispose: (s) => s.close());
  registerService<Connectivity>(
    Connectivity.new,
  );
  runApp(ChangeNotifierProvider<StoreModel>(
    create: (context) => StoreModel(getService<Connectivity>()),
    child: const StoreApp(),
  ));
}
