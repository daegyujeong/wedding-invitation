import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class NaverMapWidgetWeb extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String venue;
  final String? address;
  final bool showControls;
  final double height;
  final bool isLocked;

  const NaverMapWidgetWeb({
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
  State<NaverMapWidgetWeb> createState() => _NaverMapWidgetWebState();
}

class _NaverMapWidgetWebState extends State<NaverMapWidgetWeb> {
  late String _elementId;
  bool _isMapCreated = false;

  @override
  void initState() {
    super.initState();
    _elementId = 'naver-map-${DateTime.now().millisecondsSinceEpoch}';
    _createMapElement();
  }

  void _createMapElement() {
    // Register a platform view
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      _elementId,
      (int viewId) {
        final mapElement = html.DivElement()
          ..id = _elementId
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.position = 'relative';

        // Add loading indicator
        mapElement.innerHtml = '''
          <div style="display: flex; align-items: center; justify-content: center; height: 100%; background: #f5f5f5;">
            <div style="text-align: center; color: #666;">
              <div style="margin-bottom: 10px;">
                <svg width="40" height="40" viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg">
                  <circle cx="20" cy="20" r="18" stroke="#1ec800" stroke-width="2" fill="none" opacity="0.2"/>
                  <path d="M20,2 A18,18 0 0,1 38,20" stroke="#1ec800" stroke-width="2" fill="none">
                    <animateTransform attributeName="transform" type="rotate" from="0 20 20" to="360 20 20" dur="1s" repeatCount="indefinite"/>
                  </path>
                </svg>
              </div>
              <div>네이버 지도 로딩중...</div>
            </div>
          </div>
        ''';

        // Initialize map after a short delay
        Future.delayed(const Duration(milliseconds: 100), () {
          _initializeMap();
        });

        return mapElement;
      },
    );
  }

  Future<void> _initializeMap() async {
    if (_isMapCreated) return;

    debugPrint('🗺️ Initializing Naver Map for ${widget.venue} at ${widget.latitude}, ${widget.longitude}');

    try {
      final result = await js.context.callMethod('createNaverMap', [
        _elementId,
        js.JsObject.jsify({
          'latitude': widget.latitude,
          'longitude': widget.longitude,
          'venue': widget.venue,
          'address': widget.address,
          'zoom': 15,
          'showControls': widget.showControls && !widget.isLocked,
          'showMarker': true,
        }),
      ]);

      if (result != null && result['success'] == true) {
        setState(() {
          _isMapCreated = true;
        });
        debugPrint('✅ Naver Map created successfully');
      } else {
        debugPrint('❌ Failed to create Naver map: ${result?['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('❌ Error initializing Naver map: $e');
    }
  }

  @override
  void didUpdateWidget(NaverMapWidgetWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update map if coordinates or controls changed
    if (_isMapCreated &&
        (oldWidget.latitude != widget.latitude ||
         oldWidget.longitude != widget.longitude ||
         oldWidget.venue != widget.venue ||
         oldWidget.address != widget.address ||
         oldWidget.isLocked != widget.isLocked)) {
      _updateMap();
    }
  }

  void _updateMap() {
    if (!_isMapCreated) return;

    try {
      js.context.callMethod('updateNaverMap', [
        _elementId,
        js.JsObject.jsify({
          'latitude': widget.latitude,
          'longitude': widget.longitude,
          'venue': widget.venue,
          'address': widget.address,
          'showControls': widget.showControls && !widget.isLocked,
        }),
      ]);
    } catch (e) {
      debugPrint('Error updating Naver map: $e');
    }
  }

  @override
  void dispose() {
    if (_isMapCreated) {
      try {
        js.context.callMethod('destroyNaverMap', [_elementId]);
      } catch (e) {
        debugPrint('Error destroying Naver map: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            HtmlElementView(viewType: _elementId),
            if (widget.isLocked)
              Positioned.fill(
                child: Container(
                  color: Colors.transparent,
                  child: const SizedBox.expand(), // Blocks interaction
                ),
              ),
          ],
        ),
      ),
    );
  }
}