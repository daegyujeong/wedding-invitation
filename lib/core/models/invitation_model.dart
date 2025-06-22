import 'package:equatable/equatable.dart';

class InvitationModel extends Equatable {
  final String id;
  final String templateId;
  final String groomName;
  final String brideName;
  final DateTime weddingDate;
  final String weddingTime;
  final String venue;
  final String address;
  final String? groomFather;
  final String? groomMother;
  final String? brideFather;
  final String? brideMother;
  final String? greeting;
  final String? coverImage;
  final List<String> galleryImages;
  final Map<String, dynamic> styleSettings;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InvitationModel({
    required this.id,
    required this.templateId,
    required this.groomName,
    required this.brideName,
    required this.weddingDate,
    required this.weddingTime,
    required this.venue,
    required this.address,
    this.groomFather,
    this.groomMother,
    this.brideFather,
    this.brideMother,
    this.greeting,
    this.coverImage,
    required this.galleryImages,
    required this.styleSettings,
    this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'] as String,
      templateId: json['template_id'] as String,
      groomName: json['groom_name'] as String,
      brideName: json['bride_name'] as String,
      weddingDate: DateTime.parse(json['wedding_date'] as String),
      weddingTime: json['wedding_time'] as String,
      venue: json['venue'] as String,
      address: json['address'] as String,
      groomFather: json['groom_father'] as String?,
      groomMother: json['groom_mother'] as String?,
      brideFather: json['bride_father'] as String?,
      brideMother: json['bride_mother'] as String?,
      greeting: json['greeting'] as String?,
      coverImage: json['cover_image'] as String?,
      galleryImages: List<String>.from(json['gallery_images'] ?? []),
      styleSettings: json['style_settings'] as Map<String, dynamic>? ?? {},
      userId: json['user_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'template_id': templateId,
      'groom_name': groomName,
      'bride_name': brideName,
      'wedding_date': weddingDate.toIso8601String(),
      'wedding_time': weddingTime,
      'venue': venue,
      'address': address,
      'groom_father': groomFather,
      'groom_mother': groomMother,
      'bride_father': brideFather,
      'bride_mother': brideMother,
      'greeting': greeting,
      'cover_image': coverImage,
      'gallery_images': galleryImages,
      'style_settings': styleSettings,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  InvitationModel copyWith({
    String? id,
    String? templateId,
    String? groomName,
    String? brideName,
    DateTime? weddingDate,
    String? weddingTime,
    String? venue,
    String? address,
    String? groomFather,
    String? groomMother,
    String? brideFather,
    String? brideMother,
    String? greeting,
    String? coverImage,
    List<String>? galleryImages,
    Map<String, dynamic>? styleSettings,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvitationModel(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      groomName: groomName ?? this.groomName,
      brideName: brideName ?? this.brideName,
      weddingDate: weddingDate ?? this.weddingDate,
      weddingTime: weddingTime ?? this.weddingTime,
      venue: venue ?? this.venue,
      address: address ?? this.address,
      groomFather: groomFather ?? this.groomFather,
      groomMother: groomMother ?? this.groomMother,
      brideFather: brideFather ?? this.brideFather,
      brideMother: brideMother ?? this.brideMother,
      greeting: greeting ?? this.greeting,
      coverImage: coverImage ?? this.coverImage,
      galleryImages: galleryImages ?? this.galleryImages,
      styleSettings: styleSettings ?? this.styleSettings,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        templateId,
        groomName,
        brideName,
        weddingDate,
        weddingTime,
        venue,
        address,
        groomFather,
        groomMother,
        brideFather,
        brideMother,
        greeting,
        coverImage,
        galleryImages,
        styleSettings,
        userId,
        createdAt,
        updatedAt,
      ];
}
