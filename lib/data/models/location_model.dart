// lib/data/models/location_model.dart
class LocationModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? placeId;
  final String? phoneNumber;
  final String? website;
  final String? rating;
  final List<String>? types;
  final Map<String, dynamic>? openingHours;

  const LocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.placeId,
    this.phoneNumber,
    this.website,
    this.rating,
    this.types,
    this.openingHours,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? json['formatted_address'] ?? '',
      latitude: (json['latitude'] ?? json['lat'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? json['lng'] ?? 0.0).toDouble(),
      placeId: json['placeId'] ?? json['place_id'],
      phoneNumber: json['phoneNumber'] ?? json['formatted_phone_number'],
      website: json['website'],
      rating: json['rating']?.toString(),
      types: json['types'] != null 
          ? List<String>.from(json['types']) 
          : null,
      openingHours: json['opening_hours'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'placeId': placeId,
      'phoneNumber': phoneNumber,
      'website': website,
      'rating': rating,
      'types': types,
      'openingHours': openingHours,
    };
  }

  LocationModel copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? placeId,
    String? phoneNumber,
    String? website,
    String? rating,
    List<String>? types,
    Map<String, dynamic>? openingHours,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      rating: rating ?? this.rating,
      types: types ?? this.types,
      openingHours: openingHours ?? this.openingHours,
    );
  }

  @override
  String toString() {
    return 'LocationModel(id: $id, name: $name, address: $address, lat: $latitude, lng: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel &&
        other.id == id &&
        other.name == name &&
        other.address == address &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        address.hashCode ^
        latitude.hashCode ^
        longitude.hashCode;
  }
}