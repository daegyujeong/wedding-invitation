class GuestbookMessage {
  final String id;
  final String name;
  final String message;
  final DateTime createdAt;
  final bool isApproved;
  final String? relationship; // 신랑측, 신부측, 친구, 직장동료 등
  final String? avatarUrl;

  GuestbookMessage({
    required this.id,
    required this.name,
    required this.message,
    required this.createdAt,
    this.isApproved = true,
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
      relationship: json['relationship'],
      avatarUrl: json['avatarUrl'],
    );
  }

  GuestbookMessage copyWith({
    String? id,
    String? name,
    String? message,
    DateTime? createdAt,
    bool? isApproved,
    String? relationship,
    String? avatarUrl,
  }) {
    return GuestbookMessage(
      id: id ?? this.id,
      name: name ?? this.name,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isApproved: isApproved ?? this.isApproved,
      relationship: relationship ?? this.relationship,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}