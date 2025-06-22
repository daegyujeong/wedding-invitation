class MessageModel {
  final String id;
  final String name;
  final String message;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.name,
    required this.message,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      name: json['name'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'message': message,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
