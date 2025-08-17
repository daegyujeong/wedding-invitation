// lib/data/repositories/location_repository_impl.dart
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/venue_model.dart';
import '../services/location_search_service.dart';
import 'interfaces/location_repository.dart';

class LocationRepositoryImpl implements ILocationRepository {
  static const String _venuesKey = 'saved_venues';
  static const String _defaultVenueKey = 'default_venue_id';
  
  final LocationSearchService _locationSearchService;
  
  LocationRepositoryImpl(this._locationSearchService);

  @override
  Future<List<LocationSearchResult>> searchLocations(String query, {String provider = 'google'}) async {
    try {
      return await _locationSearchService.search(query, provider);
    } catch (e) {
      print('Error searching locations: $e');
      return [];
    }
  }

  @override
  Future<VenueModel?> getVenueById(String venueId) async {
    final venues = await getSavedVenues();
    try {
      return venues.firstWhere((venue) => venue.id == venueId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> saveVenue(VenueModel venue) async {
    try {
      final venues = await getSavedVenues();
      
      // Check if venue already exists, update if it does
      final existingIndex = venues.indexWhere((v) => v.id == venue.id);
      if (existingIndex >= 0) {
        venues[existingIndex] = venue;
      } else {
        venues.add(venue);
      }
      
      return await _saveVenues(venues);
    } catch (e) {
      print('Error saving venue: $e');
      return false;
    }
  }

  @override
  Future<bool> updateVenue(VenueModel venue) async {
    try {
      final venues = await getSavedVenues();
      final index = venues.indexWhere((v) => v.id == venue.id);
      
      if (index == -1) return false;
      
      venues[index] = venue;
      return await _saveVenues(venues);
    } catch (e) {
      print('Error updating venue: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteVenue(String venueId) async {
    try {
      final venues = await getSavedVenues();
      venues.removeWhere((venue) => venue.id == venueId);
      
      return await _saveVenues(venues);
    } catch (e) {
      print('Error deleting venue: $e');
      return false;
    }
  }

  @override
  Future<List<VenueModel>> getSavedVenues() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final venuesJson = prefs.getString(_venuesKey);
      
      if (venuesJson == null) return [];
      
      final List<dynamic> venuesList = json.decode(venuesJson);
      return venuesList.map((json) => VenueModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading venues: $e');
      return [];
    }
  }

  @override
  Future<List<VenueModel>> getVenuesByEventType(String eventType) async {
    final venues = await getSavedVenues();
    return venues.where((venue) => venue.eventType == eventType).toList();
  }

  @override
  Future<List<VenueModel>> getVenuesByCountry(String country) async {
    final venues = await getSavedVenues();
    return venues.where((venue) => venue.country == country).toList();
  }

  @override
  Future<List<VenueModel>> getVenuesByDateRange(DateTime startDate, DateTime endDate) async {
    final venues = await getSavedVenues();
    return venues.where((venue) => 
      venue.eventDate.isAfter(startDate) && venue.eventDate.isBefore(endDate)
    ).toList();
  }

  @override
  Future<List<VenueModel>> searchVenuesByAddress(String address) async {
    final venues = await getSavedVenues();
    final query = address.toLowerCase();
    return venues.where((venue) => 
      venue.address.toLowerCase().contains(query) ||
      venue.name.toLowerCase().contains(query)
    ).toList();
  }

  @override
  Future<List<VenueModel>> getVenuesNearLocation(
    double latitude, 
    double longitude, 
    {double radiusMeters = 1000}
  ) async {
    final venues = await getSavedVenues();
    return venues.where((venue) {
      final distance = _calculateDistance(latitude, longitude, venue.latitude, venue.longitude);
      return distance <= radiusMeters;
    }).toList();
  }

  @override
  Future<bool> addMapLinks(String venueId, Map<String, String> mapLinks) async {
    try {
      final venue = await getVenueById(venueId);
      if (venue == null) return false;
      
      final updatedMapLinks = {...venue.mapLinks, ...mapLinks};
      final updatedVenue = VenueModel(
        id: venue.id,
        name: venue.name,
        address: venue.address,
        latitude: venue.latitude,
        longitude: venue.longitude,
        country: venue.country,
        eventType: venue.eventType,
        eventDate: venue.eventDate,
        mapLinks: updatedMapLinks,
      );
      
      return await updateVenue(updatedVenue);
    } catch (e) {
      print('Error adding map links: $e');
      return false;
    }
  }

  @override
  Future<Map<String, String>> getMapLinks(String venueId) async {
    final venue = await getVenueById(venueId);
    return venue?.mapLinks ?? {};
  }

  @override
  Future<String?> generateMapLink(VenueModel venue, String provider) async {
    switch (provider.toLowerCase()) {
      case 'google':
        return 'https://maps.google.com/?q=${venue.latitude},${venue.longitude}';
      case 'naver':
        return 'https://map.naver.com/v5/?c=${venue.longitude},${venue.latitude},15,0,0,0,dh';
      case 'kakao':
        return 'https://map.kakao.com/link/map/${venue.name},${venue.latitude},${venue.longitude}';
      default:
        return null;
    }
  }

  @override
  Future<bool> hasValidCoordinates(String venueId) async {
    final venue = await getVenueById(venueId);
    if (venue == null) return false;
    
    return venue.latitude != 0.0 && venue.longitude != 0.0;
  }

  @override
  Future<bool> updateVenueCoordinates(String venueId, double latitude, double longitude) async {
    try {
      final venue = await getVenueById(venueId);
      if (venue == null) return false;
      
      final updatedVenue = VenueModel(
        id: venue.id,
        name: venue.name,
        address: venue.address,
        latitude: latitude,
        longitude: longitude,
        country: venue.country,
        eventType: venue.eventType,
        eventDate: venue.eventDate,
        mapLinks: venue.mapLinks,
      );
      
      return await updateVenue(updatedVenue);
    } catch (e) {
      print('Error updating venue coordinates: $e');
      return false;
    }
  }

  @override
  Future<VenueModel?> getDefaultVenue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final defaultVenueId = prefs.getString(_defaultVenueKey);
      
      if (defaultVenueId == null) return null;
      
      return await getVenueById(defaultVenueId);
    } catch (e) {
      print('Error getting default venue: $e');
      return null;
    }
  }

  @override
  Future<bool> setDefaultVenue(String venueId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_defaultVenueKey, venueId);
    } catch (e) {
      print('Error setting default venue: $e');
      return false;
    }
  }

  @override
  Future<bool> clearAllVenues() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final results = await Future.wait([
        prefs.remove(_venuesKey),
        prefs.remove(_defaultVenueKey),
      ]);
      
      return results.every((result) => result);
    } catch (e) {
      print('Error clearing venues: $e');
      return false;
    }
  }

  // Private helper methods
  Future<bool> _saveVenues(List<VenueModel> venues) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final venuesJson = json.encode(venues.map((v) => v.toJson()).toList());
      return await prefs.setString(_venuesKey, venuesJson);
    } catch (e) {
      print('Error saving venues: $e');
      return false;
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth radius in meters
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}