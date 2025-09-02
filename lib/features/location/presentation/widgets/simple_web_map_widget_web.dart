import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

/// Simplified web-specific implementation to avoid LegacyJavaScriptObject errors
Widget createSimpleWebMap({
  required double latitude,
  required double longitude,
  required String venue,
  bool showControls = true,
  double height = 300.0,
}) {
  return _SimpleWebMapImpl(
    latitude: latitude,
    longitude: longitude,
    venue: venue,
    showControls: showControls,
    height: height,
  );
}

class _SimpleWebMapImpl extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String venue;
  final bool showControls;
  final double height;

  const _SimpleWebMapImpl({
    required this.latitude,
    required this.longitude,
    required this.venue,
    this.showControls = true,
    this.height = 300.0,
  });

  @override
  State<_SimpleWebMapImpl> createState() => _SimpleWebMapImplState();
}

class _SimpleWebMapImplState extends State<_SimpleWebMapImpl> {
  final String _mapId = 'simple-map-${DateTime.now().millisecondsSinceEpoch}';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _registerMapView();
  }

  void _registerMapView() {
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      _mapId,
      (int viewId) {
        final div = html.DivElement()
          ..id = 'map-div-$_mapId'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.borderRadius = '12px';

        // Simple delay before initializing map
        Future.delayed(const Duration(milliseconds: 800), () {
          _initializeSimpleMap();
        });

        return div;
      },
    );
  }

  void _initializeSimpleMap() {
    if (!mounted) return;

    try {
      // Use enhanced wedding map with CSS to hide close button
      final mapScript = '''
        (function() {
          try {
            if (typeof google === 'undefined' || !google.maps) {
              console.error('Google Maps not loaded');
              return;
            }
            
            var mapDiv = document.getElementById('map-div-$_mapId');
            if (!mapDiv) {
              console.error('Map div not found');
              return;
            }
            
            // Add comprehensive CSS to hide Google Maps info window close button
            var style = document.createElement('style');
            style.textContent = `
              /* Hide all variations of Google Maps close button */
              .gm-ui-hover-effect { display: none !important; }
              .gm-style-iw-chr { display: none !important; }
              .gm-style-iw-c button { display: none !important; }
              .gm-style-iw button { display: none !important; }
              .gm-style-iw .gm-ui-hover-effect { display: none !important; }
              button[title="Close"] { display: none !important; }
              button[aria-label="Close"] { display: none !important; }
              .gm-style-iw button[aria-label="Close"] { display: none !important; }
              .gm-style-iw-d button { display: none !important; }
              .gm-style-iw-tc button { display: none !important; }
              /* Force hide with more specific selectors */
              div.gm-style-iw button { visibility: hidden !important; opacity: 0 !important; }
              .gm-style button[title*="lose"] { display: none !important; }
            `;
            document.head.appendChild(style);
            
            // Create map with wedding styling
            var map = new google.maps.Map(mapDiv, {
              center: new google.maps.LatLng(${widget.latitude}, ${widget.longitude}),
              zoom: 15,
              scrollwheel: ${widget.showControls},
              zoomControl: ${widget.showControls},
              mapTypeControl: false,
              streetViewControl: false,
              fullscreenControl: ${widget.showControls},
              styles: [
                {
                  "featureType": "landscape",
                  "elementType": "geometry.fill", 
                  "stylers": [{"color": "#faf4f5"}]
                },
                {
                  "featureType": "water",
                  "elementType": "geometry.fill",
                  "stylers": [{"color": "#b3d9f2"}]
                },
                {
                  "featureType": "road",
                  "elementType": "geometry.fill",
                  "stylers": [{"color": "#ffffff"}]
                },
                {
                  "featureType": "poi.park",
                  "elementType": "geometry.fill",
                  "stylers": [{"color": "#d4e5d7"}]
                }
              ]
            });
            
            // Create marker
            var marker = new google.maps.Marker({
              position: new google.maps.LatLng(${widget.latitude}, ${widget.longitude}),
              map: map,
              title: "${widget.venue.replaceAll('"', '\\"').replaceAll("'", "\\'")}",
              animation: google.maps.Animation.DROP
            });
            
            // Get specific map link for directions
            function getMapLink(lat, lng) {
              // Malaysia location
              if (Math.abs(lat - 3.8077) < 0.0001 && Math.abs(lng - 103.3260) < 0.0001) {
                return 'https://maps.app.goo.gl/NQh4bPQZ6Mqd45rx6';
              }
              // Singapore location
              else if (Math.abs(lat - 1.273806) < 0.0001 && Math.abs(lng - 103.817497) < 0.0001) {
                return 'https://maps.app.goo.gl/YTLSyvffXX8HFUiRA';
              }
              // Korea location
              else if (Math.abs(lat - 35.6288349) < 0.0001) {
                return 'https://maps.app.goo.gl/MEbVPxKa3UYWWGmj8';
              }
              // Fallback to generic Google Maps link
              else {
                return 'https://maps.google.com/maps?q=' + lat + ',' + lng;
              }
            }
            
            // Create compact info window content
            var infoContent = `
              <div style="
                padding: 12px; 
                max-width: 240px; 
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                line-height: 1.4;
              ">
                <!-- Header -->
                <div style="text-align: center; margin-bottom: 12px;">
                  <h4 style="
                    margin: 0 0 6px 0; 
                    color: #d63384; 
                    font-size: 16px; 
                    font-weight: 600;
                  ">
                    ${widget.venue.replaceAll('"', '\\"').replaceAll("'", "\\'")}
                  </h4>
                  <div style="
                    width: 30px; 
                    height: 2px; 
                    background: linear-gradient(90deg, #d63384, #fd7e14); 
                    margin: 0 auto; 
                    border-radius: 1px;
                  "></div>
                </div>
                
                <!-- Venue Details -->
                <div style="margin-bottom: 12px;">
                  <div style="
                    display: flex; 
                    align-items: center; 
                    margin-bottom: 8px;
                    padding: 6px;
                    background: #faf4f5;
                    border-radius: 6px;
                  ">
                    <span style="
                      font-size: 14px; 
                      margin-right: 8px; 
                      color: #d63384;
                    ">📍</span>
                    <span style="
                      color: #495057; 
                      font-size: 13px; 
                      font-weight: 500;
                    ">
                      Wedding Venue
                    </span>
                  </div>
                </div>
                
                <!-- Get Directions Button -->
                <div style="text-align: center;">
                  <a href="` + getMapLink(${widget.latitude}, ${widget.longitude}) + `" 
                     target="_blank"
                     style="
                       display: inline-block; 
                       background: linear-gradient(135deg, #d63384 0%, #fd7e14 100%); 
                       color: white; 
                       text-decoration: none; 
                       padding: 8px 16px; 
                       border-radius: 20px; 
                       font-size: 12px; 
                       font-weight: 600;
                       box-shadow: 0 2px 8px rgba(214, 51, 132, 0.3);
                       transition: all 0.3s ease;
                     "
                     onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 12px rgba(214, 51, 132, 0.4)';"
                     onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 8px rgba(214, 51, 132, 0.3)';"
                  >
                    <span style="margin-right: 6px;">🧭</span>
                    Directions
                  </a>
                </div>
              </div>
            `;
            
            var infoWindow = new google.maps.InfoWindow({
              content: infoContent,
              disableAutoPan: false
            });
            
            // Hide the close button with CSS after the info window opens
            google.maps.event.addListener(infoWindow, 'domready', function() {
              // Hide the close button with multiple selectors
              var closeBtn = document.querySelector('.gm-ui-hover-effect');
              if (closeBtn) {
                closeBtn.style.display = 'none';
              }
              
              var closeBtnAlt = document.querySelector('button[title="Close"]');
              if (closeBtnAlt) {
                closeBtnAlt.style.display = 'none';
              }
              
              var closeBtnAlt2 = document.querySelector('.gm-style-iw-chr');
              if (closeBtnAlt2) {
                closeBtnAlt2.style.display = 'none';
              }
            });
            
            marker.addListener('click', function() {
              infoWindow.open(map, marker);
            });
            
            // Auto-open info window after a delay
            setTimeout(function() {
              infoWindow.open(map, marker);
            }, 1500);
            
          } catch (error) {
            console.error('Map initialization error:', error);
          }
        })();
      ''';

      final script = html.ScriptElement()..text = mapScript;
      html.document.head?.append(script);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Simple map error: $e');
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
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            HtmlElementView(viewType: _mapId),
            
            // Loading overlay
            if (!_isInitialized)
              Container(
                color: const Color(0xFFFAF4F5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFd63384)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading ${widget.venue}...',
                        style: const TextStyle(
                          color: Color(0xFFd63384),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}