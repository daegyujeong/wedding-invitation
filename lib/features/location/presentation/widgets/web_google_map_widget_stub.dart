import 'package:flutter/material.dart';

/// Stub implementation for non-web platforms
Widget createWebGoogleMapWidget({
  required double latitude,
  required double longitude,
  required String venue,
  String? address,
  String? eventDate,
  String? eventTime,
  bool showControls = true,
  double zoom = 16.0,
  double height = 300.0,
}) {
  return Container(
    width: double.infinity,
    height: height,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.map_outlined,
          size: 48,
          color: Colors.grey[600],
        ),
        const SizedBox(height: 16),
        Text(
          venue,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Web view required for interactive map',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}