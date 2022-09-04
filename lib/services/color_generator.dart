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
