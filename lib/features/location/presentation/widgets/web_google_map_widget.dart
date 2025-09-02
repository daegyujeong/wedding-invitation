import 'package:flutter/material.dart';

// Conditional imports for web-only libraries
import 'web_google_map_widget_stub.dart' 
  if (dart.library.html) 'web_google_map_widget_web.dart';

/// Web-optimized Google Maps widget with custom wedding styling
/// Based on the piano school project's elegant map design
class WebGoogleMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String venue;
  final String? address;
  final String? eventDate;
  final String? eventTime;
  final bool showControls;
  final double zoom;
  final double height;

  const WebGoogleMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.venue,
    this.address,
    this.eventDate,
    this.eventTime,
    this.showControls = true,
    this.zoom = 16.0,
    this.height = 300.0,
  });

  @override
  Widget build(BuildContext context) {
    return createWebGoogleMapWidget(
      latitude: latitude,
      longitude: longitude,
      venue: venue,
      address: address,
      eventDate: eventDate,
      eventTime: eventTime,
      showControls: showControls,
      zoom: zoom,
      height: height,
    );
  }
}