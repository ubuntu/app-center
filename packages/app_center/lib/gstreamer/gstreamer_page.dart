import 'package:app_center/gstreamer/gstreamer.dart';
import 'package:flutter/material.dart';

class GStreamerPage extends StatelessWidget {
  const GStreamerPage({required this.resources, super.key});

  final List<GstResource> resources;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: resources.map((resource) => Text(resource.name)).toList(),
    );
  }
}
