import 'dart:async';
import 'package:flutter/foundation.dart';
import 'location_search_service.dart';

// Use web-compatible interop
import 'dart:js' as js;

class GooglePlacesWebService {
  static const Duration _debounceDelay = Duration(milliseconds: 300);
  Timer? _debounceTimer;
  
  // Google Places API를 사용한 실시간 검색
  Future<List<LocationSearchResult>> searchPlaces(String query) async {
    if (!kIsWeb) {
      throw UnsupportedError('This service is only available on web platform');
    }
    
    if (query.trim().isEmpty) {
      return [];
    }
    
    try {
      final completer = Completer<List<LocationSearchResult>>();
      
      // Check if Google Places API is available
      if (js.context['placesSearchService'] == null) {
        debugPrint('Google Places API service not available');
        completer.complete([]);
        return completer.future;
      }
      
      // Create callback function
      js.JsFunction callback = js.JsFunction.withThis((self, result) {
        try {
          if (result == null) {
            completer.complete([]);
            return;
          }
          
          // Convert JS object to Dart
          final resultMap = _convertJsObject(result);
          
          if (resultMap['error'] != null) {
            debugPrint('Places API error: ${resultMap['error']}');
            completer.complete([]);
            return;
          }
          
          final List<dynamic> results = resultMap['results'] ?? [];
          final searchResults = results.map((place) {
            final placeMap = place is Map ? place : _convertJsObject(place);
            return LocationSearchResult(
              id: placeMap['id']?.toString() ?? '',
              name: placeMap['name']?.toString() ?? '',
              address: placeMap['address']?.toString() ?? '',
              latitude: 0.0, // Will be filled by getPlaceDetails
              longitude: 0.0,
              provider: 'google_places',
            );
          }).toList();
          
          completer.complete(searchResults);
        } catch (e) {
          debugPrint('Error processing search results: $e');
          completer.complete([]);
        }
      });
      
      // Call JavaScript function
      js.context['placesSearchService'].callMethod('searchPlaces', [query, callback]);
      
      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Places search timeout');
          return <LocationSearchResult>[];
        },
      );
    } catch (e) {
      debugPrint('Places search error: $e');
      return [];
    }
  }
  
  // Place ID로 상세 정보 가져오기 (레거시 방법, 기존 호환성을 위해 유지)
  Future<LocationSearchResult?> getLocationDetails(String placeId, String name, String address) async {
    final details = await getPlaceDetails(placeId);
    if (details == null) {
      return LocationSearchResult(
        id: placeId,
        name: name,
        address: address,
        latitude: 37.5665,
        longitude: 126.9780,
        provider: 'google_places',
      );
    }
    
    return LocationSearchResult(
      id: details['place_id'] ?? placeId,
      name: details['name'] ?? name,
      address: details['formatted_address'] ?? address,
      latitude: details['geometry']?['location']?['lat']?.toDouble() ?? 37.5665,
      longitude: details['geometry']?['location']?['lng']?.toDouble() ?? 126.9780,
      provider: 'google_places',
    );
  }
  
  // 텍스트 검색 (더 포괄적인 검색)
  Future<List<LocationSearchResult>> textSearch(String query) async {
    if (!kIsWeb) {
      throw UnsupportedError('This service is only available on web platform');
    }
    
    if (query.trim().isEmpty) {
      return [];
    }
    
    try {
      final completer = Completer<List<LocationSearchResult>>();
      
      // Check if Google Places API is available
      if (js.context['placesSearchService'] == null) {
        debugPrint('Google Places API service not available');
        completer.complete([]);
        return completer.future;
      }
      
      js.JsFunction callback = js.JsFunction.withThis((self, result) {
        try {
          if (result == null) {
            completer.complete([]);
            return;
          }
          
          final resultMap = _convertJsObject(result);
          
          if (resultMap['error'] != null) {
            debugPrint('Text search error: ${resultMap['error']}');
            completer.complete([]);
            return;
          }
          
          final List<dynamic> results = resultMap['results'] ?? [];
          final searchResults = results.map((place) {
            final placeMap = place is Map ? place : _convertJsObject(place);
            return LocationSearchResult(
              id: placeMap['id']?.toString() ?? '',
              name: placeMap['name']?.toString() ?? '',
              address: placeMap['address']?.toString() ?? '',
              latitude: _parseDouble(placeMap['latitude']) ?? 37.5665,
              longitude: _parseDouble(placeMap['longitude']) ?? 126.9780,
              provider: 'google_places',
            );
          }).toList();
          
          completer.complete(searchResults);
        } catch (e) {
          debugPrint('Error processing text search results: $e');
          completer.complete([]);
        }
      });
      
      js.context['placesSearchService'].callMethod('textSearch', [query, callback]);
      
      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Text search timeout');
          return <LocationSearchResult>[];
        },
      );
    } catch (e) {
      debugPrint('Text search error: $e');
      return [];
    }
  }
  
  // 디바운스된 검색 (타이핑할 때 너무 많은 요청 방지)
  Future<List<LocationSearchResult>> debouncedSearch(String query) async {
    final completer = Completer<List<LocationSearchResult>>();
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () async {
      try {
        final results = await searchPlaces(query);
        completer.complete(results);
      } catch (e) {
        completer.complete([]);
      }
    });
    
    return completer.future;
  }
  
  // JavaScript 객체를 Dart Map으로 변환
  Map<String, dynamic> _convertJsObject(dynamic jsObject) {
    if (jsObject == null) return {};
    
    try {
      // Try direct conversion first
      if (jsObject is Map) {
        return Map<String, dynamic>.from(jsObject);
      }
      
      // Use JSON stringify/parse for complex objects
      final jsonString = js.context['JSON'].callMethod('stringify', [jsObject]);
      if (jsonString is String) {
        final decoded = js.context['JSON'].callMethod('parse', [jsonString]);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      }
      
      return {};
    } catch (e) {
      debugPrint('Error converting JS object: $e');
      return {};
    }
  }
  
  // Helper to parse numbers safely
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
  
  // Get place predictions (autocomplete suggestions)
  Future<List<Map<String, dynamic>>> getPlacePredictions(String input) async {
    if (!kIsWeb) {
      throw UnsupportedError('This service is only available on web platform');
    }
    
    if (input.trim().isEmpty) {
      return [];
    }
    
    try {
      final completer = Completer<List<Map<String, dynamic>>>();
      
      // Check if Google Places API is available
      if (js.context['placesSearchService'] == null) {
        debugPrint('Google Places API service not available');
        completer.complete([]);
        return completer.future;
      }
      
      js.JsFunction callback = js.JsFunction.withThis((self, result) {
        try {
          if (result == null) {
            completer.complete([]);
            return;
          }
          
          final resultMap = _convertJsObject(result);
          
          if (resultMap['error'] != null) {
            debugPrint('Place predictions error: ${resultMap['error']}');
            completer.complete([]);
            return;
          }
          
          final List<dynamic> predictions = resultMap['predictions'] ?? resultMap['results'] ?? [];
          final predictionsList = predictions.map((prediction) {
            final predictionMap = prediction is Map ? prediction : _convertJsObject(prediction);
            return Map<String, dynamic>.from(predictionMap);
          }).toList();
          
          completer.complete(predictionsList);
        } catch (e) {
          debugPrint('Error processing place predictions: $e');
          completer.complete([]);
        }
      });
      
      // Call JavaScript function for autocomplete predictions
      js.context['placesSearchService'].callMethod('getPlacePredictions', [input, callback]);
      
      return await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('Place predictions timeout');
          return <Map<String, dynamic>>[];
        },
      );
    } catch (e) {
      debugPrint('Place predictions error: $e');
      return [];
    }
  }
  
  // Get detailed place information by place ID
  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    if (!kIsWeb) {
      throw UnsupportedError('This service is only available on web platform');
    }
    
    try {
      final completer = Completer<Map<String, dynamic>?>();
      
      // Check if Google Places API is available
      if (js.context['placesSearchService'] == null) {
        debugPrint('Google Places API service not available');
        completer.complete(null);
        return completer.future;
      }
      
      js.JsFunction callback = js.JsFunction.withThis((self, result) {
        try {
          if (result == null) {
            completer.complete(null);
            return;
          }
          
          final resultMap = _convertJsObject(result);
          
          if (resultMap['error'] != null) {
            debugPrint('Place details error: ${resultMap['error']}');
            completer.complete(null);
            return;
          }
          
          final place = resultMap['result'] is Map 
              ? resultMap['result'] 
              : _convertJsObject(resultMap['result']);
              
          completer.complete(Map<String, dynamic>.from(place));
        } catch (e) {
          debugPrint('Error processing place details: $e');
          completer.complete(null);
        }
      });
      
      js.context['placesSearchService'].callMethod('getPlaceDetails', [placeId, callback]);
      
      return await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('Place details timeout');
          return null;
        },
      );
    } catch (e) {
      debugPrint('Place details error: $e');
      return null;
    }
  }
  
  void dispose() {
    _debounceTimer?.cancel();
  }
}