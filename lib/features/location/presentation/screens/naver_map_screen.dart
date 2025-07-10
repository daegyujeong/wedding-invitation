import 'package:flutter/material.dart';
import '../widgets/multi_map_widget.dart';
import '../../../../data/services/location_search_service.dart';
import '../../../../data/models/venue_model.dart';
import '../../../../data/repositories/saved_locations_repository.dart';

class NaverMapScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialVenue;

  const NaverMapScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialVenue,
  });

  @override
  State<NaverMapScreen> createState() => _NaverMapScreenState();
}

class _NaverMapScreenState extends State<NaverMapScreen> {
  final SavedLocationsRepository _savedLocationsRepository = SavedLocationsRepository();
  List<VenueModel> _savedLocations = [];
  
  // Default to Seoul if no initial location provided
  late double _currentLatitude;
  late double _currentLongitude;
  late String _currentVenueName;

  @override
  void initState() {
    super.initState();
    _currentLatitude = widget.initialLatitude ?? 37.5665;
    _currentLongitude = widget.initialLongitude ?? 126.9780;
    _currentVenueName = widget.initialVenue ?? 'Seoul';
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
        title: const Text('Naver Maps'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: _showSavedLocations,
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
              provider: MapProvider.naver,
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
                        leading: const Icon(Icons.location_on, color: Colors.green),
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