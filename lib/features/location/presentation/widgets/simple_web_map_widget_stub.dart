import 'package:flutter/material.dart';

/// Stub implementation for non-web platforms
Widget createSimpleWebMap({
  required double latitude,
  required double longitude,
  required String venue,
  bool showControls = true,
  double height = 300.0,
}) {
  // This should never be called on non-web platforms
  return Container(
    width: double.infinity,
    height: height,
    color: Colors.grey[300],
    child: const Center(
      child: Text('Web-only map widget'),
    ),
  );
}