import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  final String id;
  final String invitationId;
  final String name;
  final String message;
  final int likes;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.invitationId,
    required this.name,
    required this.message,
    required this.likes,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      invitationId: json['invitation_id'] as String,
      name: json['name'] as String,
      message: json['message'] as String,
      likes: json['likes'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invitation_id': invitationId,
      'name': name,
      'message': message,
      'likes': likes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? invitationId,
    String? name,
    String? message,
    int? likes,
    DateTime? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      invitationId: invitationId ?? this.invitationId,
      name: name ?? this.name,
      message: message ?? this.message,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        invitationId,
        name,
        message,
        likes,
        createdAt,
      ];
}
