import 'package:flutter/material.dart';
import 'naver_map_widget_stub.dart'
    if (dart.library.html) 'naver_map_widget_web.dart';

class NaverMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String venue;
  final String? address;
  final bool showControls;
  final double height;
  final bool isLocked;

  const NaverMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.venue,
    this.address,
    this.showControls = true,
    this.height = 300,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return NaverMapWidgetWeb(
      latitude: latitude,
      longitude: longitude,
      venue: venue,
      address: address,
      showControls: showControls,
      height: height,
      isLocked: isLocked,
    );
  }
}