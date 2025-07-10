import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../../../core/config/environment.dart';

// Note: Google Maps deprecation warning is expected for web platform
// This is a known issue with google_maps_flutter plugin
// The warning doesn't affect functionality and will be fixed in future plugin updates

class GoogleMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String venue;
  final bool showControls;
  final double zoom;
  final double height;

  const GoogleMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.venue,
    this.showControls = true,
    this.zoom = 16.0,
    this.height = 300.0,
  });

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  late Set<Marker> _markers;
  late CameraPosition _initialPosition;
  bool _hasError = false;
  String _errorMessage = '';
  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void didUpdateWidget(GoogleMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if coordinates have changed
    if (oldWidget.latitude != widget.latitude || 
        oldWidget.longitude != widget.longitude) {
      _initializeMap();
      _updateMapCamera();
    }
  }

  void _initializeMap() {
    _initialPosition = CameraPosition(
      target: LatLng(widget.latitude, widget.longitude),
      zoom: widget.zoom,
    );

    // Disable markers to avoid LegacyJavaScriptObject error on web
    // TODO: Find alternative marker solution for web platform
    _markers = <Marker>{};
  }

  Future<void> _updateMapCamera() async {
    if (_controller.isCompleted) {
      try {
        final GoogleMapController controller = await _controller.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(widget.latitude, widget.longitude),
              zoom: widget.zoom,
            ),
          ),
        );
      } catch (e) {
        debugPrint('Error updating map camera: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if Google Maps is configured
    if (!Environment.isGoogleMapsConfigured) {
      return _buildErrorWidget('Google Maps API 키가 설정되지 않았습니다.');
    }

    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: _hasError ? _buildErrorWidget(_errorMessage) : _buildMapWidget(),
    );
  }

  Widget _buildMapWidget() {
    return Stack(
      children: [
        GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _initialPosition,
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  try {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                    }
                  } catch (e) {
                    debugPrint('GoogleMap onMapCreated error: $e');
                    // Don't set error state for map creation issues
                    // The map often loads successfully despite initial errors
                  }
                },
                zoomControlsEnabled: widget.showControls,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: widget.showControls,
                compassEnabled: widget.showControls,
                // Disable all gestures for preview mode
                zoomGesturesEnabled: widget.showControls,
                scrollGesturesEnabled: widget.showControls,
                tiltGesturesEnabled: widget.showControls,
                rotateGesturesEnabled: widget.showControls,
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
                    color: Colors.blue,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Google Maps',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
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
            widget.venue,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _hasError = false;
                _errorMessage = '';
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
