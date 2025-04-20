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
    return VenueModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      country: json['country'],
      eventType: json['event_type'],
      eventDate: DateTime.parse(json['event_date']),
      mapLinks: Map<String, String>.from(json['map_links']),
    );
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
