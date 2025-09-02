import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

/// Web-specific implementation of Google Maps widget
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
  return _WebGoogleMapWidgetImpl(
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

class _WebGoogleMapWidgetImpl extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String venue;
  final String? address;
  final String? eventDate;
  final String? eventTime;
  final bool showControls;
  final double zoom;
  final double height;

  const _WebGoogleMapWidgetImpl({
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
  State<_WebGoogleMapWidgetImpl> createState() => _WebGoogleMapWidgetImplState();
}

class _WebGoogleMapWidgetImplState extends State<_WebGoogleMapWidgetImpl> {
  final String _mapId = 'wedding-map-${DateTime.now().millisecondsSinceEpoch}';
  bool _isMapInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWebMap();
  }

  void _initializeWebMap() {
    // Register view factory for the map container
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      _mapId,
      (int viewId) {
        final mapContainer = html.DivElement()
          ..id = 'map-container-$_mapId'
          ..style.width = '100%'
          ..style.height = '${widget.height}px'
          ..style.borderRadius = '12px'
          ..style.overflow = 'hidden'
          ..style.boxShadow = '0 4px 20px rgba(0,0,0,0.15)'
          ..style.border = '1px solid rgba(108, 117, 125, 0.2)';

        final mapDiv = html.DivElement()
          ..id = 'wedding-map-$_mapId'
          ..style.width = '100%'
          ..style.height = '100%';

        mapContainer.append(mapDiv);

        // Initialize map after a brief delay to ensure DOM is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          _initializeMap();
        });

        return mapContainer;
      },
    );
  }

  void _initializeMap() {
    try {
      // Use a more compatible approach with direct JavaScript execution
      final script = '''
        if (typeof window.WeddingMapStyles !== 'undefined' && typeof google !== 'undefined' && google.maps) {
          try {
            var venueData = {
              name: '${widget.venue.replaceAll("'", "\\'")}',
              address: '${(widget.address ?? widget.venue).replaceAll("'", "\\'")}',
              lat: ${widget.latitude},
              lng: ${widget.longitude},
              date: '${widget.eventDate ?? ''}',
              time: '${widget.eventTime ?? ''}'
            };
            
            var mapOptions = {
              zoom: ${widget.zoom.toInt()},
              scrollwheel: ${widget.showControls},
              zoomControl: ${widget.showControls},
              mapTypeControl: false,
              streetViewControl: ${widget.showControls},
              fullscreenControl: ${widget.showControls}
            };
            
            window.WeddingMapStyles.initMap('wedding-map-$_mapId', venueData, mapOptions);
          } catch (e) {
            console.error('WeddingMapStyles error:', e);
            // Fallback to basic map if custom styling fails
            if (typeof google !== 'undefined' && google.maps) {
              var map = new google.maps.Map(document.getElementById('wedding-map-$_mapId'), {
                center: {lat: ${widget.latitude}, lng: ${widget.longitude}},
                zoom: ${widget.zoom.toInt()},
                scrollwheel: ${widget.showControls},
                zoomControl: ${widget.showControls},
                mapTypeControl: false,
                streetViewControl: ${widget.showControls},
                fullscreenControl: ${widget.showControls}
              });
              
              var marker = new google.maps.Marker({
                position: {lat: ${widget.latitude}, lng: ${widget.longitude}},
                map: map,
                title: '${widget.venue.replaceAll("'", "\\'")}',
                animation: google.maps.Animation.DROP
              });
            }
          }
        } else {
          // Direct fallback without custom styling
          if (typeof google !== 'undefined' && google.maps) {
            var map = new google.maps.Map(document.getElementById('wedding-map-$_mapId'), {
              center: {lat: ${widget.latitude}, lng: ${widget.longitude}},
              zoom: ${widget.zoom.toInt()},
              scrollwheel: ${widget.showControls},
              zoomControl: ${widget.showControls},
              mapTypeControl: false,
              streetViewControl: ${widget.showControls},
              fullscreenControl: ${widget.showControls}
            });
            
            var marker = new google.maps.Marker({
              position: {lat: ${widget.latitude}, lng: ${widget.longitude}},
              map: map,
              title: '${widget.venue.replaceAll("'", "\\'")}',
              animation: google.maps.Animation.DROP
            });
          }
        }
      ''';

      final scriptElement = html.ScriptElement()..text = script;
      html.document.head?.append(scriptElement);

      setState(() {
        _isMapInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing wedding map: $e');
      _initializeBasicMap();
    }
  }

  void _initializeBasicMap() {
    // Fallback to basic Google Maps initialization
    try {
      final script = '''
        if (typeof google !== 'undefined' && google.maps) {
          var map = new google.maps.Map(document.getElementById('wedding-map-$_mapId'), {
            center: {lat: ${widget.latitude}, lng: ${widget.longitude}},
            zoom: ${widget.zoom.toInt()},
            scrollwheel: ${widget.showControls},
            zoomControl: ${widget.showControls},
            mapTypeControl: false,
            streetViewControl: ${widget.showControls},
            fullscreenControl: ${widget.showControls}
          });
          
          var marker = new google.maps.Marker({
            position: {lat: ${widget.latitude}, lng: ${widget.longitude}},
            map: map,
            title: '${widget.venue}',
            animation: google.maps.Animation.DROP
          });
          
          var infoWindow = new google.maps.InfoWindow({
            content: '<div style="padding:10px;"><h3>${widget.venue}</h3><p>${widget.address ?? widget.venue}</p></div>'
          });
          
          marker.addListener('click', function() {
            infoWindow.open(map, marker);
          });
          
          setTimeout(function() {
            infoWindow.open(map, marker);
          }, 1000);
        }
      ''';

      final scriptElement = html.ScriptElement()..text = script;
      html.document.head?.append(scriptElement);

      setState(() {
        _isMapInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing basic map: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Map container
            HtmlElementView(
              viewType: _mapId,
            ),
            
            // Loading overlay
            if (!_isMapInitialized)
              Container(
                width: double.infinity,
                height: widget.height,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF4F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFd63384)),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Loading wedding venue map...',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.venue,
                      style: const TextStyle(
                        color: Color(0xFFd63384),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}