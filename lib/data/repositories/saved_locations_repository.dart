import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/venue_model.dart';
import '../services/location_search_service.dart';

class SavedLocationsRepository {
  static const String _savedLocationsKey = 'saved_locations';
  static const String _recentSearchesKey = 'recent_searches';

  // 저장된 장소 조회
  Future<List<VenueModel>> getSavedLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_savedLocationsKey);
      
      if (jsonString != null && jsonString.isNotEmpty) {
        try {
          final dynamic decoded = json.decode(jsonString);
          if (decoded is! List) {
            print('Saved locations data is not a list, resetting...');
            await prefs.remove(_savedLocationsKey);
            return [];
          }
          
          final List<dynamic> jsonList = decoded;
          final List<VenueModel> venues = [];
          
          for (int i = 0; i < jsonList.length; i++) {
            try {
              final venue = VenueModel.fromJson(jsonList[i]);
              venues.add(venue);
            } catch (e) {
              print('Error parsing venue at index $i: $e, Data: ${jsonList[i]}');
              // Skip corrupted venue but continue with others
            }
          }
          
          return venues;
        } catch (e) {
          print('Error parsing saved locations JSON: $e');
          print('Corrupted JSON: $jsonString');
          // Clear corrupted data
          await prefs.remove(_savedLocationsKey);
        }
      }
    } catch (e) {
      print('Error loading saved locations: $e');
    }
    return [];
  }

  // 장소 저장
  Future<bool> saveLocation(VenueModel venue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocations = await getSavedLocations();
      
      // 중복 체크 (같은 ID나 같은 좌표)
      final exists = savedLocations.any((location) => 
        location.id == venue.id || 
        (location.latitude == venue.latitude && location.longitude == venue.longitude)
      );
      
      if (!exists) {
        savedLocations.add(venue);
        final String jsonString = json.encode(
          savedLocations.map((v) => v.toJson()).toList()
        );
        await prefs.setString(_savedLocationsKey, jsonString);
        return true;
      }
      return false; // 이미 존재함
    } catch (e) {
      print('Error saving location: $e');
      return false;
    }
  }

  // 장소 삭제
  Future<bool> removeLocation(String locationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocations = await getSavedLocations();
      
      final initialLength = savedLocations.length;
      savedLocations.removeWhere((location) => location.id == locationId);
      
      if (savedLocations.length < initialLength) {
        final String jsonString = json.encode(
          savedLocations.map((v) => v.toJson()).toList()
        );
        await prefs.setString(_savedLocationsKey, jsonString);
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing location: $e');
      return false;
    }
  }

  // 모든 저장된 장소 삭제
  Future<void> clearSavedLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedLocationsKey);
    } catch (e) {
      print('Error clearing saved locations: $e');
    }
  }

  // 최근 검색어 저장
  Future<void> saveRecentSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> recentSearches = await getRecentSearches();
      
      // 중복 제거
      recentSearches.removeWhere((search) => search == query);
      
      // 새로운 검색어를 맨 앞에 추가
      recentSearches.insert(0, query);
      
      // 최대 10개까지만 저장
      if (recentSearches.length > 10) {
        recentSearches = recentSearches.sublist(0, 10);
      }
      
      final String jsonString = json.encode(recentSearches);
      await prefs.setString(_recentSearchesKey, jsonString);
    } catch (e) {
      print('Error saving recent search: $e');
    }
  }

  // 최근 검색어 조회
  Future<List<String>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_recentSearchesKey);
      
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.cast<String>();
      }
    } catch (e) {
      print('Error loading recent searches: $e');
    }
    return [];
  }

  // 최근 검색어 삭제
  Future<void> clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);
    } catch (e) {
      print('Error clearing recent searches: $e');
    }
  }

  // 검색 결과를 VenueModel로 변환하여 저장
  Future<bool> saveSearchResult(
    LocationSearchResult result, {
    required String eventType,
    required DateTime eventDate,
    required String country,
  }) async {
    final venue = result.toVenueModel(
      eventType: eventType,
      eventDate: eventDate,
      country: country,
    );
    return await saveLocation(venue);
  }
}