import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class NaverMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String venue;
  final bool showControls;
  final double zoom;

  const NaverMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.venue,
    this.showControls = true,
    this.zoom = 14.0,
  });

  @override
  State<NaverMapWidget> createState() => _NaverMapWidgetState();
}

class _NaverMapWidgetState extends State<NaverMapWidget> {
  late NaverMapController _controller;
  late NMarker _venueMarker;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    _venueMarker = NMarker(
      id: 'venue',
      position: NLatLng(widget.latitude, widget.longitude),
      caption: NOverlayCaption(
        text: widget.venue,
        textSize: 14,
        color: Colors.black,
        haloColor: Colors.white,
      ),
      iconTintColor: Colors.red,
      size: const Size(30, 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NaverMap(
          options: NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: NLatLng(widget.latitude, widget.longitude),
              zoom: widget.zoom,
            ),
            mapType: NMapType.basic,
            activeLayerGroups: [
              NLayerGroup.building,
              NLayerGroup.transit,
            ],
            extent: const NLatLngBounds(
              southWest: NLatLng(31.43, 122.37),
              northEast: NLatLng(44.35, 132.0),
            ),
            locale: const Locale('ko'),
            rotationGesturesEnable: widget.showControls,
            scrollGesturesEnable: widget.showControls,
            tiltGesturesEnable: widget.showControls,
            zoomGesturesEnable: widget.showControls,
            stopGesturesEnable: !widget.showControls,
          ),
          onMapReady: (controller) {
            _controller = controller;
            _controller.addOverlay(_venueMarker);
          },
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
              child: const Row(
                children: [
                  Icon(
                    Icons.map,
                    size: 16,
                    color: Colors.green,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Naver Maps',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
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
                const SizedBox(height: 4),
                Text(
                  '위도: ${widget.latitude.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '경도: ${widget.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 12),
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
    _controller.dispose();
    super.dispose();
  }
}
