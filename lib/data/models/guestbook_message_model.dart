class GuestbookMessage {
  final String id;
  final String name;
  final String message;
  final DateTime createdAt;
  final bool isApproved;
  final bool isDeleted;
  final String? password; // For deletion authentication
  final String? relationship; // 신랑측, 신부측, 친구, 직장동료 등
  final String? avatarUrl;

  GuestbookMessage({
    required this.id,
    required this.name,
    required this.message,
    required this.createdAt,
    this.isApproved = true,
    this.isDeleted = false,
    this.password,
    this.relationship,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isApproved': isApproved,
      'isDeleted': isDeleted,
      'password': password,
      'relationship': relationship,
      'avatarUrl': avatarUrl,
    };
  }

  factory GuestbookMessage.fromJson(Map<String, dynamic> json) {
    return GuestbookMessage(
      id: json['id'],
      name: json['name'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt']),
      isApproved: json['isApproved'] ?? true,
      isDeleted: json['isDeleted'] ?? false,
      password: json['password'],
      relationship: json['relationship'],
      avatarUrl: json['avatarUrl'],
    );
  }

  // Supabase uses snake_case for column names
  factory GuestbookMessage.fromSupabase(Map<String, dynamic> json) {
    return GuestbookMessage(
      id: json['id'],
      name: json['name'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      isApproved: json['is_approved'] ?? true,
      isDeleted: json['is_deleted'] ?? false,
      password: json['password'],
      relationship: json['relationship'],
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'name': name,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_approved': isApproved,
      'is_deleted': isDeleted,
      'password': password,
      'relationship': relationship,
      'avatar_url': avatarUrl,
    };
  }

  GuestbookMessage copyWith({
    String? id,
    String? name,
    String? message,
    DateTime? createdAt,
    bool? isApproved,
    bool? isDeleted,
    String? password,
    String? relationship,
    String? avatarUrl,
  }) {
    return GuestbookMessage(
      id: id ?? this.id,
      name: name ?? this.name,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isApproved: isApproved ?? this.isApproved,
      isDeleted: isDeleted ?? this.isDeleted,
      password: password ?? this.password,
      relationship: relationship ?? this.relationship,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}