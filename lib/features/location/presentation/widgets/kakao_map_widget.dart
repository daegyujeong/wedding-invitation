import 'package:flutter/material.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';
import '../../../../core/config/environment.dart';

class KakaoMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String venue;
  final bool showControls;
  final double zoom;

  const KakaoMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.venue,
    this.showControls = true,
    this.zoom = 4.0, // Kakao Map uses different zoom levels
  });

  @override
  State<KakaoMapWidget> createState() => _KakaoMapWidgetState();
}

class _KakaoMapWidgetState extends State<KakaoMapWidget> {
  // Remove controller variable since it's handled by the package

  @override
  Widget build(BuildContext context) {
    const String kakaoMapKey = Environment.kakaoMapsJsKey;

    return Stack(
      children: [
        KakaoMapView(
          width: MediaQuery.of(context).size.width,
          height: 300,
          kakaoMapKey: kakaoMapKey,
          lat: widget.latitude,
          lng: widget.longitude,
          zoomLevel: widget.zoom.toInt(),
          showZoomControl: widget.showControls,
          showMapTypeControl: false,
          draggableMarker: false,
        ),
        if (!widget.showControls)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.map,
                    size: 16,
                    color: Colors.yellow.shade700,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Kakao Maps',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          bottom: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 20,
                  color: Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.venue,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
