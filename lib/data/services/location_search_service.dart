import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../core/config/environment.dart';
import '../models/venue_model.dart';
// import 'google_places_web_service.dart'; // Temporarily disabled

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
  
  // 웹용 실시간 검색 서비스 (lazy loading)
  // GooglePlacesWebService? _webPlacesService; // Temporarily disabled

  // Google Places API 검색
  Future<List<LocationSearchResult>> searchGoogle(String query) async {
    try {
      final String apiKey = Environment.googleMapsApiKey;
      if (apiKey.isEmpty) return [];

      // For web, use fallback results (Google Places API temporarily disabled)
      if (kIsWeb) {
        debugPrint('Using fallback web search for query: $query');
        return _getWebFallbackResults(query);
      }

      // Google Places Text Search API with language and region support
      final Map<String, String> queryParams = {
        'query': query,
        'key': apiKey,
        'language': 'ko', // Support Korean language
        'region': 'kr', // Bias results towards Korea
        'inputtype': 'textquery', // Enable text-based queries
      };
      
      // Enable international search for English queries
      if (_isEnglishQuery(query)) {
        queryParams['language'] = 'en';
        queryParams['region'] = 'us'; // For international places
      }
      
      final Uri uri = Uri.parse('$_googleBaseUrl/textsearch/json')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        try {
          // Check if response is actually JSON
          final contentType = response.headers['content-type'];
          if (contentType == null || !contentType.contains('application/json')) {
            debugPrint('Google API returned non-JSON response: $contentType');
            return [];
          }
          
          final data = json.decode(response.body);
          if (data == null || data is! Map<String, dynamic>) {
            debugPrint('Google API returned invalid JSON structure');
            return [];
          }
          
          final results = data['results'] as List? ?? [];
          if (results.isEmpty) {
            debugPrint('Google API returned empty results for query: $query');
            return [];
          }
        
        return results.map((result) {
          try {
            final geometry = result['geometry']?['location'];
            if (geometry == null) {
              debugPrint('Missing geometry data in result: $result');
              return null;
            }
            
            final lat = geometry['lat'];
            final lng = geometry['lng'];
            if (lat == null || lng == null) {
              debugPrint('Missing lat/lng in geometry: $geometry');
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
            debugPrint('Error parsing search result: $e, Result: $result');
            return null;
          }
        }).where((result) => result != null).cast<LocationSearchResult>().toList();
        } catch (e) {
          debugPrint('Google search JSON parsing error: $e');
          debugPrint('Response body: ${response.body}');
          return [];
        }
      } else {
        debugPrint('Google API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Google search error: $e');
    }
    return [];
  }

  // Kakao Local API 검색
  Future<List<LocationSearchResult>> searchKakao(String query) async {
    try {
      // For web, use fallback results (Google Places API temporarily disabled)
      if (kIsWeb) {
        debugPrint('Kakao search using fallback for web: $query');
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
        debugPrint('Kakao API key not configured, falling back to Google');
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
      debugPrint('Kakao search error: $e, falling back to Google');
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
      // For web, use fallback results (Google Places API temporarily disabled)
      if (kIsWeb) {
        debugPrint('Naver search using fallback for web: $query');
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

      const String clientId = Environment.naverClientId;
      const String clientSecret = Environment.naverClientSecret;
      if (clientId.isEmpty || clientSecret.isEmpty || 
          clientId == 'YOUR_NAVER_CLIENT_ID' || clientSecret == 'YOUR_NAVER_CLIENT_SECRET') {
        // Fall back to Google search if Naver API keys not available
        debugPrint('Naver API keys not configured, falling back to Google');
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
      debugPrint('Naver search error: $e, falling back to Google');
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

  // Helper method to detect if query is in English
  bool _isEnglishQuery(String query) {
    // Simple regex to check if query contains mainly Latin characters
    final englishRegex = RegExp(r"^[a-zA-Z\s\-.,']");
    return englishRegex.hasMatch(query.trim());
  }



  // Web fallback search with common Korean locations
  Future<List<LocationSearchResult>> _getWebFallbackResults(String query) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final normalizedQuery = query.toLowerCase().trim();
    debugPrint('Searching fallback for: "$normalizedQuery"');
    
    final List<LocationSearchResult> commonLocations = [
      // Major Korean Cities with English names
      LocationSearchResult(
        id: 'seoul_city',
        name: 'Seoul (서울)',
        address: 'Seoul, South Korea',
        latitude: 37.5665,
        longitude: 126.9780,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'busan_city',
        name: 'Busan (부산)',
        address: 'Busan, South Korea',
        latitude: 35.1796,
        longitude: 129.0756,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'ulsan_city',
        name: 'Ulsan (울산)',
        address: 'Ulsan, South Korea',
        latitude: 35.5384,
        longitude: 129.3114,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'daegu_city',
        name: 'Daegu (대구)',
        address: 'Daegu, South Korea',
        latitude: 35.8714,
        longitude: 128.6014,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'incheon_city',
        name: 'Incheon (인천)',
        address: 'Incheon, South Korea',
        latitude: 37.4563,
        longitude: 126.7052,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'gwangju_city',
        name: 'Gwangju (광주)',
        address: 'Gwangju, South Korea',
        latitude: 35.1595,
        longitude: 126.8526,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'daejeon_city',
        name: 'Daejeon (대전)',
        address: 'Daejeon, South Korea',
        latitude: 36.3504,
        longitude: 127.3845,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'suwon_city',
        name: 'Suwon (수원)',
        address: 'Suwon, Gyeonggi-do, South Korea',
        latitude: 37.2636,
        longitude: 127.0286,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'goyang_city',
        name: 'Goyang (고양)',
        address: 'Goyang, Gyeonggi-do, South Korea',
        latitude: 37.6564,
        longitude: 126.8352,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'seongnam_city',
        name: 'Seongnam (성남)',
        address: 'Seongnam, Gyeonggi-do, South Korea',
        latitude: 37.4386,
        longitude: 127.1378,
        provider: 'google',
      ),
      
      // International Major Cities
      LocationSearchResult(
        id: 'singapore_city',
        name: 'Singapore',
        address: 'Singapore',
        latitude: 1.3521,
        longitude: 103.8198,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'new_york_city',
        name: 'New York',
        address: 'New York, NY, USA',
        latitude: 40.7128,
        longitude: -74.0060,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'los_angeles_city',
        name: 'Los Angeles',
        address: 'Los Angeles, CA, USA',
        latitude: 34.0522,
        longitude: -118.2437,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'san_francisco_city',
        name: 'San Francisco',
        address: 'San Francisco, CA, USA',
        latitude: 37.7749,
        longitude: -122.4194,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'chicago_city',
        name: 'Chicago',
        address: 'Chicago, IL, USA',
        latitude: 41.8781,
        longitude: -87.6298,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'london_city',
        name: 'London',
        address: 'London, UK',
        latitude: 51.5074,
        longitude: -0.1278,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'paris_city',
        name: 'Paris',
        address: 'Paris, France',
        latitude: 48.8566,
        longitude: 2.3522,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'berlin_city',
        name: 'Berlin',
        address: 'Berlin, Germany',
        latitude: 52.5200,
        longitude: 13.4050,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'rome_city',
        name: 'Rome',
        address: 'Rome, Italy',
        latitude: 41.9028,
        longitude: 12.4964,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'madrid_city',
        name: 'Madrid',
        address: 'Madrid, Spain',
        latitude: 40.4168,
        longitude: -3.7038,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'beijing_city',
        name: 'Beijing',
        address: 'Beijing, China',
        latitude: 39.9042,
        longitude: 116.4074,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'shanghai_city',
        name: 'Shanghai',
        address: 'Shanghai, China',
        latitude: 31.2304,
        longitude: 121.4737,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'guangzhou_city',
        name: 'Guangzhou',
        address: 'Guangzhou, China',
        latitude: 23.1291,
        longitude: 113.2644,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'shenzhen_city',
        name: 'Shenzhen',
        address: 'Shenzhen, China',
        latitude: 22.5431,
        longitude: 114.0579,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'hong_kong_city',
        name: 'Hong Kong',
        address: 'Hong Kong',
        latitude: 22.3193,
        longitude: 114.1694,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'taipei_city',
        name: 'Taipei',
        address: 'Taipei, Taiwan',
        latitude: 25.0330,
        longitude: 121.5654,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'bangkok_city',
        name: 'Bangkok',
        address: 'Bangkok, Thailand',
        latitude: 13.7563,
        longitude: 100.5018,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'kuala_lumpur_city',
        name: 'Kuala Lumpur',
        address: 'Kuala Lumpur, Malaysia',
        latitude: 3.1390,
        longitude: 101.6869,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'jakarta_city',
        name: 'Jakarta',
        address: 'Jakarta, Indonesia',
        latitude: -6.2088,
        longitude: 106.8456,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'manila_city',
        name: 'Manila',
        address: 'Manila, Philippines',
        latitude: 14.5995,
        longitude: 120.9842,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'ho_chi_minh_city',
        name: 'Ho Chi Minh City',
        address: 'Ho Chi Minh City, Vietnam',
        latitude: 10.8231,
        longitude: 106.6297,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'hanoi_city',
        name: 'Hanoi',
        address: 'Hanoi, Vietnam',
        latitude: 21.0285,
        longitude: 105.8542,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'mumbai_city',
        name: 'Mumbai',
        address: 'Mumbai, India',
        latitude: 19.0760,
        longitude: 72.8777,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'delhi_city',
        name: 'New Delhi',
        address: 'New Delhi, India',
        latitude: 28.6139,
        longitude: 77.2090,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'sydney_city',
        name: 'Sydney',
        address: 'Sydney, Australia',
        latitude: -33.8688,
        longitude: 151.2093,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'melbourne_city',
        name: 'Melbourne',
        address: 'Melbourne, Australia',
        latitude: -37.8136,
        longitude: 144.9631,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'toronto_city',
        name: 'Toronto',
        address: 'Toronto, Canada',
        latitude: 43.6532,
        longitude: -79.3832,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'vancouver_city',
        name: 'Vancouver',
        address: 'Vancouver, Canada',
        latitude: 49.2827,
        longitude: -123.1207,
        provider: 'google',
      ),
      
      // Korean-only entries for better Korean search
      LocationSearchResult(
        id: 'seoul_korean',
        name: '서울',
        address: '서울특별시',
        latitude: 37.5665,
        longitude: 126.9780,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'busan_korean',
        name: '부산',
        address: '부산광역시',
        latitude: 35.1796,
        longitude: 129.0756,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'ulsan_korean',
        name: '울산',
        address: '울산광역시',
        latitude: 35.5384,
        longitude: 129.3114,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'daegu_korean',
        name: '대구',
        address: '대구광역시',
        latitude: 35.8714,
        longitude: 128.6014,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'incheon_korean',
        name: '인천',
        address: '인천광역시',
        latitude: 37.4563,
        longitude: 126.7052,
        provider: 'google',
      ),
      
      // Seoul Wedding Venues & Hotels
      LocationSearchResult(
        id: 'lotte_hotel_seoul',
        name: 'Lotte Hotel Seoul (롯데호텔 서울)',
        address: '서울특별시 중구 을지로 30',
        latitude: 37.5651,
        longitude: 126.9895,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'shilla_hotel_seoul',
        name: 'The Shilla Seoul (신라호텔 서울)',
        address: '서울특별시 중구 동호로 249',
        latitude: 37.5557,
        longitude: 127.0051,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'grand_hyatt_seoul',
        name: 'Grand Hyatt Seoul (그랜드 하얏트 서울)',
        address: '서울특별시 용산구 소월로 322',
        latitude: 37.5433,
        longitude: 126.9956,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'walkerhill_hotel',
        name: 'Walkerhill Hotel (워커힐호텔)',
        address: '서울특별시 광진구 워커힐로 177',
        latitude: 37.5557,
        longitude: 127.1092,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'intercontinental_seoul',
        name: 'InterContinental Seoul COEX (인터컨티넨탈 서울 코엑스)',
        address: '서울특별시 강남구 봉은사로 524',
        latitude: 37.5133,
        longitude: 127.0590,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'jw_marriott_seoul',
        name: 'JW Marriott Hotel Seoul (JW 메리어트 호텔 서울)',
        address: '서울특별시 서초구 신반포로 176',
        latitude: 37.5208,
        longitude: 126.9958,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'banyan_tree_club',
        name: 'Banyan Tree Club & Spa Seoul (반얀트리 클럽 앤 스파 서울)',
        address: '서울특별시 중구 장충단로 60',
        latitude: 37.5589,
        longitude: 127.0071,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'park_hyatt_seoul',
        name: 'Park Hyatt Seoul (파크 하얏트 서울)',
        address: '서울특별시 강남구 테헤란로 606',
        latitude: 37.5101,
        longitude: 127.0594,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'conrad_seoul',
        name: 'Conrad Seoul (콘래드 서울)',
        address: '서울특별시 영등포구 국제금융로 10',
        latitude: 37.5261,
        longitude: 126.9240,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'signiel_seoul',
        name: 'SIGNIEL Seoul (시그니엘 서울)',
        address: '서울특별시 송파구 올림픽로 300',
        latitude: 37.5125,
        longitude: 127.1025,
        provider: 'google',
      ),
      
      // Seoul Event Halls & Wedding Venues
      LocationSearchResult(
        id: 'cj_blossompark',
        name: 'CJ BlossomPark (CJ 블라썸파크)',
        address: '서울특별시 마포구 상암산로 66',
        latitude: 37.5800,
        longitude: 126.8886,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'floating_island',
        name: 'Floating Island (플로팅 아일랜드)',
        address: '서울특별시 서초구 올림픽대로 683',
        latitude: 37.5201,
        longitude: 127.0071,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'seoul_arts_center',
        name: 'Seoul Arts Center (예술의전당)',
        address: '서울특별시 서초구 남부순환로 2406',
        latitude: 37.4798,
        longitude: 127.0114,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'lotte_world_tower_seoul_sky',
        name: 'Lotte World Tower Seoul Sky (롯데월드타워 서울스카이)',
        address: '서울특별시 송파구 올림픽로 300',
        latitude: 37.5126,
        longitude: 127.1025,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'banpo_hangang_park',
        name: 'Banpo Hangang Park (반포한강공원)',
        address: '서울특별시 서초구 신반포로11길 40',
        latitude: 37.5088,
        longitude: 126.9962,
        provider: 'google',
      ),
      
      // Busan Wedding Venues
      LocationSearchResult(
        id: 'park_hyatt_busan',
        name: 'Park Hyatt Busan (파크 하얏트 부산)',
        address: '부산광역시 해운대구 마린시티1로 51',
        latitude: 35.1692,
        longitude: 129.1305,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'lotte_hotel_busan',
        name: 'Lotte Hotel Busan (롯데호텔 부산)',
        address: '부산광역시 부산진구 가야대로 772',
        latitude: 35.1547,
        longitude: 129.0565,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'paradise_hotel_busan',
        name: 'Paradise Hotel Busan (파라다이스호텔 부산)',
        address: '부산광역시 해운대구 해운대해변로 296',
        latitude: 35.1587,
        longitude: 129.1603,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'westin_chosun_busan',
        name: 'The Westin Chosun Busan (웨스틴 조선 부산)',
        address: '부산광역시 해운대구 달맞이길 67',
        latitude: 35.1616,
        longitude: 129.1647,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'shilla_stay_haeundae',
        name: 'Shilla Stay Haeundae (신라스테이 해운대)',
        address: '부산광역시 해운대구 해운대로 570',
        latitude: 35.1595,
        longitude: 129.1604,
        provider: 'google',
      ),
      
      // International Wedding Venues
      LocationSearchResult(
        id: 'marina_bay_sands_singapore',
        name: 'Marina Bay Sands Singapore',
        address: '10 Bayfront Ave, Singapore 018956',
        latitude: 1.2834,
        longitude: 103.8607,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'raffles_hotel_singapore',
        name: 'Raffles Hotel Singapore',
        address: '1 Beach Rd, Singapore 189673',
        latitude: 1.2952,
        longitude: 103.8543,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'shangri_la_singapore',
        name: 'Shangri La Hotel Singapore',
        address: '22 Orange Grove Rd, Singapore 258350',
        latitude: 1.3066,
        longitude: 103.8239,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'plaza_hotel_new_york',
        name: 'The Plaza Hotel New York',
        address: '768 5th Ave, New York, NY 10019, USA',
        latitude: 40.7637,
        longitude: -73.9744,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'st_regis_new_york',
        name: 'The St. Regis New York',
        address: '2 E 55th St, New York, NY 10022, USA',
        latitude: 40.7614,
        longitude: -73.9776,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'ritz_carlton_central_park',
        name: 'The Ritz-Carlton New York, Central Park',
        address: '50 Central Park S, New York, NY 10019, USA',
        latitude: 40.7675,
        longitude: -73.9789,
        provider: 'google',
      ),
      
      // Popular Seoul locations
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
        name: '명동',
        address: '서울특별시 중구 명동2가',
        latitude: 37.5636228,
        longitude: 126.9838673,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'itaewon',
        name: '이태원',
        address: '서울특별시 용산구 이태원동',
        latitude: 37.5345,
        longitude: 126.9949,
        provider: 'google',
      ),
      LocationSearchResult(
        id: 'jamsil',
        name: '잠실',
        address: '서울특별시 송파구 잠실동',
        latitude: 37.5132379,
        longitude: 127.1001822,
        provider: 'google',
      ),
    ];

    // Enhanced search matching with multiple language support
    final results = commonLocations.where((location) {
      final name = location.name.toLowerCase();
      final address = location.address.toLowerCase();
      
      // Direct string matching (exact or partial)
      if (name.contains(normalizedQuery) || address.contains(normalizedQuery)) {
        return true;
      }
      
      // Word-based matching (split by spaces and check each word)
      final queryWords = normalizedQuery.split(' ');
      final nameWords = name.split(' ');
      final addressWords = address.split(' ');
      
      for (String queryWord in queryWords) {
        if (queryWord.isNotEmpty) {
          for (String nameWord in nameWords) {
            if (nameWord.contains(queryWord) || queryWord.contains(nameWord)) {
              return true;
            }
          }
          for (String addressWord in addressWords) {
            if (addressWord.contains(queryWord) || queryWord.contains(addressWord)) {
              return true;
            }
          }
        }
      }
      
      // Enhanced mapping for Korean-English venue terms
      final venueMappings = {
        // Cities
        'seoul': '서울',
        'busan': '부산', 
        'ulsan': '울산',
        'daegu': '대구',
        'incheon': '인천',
        'gwangju': '광주',
        'daejeon': '대전',
        'suwon': '수원',
        'goyang': '고양',
        'seongnam': '성남',
        
        // Hotels and venues
        'hotel': '호텔',
        'lotte': '롯데',
        'shilla': '신라',
        'hyatt': '하얏트',
        'marriott': '메리어트',
        'conrad': '콘래드',
        'intercontinental': '인터컨티넨탈',
        'walkerhill': '워커힐',
        'banyan tree': '반얀트리',
        'signiel': '시그니엘',
        'park': '파크',
        'grand': '그랜드',
        'westin': '웨스틴',
        'paradise': '파라다이스',
        
        // Venue types
        'wedding': '웨딩',
        'venue': '웨딩홀',
        'hall': '홀',
        'resort': '리조트',
        'club': '클럽',
        'spa': '스파',
        'center': '센터',
        'tower': '타워',
        'island': '아일랜드',
        'bay': '베이',
        'marina': '마리나',
        'plaza': '플라자',
        'palace': '팰리스',
        
        // Locations
        'coex': '코엑스',
        'gangnam': '강남',
        'haeundae': '해운대',
        'myeongdong': '명동',
        'hongdae': '홍대',
        'itaewon': '이태원',
        'jamsil': '잠실',
        'banpo': '반포',
        'hangang': '한강',
      };
      
      // Bidirectional mapping check for venues
      for (var entry in venueMappings.entries) {
        // English to Korean
        if (normalizedQuery == entry.key && 
            (name.contains(entry.value) || address.contains(entry.value))) {
          return true;
        }
        // Korean to English  
        if (normalizedQuery == entry.value && 
            (name.contains(entry.key) || address.contains(entry.key))) {
          return true;
        }
        // Partial matches
        if (normalizedQuery.contains(entry.key) && 
            (name.contains(entry.value) || address.contains(entry.value))) {
          return true;
        }
        if (normalizedQuery.contains(entry.value) && 
            (name.contains(entry.key) || address.contains(entry.key))) {
          return true;
        }
      }
      
      // Fuzzy matching for typos (improved)
      if (normalizedQuery.length > 2) {
        // Extract city name from location name (remove parentheses content)
        String cleanName = name.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
        if (_isFuzzyMatch(normalizedQuery, cleanName)) {
          return true;
        }
        
        // Check each word in address
        for (String word in addressWords) {
          if (word.length > 2 && _isFuzzyMatch(normalizedQuery, word)) {
            return true;
          }
        }
      }
      
      return false;
    }).toList();
    
    debugPrint('Found ${results.length} results for "$normalizedQuery"');
    return results;
  }
  
  // Enhanced fuzzy matching for typos and similar strings
  bool _isFuzzyMatch(String query, String target) {
    if (query.length < 3 || target.length < 3) return false;
    
    // Exact match check first
    if (query == target) return true;
    
    // Check if one string is contained in the other (for partial matches)
    if (query.contains(target) || target.contains(query)) return true;
    
    // Levenshtein-like distance check (simplified)
    int maxDistance = (query.length * 0.3).round(); // Allow 30% difference
    return _calculateEditDistance(query, target) <= maxDistance;
  }
  
  // Simple edit distance calculation
  int _calculateEditDistance(String s1, String s2) {
    if (s1.length < s2.length) {
      return _calculateEditDistance(s2, s1);
    }
    
    if (s2.isEmpty) {
      return s1.length;
    }
    
    List<int> previousRow = List.generate(s2.length + 1, (i) => i);
    
    for (int i = 0; i < s1.length; i++) {
      List<int> currentRow = [i + 1];
      
      for (int j = 0; j < s2.length; j++) {
        int insertions = previousRow[j + 1] + 1;
        int deletions = currentRow[j] + 1;
        int substitutions = previousRow[j] + (s1[i] == s2[j] ? 0 : 1);
        
        currentRow.add([insertions, deletions, substitutions].reduce((a, b) => a < b ? a : b));
      }
      
      previousRow = currentRow;
    }
    
    return previousRow.last;
  }
  
}