// lib/data/models/rsvp_model.dart
class RSVPModel {
  final String id;
  final String guestName;
  final String email;
  final bool isAttending;
  final List<String> selectedVenues; // ['my', 'sg', 'ko']
  final String? additionalNotes;
  final DateTime submittedAt;

  RSVPModel({
    required this.id,
    required this.guestName,
    required this.email,
    required this.isAttending,
    required this.selectedVenues,
    this.additionalNotes,
    required this.submittedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guest_name': guestName,
      'email': email,
      'is_attending': isAttending,
      'selected_venues': selectedVenues,
      'additional_notes': additionalNotes,
      'submitted_at': submittedAt.toIso8601String(),
    };
  }

  factory RSVPModel.fromJson(Map<String, dynamic> json) {
    // Handle timezone conversion like guestbook model
    final submittedAtString = json['submitted_at'] as String;
    final parsedDateTime = DateTime.parse(submittedAtString);
    
    return RSVPModel(
      id: json['id'] as String,
      guestName: json['guest_name'] as String,
      email: json['email'] as String,
      isAttending: json['is_attending'] as bool,
      selectedVenues: List<String>.from(json['selected_venues'] ?? []),
      additionalNotes: json['additional_notes'] as String?,
      submittedAt: parsedDateTime.isUtc ? parsedDateTime.toLocal() : parsedDateTime,
    );
  }

  // Supabase uses snake_case for column names
  factory RSVPModel.fromSupabase(Map<String, dynamic> json) {
    // Follow explicit timezone conversion pattern like guestbook
    final raw = json['submitted_at'] as String;
    final utc = DateTime.parse(raw);      // already treated as UTC
    final local = utc.toLocal();          // convert to browser/device local time
    
    return RSVPModel(
      id: json['id'] as String,
      guestName: json['guest_name'] as String,
      email: json['email'] as String,
      isAttending: json['is_attending'] as bool,
      selectedVenues: List<String>.from(json['selected_venues'] ?? []),
      additionalNotes: json['additional_notes'] as String?,
      submittedAt: local,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'guest_name': guestName,
      'email': email,
      'is_attending': isAttending,
      'selected_venues': selectedVenues,
      'additional_notes': additionalNotes,
      'submitted_at': submittedAt.toIso8601String(), // Already in UTC, no conversion needed
    };
  }
  
  RSVPModel copyWith({
    String? id,
    String? guestName,
    String? email,
    bool? isAttending,
    List<String>? selectedVenues,
    String? additionalNotes,
    DateTime? submittedAt,
  }) {
    return RSVPModel(
      id: id ?? this.id,
      guestName: guestName ?? this.guestName,
      email: email ?? this.email,
      isAttending: isAttending ?? this.isAttending,
      selectedVenues: selectedVenues ?? this.selectedVenues,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}