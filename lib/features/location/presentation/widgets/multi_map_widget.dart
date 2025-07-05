import 'package:flutter/material.dart';
import 'google_map_widget.dart';
import 'naver_map_widget.dart';
import 'kakao_map_widget.dart';
import 'map_navigation_helper.dart';

enum MapProvider {
  google,
  naver,
  kakao,
}

class MultiMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String venue;
  final MapProvider provider;
  final bool showControls;
  final bool showDirections;
  final double height;
  final VoidCallback? onMapTap;
  final bool isEditMode;

  const MultiMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.venue,
    this.provider = MapProvider.google,
    this.showControls = true,
    this.showDirections = true,
    this.height = 300,
    this.onMapTap,
    this.isEditMode = false,
  });

  @override
  State<MultiMapWidget> createState() => _MultiMapWidgetState();
}

class _MultiMapWidgetState extends State<MultiMapWidget> {
  late MapProvider _currentProvider;

  @override
  void initState() {
    super.initState();
    _currentProvider = widget.provider;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Ensure we have a finite width
        final double mapWidth = constraints.maxWidth.isFinite 
            ? constraints.maxWidth 
            : MediaQuery.of(context).size.width;

        // Calculate available height for map after accounting for other elements
        double availableMapHeight = widget.height;
        
        // Account for selector height if in edit mode
        if (widget.isEditMode) {
          availableMapHeight -= 48; // Selector height + margin
        }
        
        // Account for navigation buttons height if showing directions
        if (widget.showDirections) {
          availableMapHeight -= 80; // Navigation buttons height + margin
        }
        
        // Ensure minimum map height
        availableMapHeight = availableMapHeight.clamp(150.0, widget.height);
            
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isEditMode) _buildMapProviderSelector(context),
            Container(
              width: mapWidth,
              height: availableMapHeight, // Use calculated height instead of widget.height
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildMap(availableMapHeight),
              ),
            ),
            if (widget.showDirections) _buildNavigationButtons(context),
          ],
        );
      },
    );
  }

  Widget _buildMapProviderSelector(BuildContext context) {
    return Container(
      height: 40, // Fixed height for predictable layout
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProviderButton(
            context,
            MapProvider.google,
            'Google Maps',
            Colors.blue,
          ),
          const SizedBox(width: 8),
          _buildProviderButton(
            context,
            MapProvider.naver,
            'Naver Maps',
            Colors.green,
          ),
          const SizedBox(width: 8),
          _buildProviderButton(
            context,
            MapProvider.kakao,
            'Kakao Maps',
            Colors.yellow.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildProviderButton(
    BuildContext context,
    MapProvider mapProvider,
    String label,
    Color color,
  ) {
    final isSelected = _currentProvider == mapProvider;
    return InkWell(
      onTap: () {
        setState(() {
          _currentProvider = mapProvider;
        });
        widget.onMapTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMap(double mapHeight) {
    switch (_currentProvider) {
      case MapProvider.google:
        return GoogleMapWidget(
          latitude: widget.latitude,
          longitude: widget.longitude,
          venue: widget.venue,
          showControls: widget.showControls,
          height: mapHeight, // Pass calculated height
        );
      case MapProvider.naver:
        return NaverMapWidget(
          latitude: widget.latitude,
          longitude: widget.longitude,
          venue: widget.venue,
          showControls: widget.showControls,
          height: mapHeight, // Pass calculated height
        );
      case MapProvider.kakao:
        return KakaoMapWidget(
          latitude: widget.latitude,
          longitude: widget.longitude,
          venue: widget.venue,
          showControls: widget.showControls,
          height: mapHeight, // Pass calculated height
        );
    }
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Container(
      height: 72, // Fixed height for predictable layout
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavButton(
            context,
            'Kakao Map',
            Icons.map,
            Colors.yellow.shade700,
            () => MapNavigationHelper.openKakaoMap(
              latitude: widget.latitude,
              longitude: widget.longitude,
              venue: widget.venue,
            ),
          ),
          _buildNavButton(
            context,
            'Naver Map',
            Icons.map,
            Colors.green,
            () => MapNavigationHelper.openNaverMap(
              latitude: widget.latitude,
              longitude: widget.longitude,
              venue: widget.venue,
            ),
          ),
          _buildNavButton(
            context,
            'Google Maps',
            Icons.map,
            Colors.blue,
            () => MapNavigationHelper.openGoogleMaps(
              latitude: widget.latitude,
              longitude: widget.longitude,
              venue: widget.venue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
