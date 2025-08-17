// lib/data/repositories/interfaces/location_repository.dart
import '../../models/venue_model.dart';
import '../../services/location_search_service.dart';

/// Abstract repository interface for location and venue operations
abstract class ILocationRepository {
  /// Search for locations using query
  Future<List<LocationSearchResult>> searchLocations(String query, {String provider = 'google'});

  /// Get venue details by ID
  Future<VenueModel?> getVenueById(String venueId);

  /// Save a venue
  Future<bool> saveVenue(VenueModel venue);

  /// Update venue information
  Future<bool> updateVenue(VenueModel venue);

  /// Delete a venue
  Future<bool> deleteVenue(String venueId);

  /// Get all saved venues
  Future<List<VenueModel>> getSavedVenues();

  /// Get venues by event type (Wedding, Reception, etc.)
  Future<List<VenueModel>> getVenuesByEventType(String eventType);

  /// Get venues by country
  Future<List<VenueModel>> getVenuesByCountry(String country);

  /// Get venues within a date range
  Future<List<VenueModel>> getVenuesByDateRange(DateTime startDate, DateTime endDate);

  /// Search venues by address
  Future<List<VenueModel>> searchVenuesByAddress(String address);

  /// Get venues near coordinates (within radius in meters)
  Future<List<VenueModel>> getVenuesNearLocation(double latitude, double longitude, {double radiusMeters = 1000});

  /// Add map links to a venue
  Future<bool> addMapLinks(String venueId, Map<String, String> mapLinks);

  /// Get map links for a venue
  Future<Map<String, String>> getMapLinks(String venueId);

  /// Generate map link for specific provider
  Future<String?> generateMapLink(VenueModel venue, String provider);

  /// Check if venue has valid coordinates
  Future<bool> hasValidCoordinates(String venueId);

  /// Update venue coordinates
  Future<bool> updateVenueCoordinates(String venueId, double latitude, double longitude);

  /// Get default venue (main wedding location)
  Future<VenueModel?> getDefaultVenue();

  /// Set venue as default
  Future<bool> setDefaultVenue(String venueId);

  /// Clear all saved locations
  Future<bool> clearAllVenues();
}