import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:quiver/cache.dart';

abstract class ColorGenerator {
  Future<Color?> generateColor(String url);
}

class DominantColorGenerator implements ColorGenerator {
  DominantColorGenerator({int cacheSize = 100})
      : _cache = MapCache<String, Color>.lru(maximumSize: cacheSize);

  final Cache<String, Color> _cache;

  @override
  Future<Color?> generateColor(String url) {
    return _cache.get(
      url,
      ifAbsent: (url) async {
        try {
          final image = NetworkImage(url);
          final generator = await PaletteGenerator.fromImageProvider(image);
          return generator.dominantColor?.color ?? Colors.transparent;
        } on NetworkImageLoadException catch (_) {
          return Colors.transparent;
        }
      },
    );
  }
}
