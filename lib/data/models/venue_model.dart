// lib/data/models/venue_model.dart
class VenueModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String country; // "Korea", "Singapore", "Malaysia" 등
  final String eventType; // "Wedding", "Dinner", "Reception" 등
  final DateTime eventDate;
  final Map<String, String> mapLinks; // 다양한 지도 서비스 링크 저장

  VenueModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.country,
    required this.eventType,
    required this.eventDate,
    required this.mapLinks,
  });

  // Supabase와의 직렬화/역직렬화 메서드
  factory VenueModel.fromJson(Map<String, dynamic> json) {
    try {
      // Safely parse numeric values
      final lat = json['latitude'];
      final lng = json['longitude'];
      
      return VenueModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        latitude: lat is num ? lat.toDouble() : double.tryParse(lat.toString()) ?? 0.0,
        longitude: lng is num ? lng.toDouble() : double.tryParse(lng.toString()) ?? 0.0,
        country: json['country']?.toString() ?? '',
        eventType: json['event_type']?.toString() ?? '',
        eventDate: json['event_date'] != null 
            ? DateTime.tryParse(json['event_date'].toString()) ?? DateTime.now()
            : DateTime.now(),
        mapLinks: json['map_links'] != null && json['map_links'] is Map
            ? Map<String, String>.from(json['map_links'])
            : <String, String>{},
      );
    } catch (e) {
      // Return a default venue if parsing completely fails
      return VenueModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Invalid Venue Data',
        address: 'Unknown',
        latitude: 0.0,
        longitude: 0.0,
        country: 'Unknown',
        eventType: 'Unknown',
        eventDate: DateTime.now(),
        mapLinks: <String, String>{},
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'event_type': eventType,
      'event_date': eventDate.toIso8601String(),
      'map_links': mapLinks,
    };
  }
}
