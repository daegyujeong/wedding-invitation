// lib/presentation/screens/location/location_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../features/location/presentation/widgets/multi_map_widget.dart';
import '../../../data/models/location_model.dart';
import '../../../providers/venue_provider.dart';
import '../../../providers/locale_provider.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  LocationModel? _selectedLocation;

  // Venue locations
  static const Map<String, Map<String, dynamic>> _venues = {
    'my': {
      'name': 'AC Hotel Kuantan',
      'latitude': 3.816691981866172,
      'longitude': 103.33681728473105,
      'address': 'Jalan Teluk Sisek, Kuantan, Pahang, Malaysia',
    },
    'sg': {
      'name': 'Arbora',
      'latitude': 1.2713102232292395,
      'longitude': 103.81929169938385,
      'address': '109 Mount Faber Road, Singapore 099203',
    },
    'ko': {
      'name': '일월의정원',
      'latitude': 35.62885057440548,
      'longitude': 129.21897305040977,
      'address': '울산광역시 울주군 두동면 은편리 891',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Location',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _buildLocationContent(context),
        ),
      ),
    );
  }

  Widget _buildLocationContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 32,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Wedding Venue',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<VenueProvider>(
                  builder: (context, venueProvider, child) {
                    final selectedVenue = venueProvider.selectedVenue;
                    final venueData = _venues[selectedVenue] ?? _venues['sg']!;
                    final venueName = venueData['name'] as String;

                    return Text(
                      'Directions to $venueName',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Venue info card
          _buildVenueCard(),

          const SizedBox(height: 16),

          // Interactive map
          _buildMapCard(context),

          const SizedBox(height: 16),

          // Place picker demo (search info)
          _buildPlacePickerDemo(),

          const SizedBox(height: 16),

          // Transportation cards
          _buildTransportationSection(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildVenueCard() {
    final venueProvider = Provider.of<VenueProvider>(context);
    final selectedVenue = venueProvider.selectedVenue;

    // If no specific venue is selected or 'all' is selected, show all venues
    if (selectedVenue == null || selectedVenue == 'all') {
      return _buildAllVenuesCard();
    }

    // Get venue data
    final venueData = _venues[selectedVenue];
    if (venueData == null) return const SizedBox.shrink();

    final venueName = venueData['name'] as String;
    final address = venueData['address'] as String;

    // Get phone number based on venue
    String phoneNumber;
    switch (selectedVenue) {
      case 'ko':
        phoneNumber = '052-264-0891';
        break;
      case 'my':
        phoneNumber = '+60 9-505 7888';
        break;
      case 'sg':
      default:
        phoneNumber = '+65 6377 9688';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venueName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getVenueSubtitle(selectedVenue ?? 'sg'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.place,
                color: Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Phone
          Row(
            children: [
              Icon(
                Icons.phone,
                color: Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                phoneNumber,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getVenueSubtitle(String venue) {
    switch (venue) {
      case 'ko':
        return 'Ulsan Garden Wedding';
      case 'my':
        return 'Kuantan Beach Resort';
      case 'sg':
      default:
        return 'Mount Faber Peak';
    }
  }

  Widget _buildMapCard(BuildContext context) {
    final venueProvider = Provider.of<VenueProvider>(context);
    final selectedVenue = venueProvider.selectedVenue;

    // If no specific venue is selected or 'all' is selected, show all venues
    if (selectedVenue == null || selectedVenue == 'all') {
      return _buildAllVenuesMaps();
    }

    // Get venue data
    final venueData = _venues[selectedVenue];
    if (venueData == null) return const SizedBox.shrink();

    final venueName = venueData['name'] as String;
    final latitude = venueData['latitude'] as double;
    final longitude = venueData['longitude'] as double;

    // For Korea venue, show tabs based on language, otherwise use default provider
    if (selectedVenue == 'ko') {
      return _buildKoreaMapWithTabs(latitude, longitude, venueName);
    }

    // Use Google Maps for other venues
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: MultiMapWidget(
          key: ValueKey('${selectedVenue}_google_map'),
          latitude: latitude,
          longitude: longitude,
          venue: venueName,
          address: _venues[selectedVenue]?['address'] as String?,
          provider: MapProvider.google,
          height: 400,
          showControls: true,
          showDirections: true,
          onMapTap: () {
            _showSnackBar(context, 'Map tapped - $venueName');
          },
        ),
      ),
    );
  }

  Widget _buildTransportationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Transportation Guide',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // MRT
        _buildTransportCard(
          icon: Icons.train,
          title: 'MRT',
          color: Colors.blue,
          details: [
            'HarbourFront MRT Station (NE1/CC29)',
            'Take Exit A to VivoCity',
            'Cable car from HarbourFront Tower 2',
          ],
        ),

        const SizedBox(height: 12),

        // Cable Car
        _buildTransportCard(
          icon: Icons.cable,
          title: 'Cable Car',
          color: Colors.orange,
          details: [
            'Singapore Cable Car from HarbourFront',
            'Mount Faber Line to Mount Faber Peak',
            'Operating hours: 8:45 AM - 10:00 PM',
          ],
        ),

        const SizedBox(height: 12),

        // Car
        _buildTransportCard(
          icon: Icons.directions_car,
          title: 'By Car',
          color: Colors.red,
          details: [
            'GPS: Arbora, Mount Faber Peak',
            'Parking available at Mount Faber',
            'Valet parking service available',
          ],
        ),
      ],
    );
  }

  Widget _buildTransportCard({
    required IconData icon,
    required String title,
    required Color color,
    required List<String> details,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...details.map((detail) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      detail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlacePickerDemo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.search_outlined,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Google Places Search',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Search for places in real-time',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Location search functionality
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Place search is available in the map view',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Selected location display
          if (_selectedLocation != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.place,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Selected Location',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedLocation!.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedLocation!.address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                        'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAllVenuesCard() {
    return Column(
      children: _venues.entries.map((entry) {
        final venueData = entry.value;
        final venueName = venueData['name'] as String;
        final address = venueData['address'] as String;

        return Container(
          margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                venueName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                address,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAllVenuesMaps() {
    return Column(
      children: _venues.entries.map((entry) {
        final venueCode = entry.key;
        final venueData = entry.value;
        final venueName = venueData['name'] as String;
        final latitude = venueData['latitude'] as double;
        final longitude = venueData['longitude'] as double;

        return Container(
          margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  venueName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // For Korea venue, show tabs even in all venues view
              if (venueCode == 'ko')
                _buildKoreaMapTabsCompact(
                    latitude, longitude, venueName, venueCode)
              else
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: MultiMapWidget(
                    key: ValueKey('${venueCode}_google_map'),
                    latitude: latitude,
                    longitude: longitude,
                    venue: venueName,
                    address: _venues[venueCode]?['address'] as String?,
                    provider: MapProvider.google,
                    height: 200,
                    showControls: false,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKoreaMapWithTabs(
      double latitude, double longitude, String venueName) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final venueProvider = Provider.of<VenueProvider>(context);
    final selectedVenue = venueProvider.selectedVenue;
    final isKorean = localeProvider.locale.languageCode == 'ko';

    return DefaultTabController(
      length: 2,
      initialIndex: isKorean ? 0 : 1, // Naver for Korean, Google for others
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Tab bar
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: TabBar(
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('네이버 지도', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Google Maps', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
                labelColor: Colors.green.shade600,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: Colors.green.shade600,
                indicatorWeight: 3,
              ),
            ),
            // Tab views
            SizedBox(
              height: 400,
              child: TabBarView(
                children: [
                  // Naver Map
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: MultiMapWidget(
                      key: ValueKey('${selectedVenue}_naver_map'),
                      latitude: latitude,
                      longitude: longitude,
                      venue: venueName,
                      address: _venues[selectedVenue]?['address'] as String?,
                      provider: MapProvider.naver,
                      height: 400,
                      showControls: true,
                      showDirections: true,
                    ),
                  ),
                  // Google Map
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: MultiMapWidget(
                      key: ValueKey('${selectedVenue}_google_map'),
                      latitude: latitude,
                      longitude: longitude,
                      venue: venueName,
                      address: _venues[selectedVenue]?['address'] as String?,
                      provider: MapProvider.google,
                      height: 400,
                      showControls: true,
                      showDirections: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKoreaMapTabsCompact(
      double latitude, double longitude, String venueName, String venueCode) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isKorean = localeProvider.locale.languageCode == 'ko';

    return DefaultTabController(
      length: 2,
      initialIndex: isKorean ? 0 : 1, // Naver for Korean, Google for others
      child: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: TabBar(
              tabs: const [
                Tab(
                  child: Text('네이버 지도', style: TextStyle(fontSize: 12)),
                ),
                Tab(
                  child: Text('Google Maps', style: TextStyle(fontSize: 12)),
                ),
              ],
              labelColor: Colors.green.shade600,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Colors.green.shade600,
              indicatorWeight: 2,
            ),
          ),
          // Tab views
          SizedBox(
            height: 200,
            child: TabBarView(
              children: [
                // Naver Map
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: MultiMapWidget(
                    key: ValueKey('${venueCode}_naver_compact_map'),
                    latitude: latitude,
                    longitude: longitude,
                    venue: venueName,
                    address: _venues[venueCode]?['address'] as String?,
                    provider: MapProvider.naver,
                    height: 200,
                    showControls: false,
                    showDirections: false,
                  ),
                ),
                // Google Map
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: MultiMapWidget(
                    key: ValueKey('${venueCode}_google_compact_map'),
                    latitude: latitude,
                    longitude: longitude,
                    venue: venueName,
                    address: _venues[venueCode]?['address'] as String?,
                    provider: MapProvider.google,
                    height: 200,
                    showControls: false,
                    showDirections: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
