import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/multi_map_widget.dart';
import '../../../../data/services/location_search_service.dart';
import '../../../../data/models/venue_model.dart';
import '../../../../data/repositories/saved_locations_repository.dart';

class MapTestScreen extends StatefulWidget {
  const MapTestScreen({super.key});

  @override
  State<MapTestScreen> createState() => _MapTestScreenState();
}

class _MapTestScreenState extends State<MapTestScreen> {
  final SavedLocationsRepository _savedLocationsRepository = SavedLocationsRepository();
  List<VenueModel> _savedLocations = [];
  
  // Default to Seoul
  double _currentLatitude = 37.5665;
  double _currentLongitude = 126.9780;
  String _currentVenueName = 'Seoul City Hall';
  MapProvider _currentProvider = MapProvider.google;

  @override
  void initState() {
    super.initState();
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
        title: const Text('Map Widget Test'),
        backgroundColor: _getProviderColor(_currentProvider),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: _showSavedLocations,
          ),
          // Debug button to clear all data
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('saved_locations');
              await prefs.remove('recent_searches');
              await _loadSavedLocations();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All map data cleared!')),
                );
              }
            },
            tooltip: 'Clear all map data',
          ),
        ],
      ),
      body: Column(
        children: [
          // Provider selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProviderChip(MapProvider.google, 'Google', Colors.blue),
                _buildProviderChip(MapProvider.kakao, 'Kakao', Colors.yellow.shade700),
                _buildProviderChip(MapProvider.naver, 'Naver', Colors.green),
              ],
            ),
          ),
          
          // Status indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: Text(
              'Current Provider: ${_currentProvider.toString().split('.').last.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Map widget
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: MultiMapWidget(
                latitude: _currentLatitude,
                longitude: _currentLongitude,
                venue: _currentVenueName,
                provider: _currentProvider,
                showControls: true,
                showDirections: true,
                showSearch: true,
                height: double.infinity,
                onLocationSelected: (result) {
                  setState(() {
                    _currentLatitude = result.latitude;
                    _currentLongitude = result.longitude;
                    _currentVenueName = result.name;
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected: ${result.name}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                onLocationSaved: (venue) {
                  _loadSavedLocations();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Location saved!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Quick test locations
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Test Locations:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickLocationButton('Seoul', 37.5665, 126.9780),
                    _buildQuickLocationButton('Busan', 35.1796, 129.0756),
                    _buildQuickLocationButton('Jeju', 33.4996, 126.5312),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderChip(MapProvider provider, String label, Color color) {
    final isSelected = _currentProvider == provider;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withOpacity(0.3),
      checkmarkColor: color,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _currentProvider = provider;
          });
        }
      },
    );
  }

  Widget _buildQuickLocationButton(String name, double lat, double lng) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _currentLatitude = lat;
          _currentLongitude = lng;
          _currentVenueName = name;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _getProviderColor(_currentProvider).withOpacity(0.1),
        foregroundColor: _getProviderColor(_currentProvider),
      ),
      child: Text(name),
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
                'Saved Locations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () async {
                  await _savedLocationsRepository.clearSavedLocations();
                  await _loadSavedLocations();
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _savedLocations.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No saved locations yet'),
                        SizedBox(height: 4),
                        Text(
                          'Search for places and save them!',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
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
                          icon: const Icon(Icons.delete, color: Colors.red),
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