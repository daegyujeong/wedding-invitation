import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../core/config/environment.dart';
import '../models/venue_model.dart';

class LocationSearchResult {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String provider; // 'google', 'kakao', 'naver'

  LocationSearchResult({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.provider,
  });

  VenueModel toVenueModel({
    required String eventType,
    required DateTime eventDate,
    required String country,
  }) {
    return VenueModel(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      country: country,
      eventType: eventType,
      eventDate: eventDate,
      mapLinks: {},
    );
  }
}

class LocationSearchService {
  static const String _googleBaseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _kakaoBaseUrl = 'https://dapi.kakao.com/v2/local/search';
  static const String _naverBaseUrl = 'https://naveropenapi.apigw.ntruss.com/map-geocode/v2';

  // Google Places API 검색
  Future<List<LocationSearchResult>> searchGoogle(String query) async {
    try {
      final String apiKey = Environment.googleMapsApiKey;
      if (apiKey.isEmpty) return [];

      // For web, use a fallback search with mock data to avoid CORS issues
      if (kIsWeb) {
        return _getWebFallbackResults(query);
      }

      // Google Places Text Search API
      final Uri uri = Uri.parse('$_googleBaseUrl/textsearch/json')
          .replace(queryParameters: {
        'query': query,
        'key': apiKey,
        'language': 'ko',
      });

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        try {
          // Check if response is actually JSON
          final contentType = response.headers['content-type'];
          if (contentType == null || !contentType.contains('application/json')) {
            print('Google API returned non-JSON response: $contentType');
            return [];
          }
          
          final data = json.decode(response.body);
          if (data == null || data is! Map<String, dynamic>) {
            print('Google API returned invalid JSON structure');
            return [];
          }
          
          final results = data['results'] as List? ?? [];
          if (results.isEmpty) {
            print('Google API returned empty results for query: $query');
            return [];
          }
        
        return results.map((result) {
          try {
            final geometry = result['geometry']?['location'];
            if (geometry == null) {
              print('Missing geometry data in result: $result');
              return null;
            }
            
            final lat = geometry['lat'];
            final lng = geometry['lng'];
            if (lat == null || lng == null) {
              print('Missing lat/lng in geometry: $geometry');
              return null;
            }
            
            return LocationSearchResult(
              id: result['place_id']?.toString() ?? '',
              name: result['name']?.toString() ?? '',
              address: result['formatted_address']?.toString() ?? '',
              latitude: double.tryParse(lat.toString()) ?? 0.0,
              longitude: double.tryParse(lng.toString()) ?? 0.0,
              provider: 'google',
            );
          } catch (e) {
            print('Error parsing search result: $e, Result: $result');
            return null;
          }
        }).where((result) => result != null).cast<LocationSearchResult>().toList();
        } catch (e) {
          print('Google search JSON parsing error: $e');
          print('Response body: ${response.body}');
          return [];
        }
      } else {
        print('Google API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Google search error: $e');
    }
    return [];
  }

  // Kakao Local API 검색
  Future<List<LocationSearchResult>> searchKakao(String query) async {
    try {
      // For web, use fallback search to avoid CORS issues
      if (kIsWeb) {
        final results = await _getWebFallbackResults(query);
        return results.map((result) => LocationSearchResult(
          id: result.id,
          name: result.name,
          address: result.address,
          latitude: result.latitude,
          longitude: result.longitude,
          provider: 'kakao',
        )).toList();
      }

      final String apiKey = Environment.kakaoMapsApiKey;
      if (apiKey.isEmpty || apiKey == 'YOUR_KAKAO_API_KEY') {
        // Fall back to Google search if Kakao API key not available
        print('Kakao API key not configured, falling back to Google');
        final googleResults = await searchGoogle(query);
        return googleResults.map((result) => LocationSearchResult(
          id: result.id,
          name: result.name,
          address: result.address,
          latitude: result.latitude,
          longitude: result.longitude,
          provider: 'kakao-fallback',
        )).toList();
      }

      final Uri uri = Uri.parse('$_kakaoBaseUrl/keyword.json')
          .replace(queryParameters: {
        'query': query,
        'size': '10',
      });

      final response = await http.get(uri, headers: {
        'Authorization': 'KakaoAK $apiKey',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final documents = data['documents'] as List;
        
        return documents.map((doc) {
          return LocationSearchResult(
            id: doc['id'] ?? '',
            name: doc['place_name'] ?? '',
            address: doc['address_name'] ?? '',
            latitude: double.parse(doc['y']),
            longitude: double.parse(doc['x']),
            provider: 'kakao',
          );
        }).toList();
      }
    } catch (e) {
      print('Kakao search error: $e, falling back to Google');
      // Fall back to Google on error
      final googleResults = await searchGoogle(query);
      return googleResults.map((result) => LocationSearchResult(
        id: result.id,
        name: result.name,
        address: result.address,
        latitude: result.latitude,
        longitude: result.longitude,
        provider: 'kakao-fallback',
      )).toList();
    }
    return [];
  }

  // Naver Geocoding API 검색
  Future<List<LocationSearchResult>> searchNaver(String query) async {
    try {
      // For web, use fallback search to avoid CORS issues
      if (kIsWeb) {
        final results = await _getWebFallbackResults(query);
        return results.map((result) => LocationSearchResult(
          id: result.id,
          name: result.name,
          address: result.address,
          latitude: result.latitude,
          longitude: result.longitude,
          provider: 'naver',
        )).toList();
      }

      final String clientId = Environment.naverClientId;
      final String clientSecret = Environment.naverClientSecret;
      if (clientId.isEmpty || clientSecret.isEmpty || 
          clientId == 'YOUR_NAVER_CLIENT_ID' || clientSecret == 'YOUR_NAVER_CLIENT_SECRET') {
        // Fall back to Google search if Naver API keys not available
        print('Naver API keys not configured, falling back to Google');
        final googleResults = await searchGoogle(query);
        return googleResults.map((result) => LocationSearchResult(
          id: result.id,
          name: result.name,
          address: result.address,
          latitude: result.latitude,
          longitude: result.longitude,
          provider: 'naver-fallback',
        )).toList();
      }

      final Uri uri = Uri.parse('$_naverBaseUrl/geocode')
          .replace(queryParameters: {
        'query': query,
        'count': '10',
      });

      final response = await http.get(uri, headers: {
        'X-NCP-APIGW-API-KEY-ID': clientId,
        'X-NCP-APIGW-API-KEY': clientSecret,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addresses = data['addresses'] as List;
        
        return addresses.map((addr) {
          return LocationSearchResult(
            id: addr['roadAddress'] ?? addr['jibunAddress'] ?? '',
            name: addr['roadAddress'] ?? addr['jibunAddress'] ?? '',
            address: addr['roadAddress'] ?? addr['jibunAddress'] ?? '',
            latitude: double.parse(addr['y']),
            longitude: double.parse(addr['x']),
            provider: 'naver',
          );
        }).toList();
      }
    } catch (e) {
      print('Naver search error: $e, falling back to Google');
      // Fall back to Google on error
      final googleResults = await searchGoogle(query);
      return googleResults.map((result) => LocationSearchResult(
        id: result.id,
        name: result.name,
        address: result.address,
        latitude: result.latitude,
        longitude: result.longitude,
        provider: 'naver-fallback',
      )).toList();
    }
    return [];
  }

  // 통합 검색 (활성 프로바이더에 따라)
  Future<List<LocationSearchResult>> search(String query, String provider) async {
    switch (provider.toLowerCase()) {
      case 'google':
        return await searchGoogle(query);
      case 'kakao':
        return await searchKakao(query);
      case 'naver':
        return await searchNaver(query);
      default:
        return await searchGoogle(query);
    }
  }

  // Web fallback search with common Korean locations
  Future<List<LocationSearchResult>> _getWebFallbackResults(String query) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final normalizedQuery = query.toLowerCase();
    final List<LocationSearchResult> commonLocations = [
      LocationSearchResult(
        id: 'seoul_city_hall',
        name: '서울시청',
        address: '서울특별시 중구 태평로1가 31',
        latitude: 37.5666805,
        longitude: 126.9784147,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'gangnam_station',
        name: '강남역',
        address: '서울특별시 강남구 강남대로 지하396',
        latitude: 37.4979462,
        longitude: 127.0276368,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'hongdae',
        name: '홍대입구역',
        address: '서울특별시 마포구 양화로 지하160',
        latitude: 37.5571621,
        longitude: 126.9233316,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'myeongdong',
        name: '명동역',
        address: '서울특별시 중구 명동2가 25-36',
        latitude: 37.5636228,
        longitude: 126.9838673,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'jamsil',
        name: '잠실역',
        address: '서울특별시 송파구 올림픽로 지하265',
        latitude: 37.5132379,
        longitude: 127.1001822,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'busan_station',
        name: '부산역',
        address: '부산광역시 동구 중앙대로 206',
        latitude: 35.1154813,
        longitude: 129.0423678,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'lotte_world_tower',
        name: '롯데월드타워',
        address: '서울특별시 송파구 올림픽로 300',
        latitude: 37.5125967,
        longitude: 127.1025378,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'n_seoul_tower',
        name: 'N서울타워',
        address: '서울특별시 용산구 남산공원길 105',
        latitude: 37.5511694,
        longitude: 126.9882266,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'coex',
        name: 'COEX',
        address: '서울특별시 강남구 영동대로 513',
        latitude: 37.5115557,
        longitude: 127.0595261,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'konkuk_university',
        name: '건대입구역',
        address: '서울특별시 광진구 능동로 지하110',
        latitude: 37.5403049,
        longitude: 127.0707933,
        provider: 'google',
      ),
    ];

    // Filter results based on query
    return commonLocations.where((location) {
      return location.name.toLowerCase().contains(normalizedQuery) ||
             location.address.toLowerCase().contains(normalizedQuery);
    }).toList();
  }
}