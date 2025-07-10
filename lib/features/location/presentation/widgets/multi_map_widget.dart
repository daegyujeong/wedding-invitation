import 'package:flutter/material.dart';
import 'google_map_widget_wrapper.dart';
import 'naver_map_widget.dart';
import 'kakao_map_widget.dart';
import 'map_navigation_helper.dart';
import 'location_search_widget.dart';
import '../../../../data/services/location_search_service.dart';
import '../../../../data/repositories/saved_locations_repository.dart';
import '../../../../data/models/venue_model.dart';

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
  final bool showSearch;
  final Function(LocationSearchResult)? onLocationSelected;
  final Function(VenueModel)? onLocationSaved;

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
    this.showSearch = false,
    this.onLocationSelected,
    this.onLocationSaved,
  });

  @override
  State<MultiMapWidget> createState() => _MultiMapWidgetState();
}

class _MultiMapWidgetState extends State<MultiMapWidget> {
  late MapProvider _currentProvider;
  final SavedLocationsRepository _savedLocationsRepository = SavedLocationsRepository();
  double _currentLatitude = 0.0;
  double _currentLongitude = 0.0;
  String _currentVenueName = '';
  bool _isMapLocked = true; // Start with map locked in edit mode

  @override
  void initState() {
    super.initState();
    _currentProvider = widget.provider;
    _currentLatitude = widget.latitude;
    _currentLongitude = widget.longitude;
    _currentVenueName = widget.venue;
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
        
        // Account for search section height if showing search
        if (widget.showSearch) {
          availableMapHeight -= 120; // Search section estimated height
        }
        
        // Account for selector height if in edit mode
        if (widget.isEditMode) {
          availableMapHeight -= 48; // Selector height + margin
        }
        
        // Account for navigation buttons height if showing directions
        if (widget.showDirections) {
          availableMapHeight -= 80; // Navigation buttons height + margin
        }
        
        // Account for save button height if showing search
        if (widget.showSearch) {
          availableMapHeight -= 64; // Save button height + padding
        }
        
        // Ensure minimum map height
        availableMapHeight = availableMapHeight.clamp(100.0, widget.height);
            
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showSearch) _buildSearchSection(),
              if (widget.isEditMode) _buildMapProviderSelector(context),
              Stack(
                children: [
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
                  if (widget.isEditMode) _buildMapLockButton(),
                ],
              ),
              if (widget.showDirections) _buildNavigationButtons(context),
              if (widget.showSearch) _buildSaveButton(),
            ],
          ),
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

  Widget _buildSearchSection() {
    return LocationSearchWidget(
      provider: _currentProvider,
      onLocationSelected: _handleLocationSelected,
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: _saveCurrentLocation,
        icon: const Icon(Icons.bookmark_add),
        label: const Text('현재 위치 저장'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _handleLocationSelected(LocationSearchResult result) {
    setState(() {
      _currentLatitude = result.latitude;
      _currentLongitude = result.longitude;
      _currentVenueName = result.name;
    });
    
    widget.onLocationSelected?.call(result);
  }

  Future<void> _saveCurrentLocation() async {
    final venue = VenueModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _currentVenueName,
      address: _currentVenueName,
      latitude: _currentLatitude,
      longitude: _currentLongitude,
      country: 'Korea', // Default, should be configurable
      eventType: 'Wedding', // Default, should be configurable  
      eventDate: DateTime.now(),
      mapLinks: {},
    );

    final success = await _savedLocationsRepository.saveLocation(venue);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '위치가 저장되었습니다.' : '이미 저장된 위치입니다.'),
          backgroundColor: success ? Colors.green : Colors.orange,
        ),
      );
    }

    if (success) {
      widget.onLocationSaved?.call(venue);
    }
  }

  Widget _buildMapLockButton() {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () {
              setState(() {
                _isMapLocked = !_isMapLocked;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isMapLocked ? Icons.lock : Icons.lock_open,
                    size: 16,
                    color: _isMapLocked ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isMapLocked ? '잠금' : '해제',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _isMapLocked ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMap(double mapHeight) {
    // Determine if map controls should be enabled
    final bool enableControls = widget.isEditMode ? !_isMapLocked : widget.showControls;
    
    switch (_currentProvider) {
      case MapProvider.google:
        return GoogleMapWidgetWrapper(
          latitude: _currentLatitude,
          longitude: _currentLongitude,
          venue: _currentVenueName,
          showControls: enableControls,
          height: mapHeight, // Pass calculated height
        );
      case MapProvider.naver:
        return NaverMapWidget(
          latitude: _currentLatitude,
          longitude: _currentLongitude,
          venue: _currentVenueName,
          showControls: enableControls,
          height: mapHeight, // Pass calculated height
        );
      case MapProvider.kakao:
        return KakaoMapWidget(
          latitude: _currentLatitude,
          longitude: _currentLongitude,
          venue: _currentVenueName,
          showControls: enableControls,
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
