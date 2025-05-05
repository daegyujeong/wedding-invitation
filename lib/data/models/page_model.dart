class PageModel {
  final String id;
  final String title;
  final String template;
  final Map<String, dynamic> content;
  final int order;

  PageModel({
    required this.id,
    required this.title,
    required this.template,
    required this.content,
    required this.order,
  });

  // Create a copy with updated fields
  PageModel copyWith({
    String? title,
    String? template,
    Map<String, dynamic>? content,
    int? order,
  }) {
    return PageModel(
      id: this.id,
      title: title ?? this.title,
      template: template ?? this.template,
      content: content ?? this.content,
      order: order ?? this.order,
    );
  }

  factory PageModel.fromJson(Map<String, dynamic> json) {
    return PageModel(
      id: json['id'],
      title: json['title'],
      template: json['template'],
      content: json['content'],
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'template': template,
      'content': content,
      'order': order,
    };
  }
}