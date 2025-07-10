import 'package:flutter/material.dart';
import '../widgets/multi_map_widget.dart';
import '../../../../data/services/location_search_service.dart';
import '../../../../data/models/venue_model.dart';
import '../../../../data/repositories/saved_locations_repository.dart';

class CombinedMapScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialVenue;
  final MapProvider? initialProvider;

  const CombinedMapScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialVenue,
    this.initialProvider,
  });

  @override
  State<CombinedMapScreen> createState() => _CombinedMapScreenState();
}

class _CombinedMapScreenState extends State<CombinedMapScreen> {
  final SavedLocationsRepository _savedLocationsRepository = SavedLocationsRepository();
  List<VenueModel> _savedLocations = [];
  
  // Default to Seoul if no initial location provided
  late double _currentLatitude;
  late double _currentLongitude;
  late String _currentVenueName;
  late MapProvider _currentProvider;

  @override
  void initState() {
    super.initState();
    _currentLatitude = widget.initialLatitude ?? 37.5665;
    _currentLongitude = widget.initialLongitude ?? 126.9780;
    _currentVenueName = widget.initialVenue ?? 'Seoul';
    _currentProvider = widget.initialProvider ?? MapProvider.google;
    _loadSavedLocations();
  }

  Future<void> _loadSavedLocations() async {
    final locations = await _savedLocationsRepository.getSavedLocations();
    setState(() {
      _savedLocations = locations;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps'),
        backgroundColor: _getProviderColor(_currentProvider),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: _showSavedLocations,
          ),
          PopupMenuButton<MapProvider>(
            icon: const Icon(Icons.map),
            onSelected: (provider) {
              setState(() {
                _currentProvider = provider;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: MapProvider.google,
                child: Row(
                  children: [
                    Icon(Icons.map, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Google Maps'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: MapProvider.kakao,
                child: Row(
                  children: [
                    Icon(Icons.map, color: Colors.yellow.shade700),
                    SizedBox(width: 8),
                    Text('Kakao Maps'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: MapProvider.naver,
                child: Row(
                  children: [
                    Icon(Icons.map, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Naver Maps'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MultiMapWidget(
              latitude: _currentLatitude,
              longitude: _currentLongitude,
              venue: _currentVenueName,
              provider: _currentProvider,
              showControls: true,
              showDirections: true,
              showSearch: true,
              isEditMode: true, // Show provider selector
              height: double.infinity,
              onLocationSelected: (result) {
                setState(() {
                  _currentLatitude = result.latitude;
                  _currentLongitude = result.longitude;
                  _currentVenueName = result.name;
                });
              },
              onLocationSaved: (venue) {
                _loadSavedLocations();
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getProviderColor(MapProvider provider) {
    switch (provider) {
      case MapProvider.google:
        return Colors.blue;
      case MapProvider.kakao:
        return Colors.yellow.shade700;
      case MapProvider.naver:
        return Colors.green;
    }
  }

  void _showSavedLocations() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildSavedLocationsSheet(),
    );
  }

  Widget _buildSavedLocationsSheet() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '저장된 위치',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () async {
                  await _savedLocationsRepository.clearSavedLocations();
                  await _loadSavedLocations();
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('모두 삭제'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _savedLocations.isEmpty
                ? const Center(
                    child: Text('저장된 위치가 없습니다.'),
                  )
                : ListView.builder(
                    itemCount: _savedLocations.length,
                    itemBuilder: (context, index) {
                      final location = _savedLocations[index];
                      return ListTile(
                        leading: Icon(
                          Icons.location_on, 
                          color: _getProviderColor(_currentProvider),
                        ),
                        title: Text(location.name),
                        subtitle: Text(location.address),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await _savedLocationsRepository.removeLocation(location.id);
                            await _loadSavedLocations();
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _currentLatitude = location.latitude;
                            _currentLongitude = location.longitude;
                            _currentVenueName = location.name;
                          });
                          if (mounted) Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}