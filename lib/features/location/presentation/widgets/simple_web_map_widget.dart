import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Conditional imports for web-only libraries
import 'simple_web_map_widget_stub.dart'
  if (dart.library.html) 'simple_web_map_widget_web.dart';

/// Simplified web Google Maps widget to avoid LegacyJavaScriptObject errors
class SimpleWebMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String venue;
  final bool showControls;
  final double height;

  const SimpleWebMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.venue,
    this.showControls = true,
    this.height = 300.0,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return createSimpleWebMap(
        latitude: latitude,
        longitude: longitude,
        venue: venue,
        showControls: showControls,
        height: height,
      );
    }
    
    // Fallback for non-web platforms
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
}