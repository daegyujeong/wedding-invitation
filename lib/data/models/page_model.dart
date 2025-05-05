import 'custom_widget_model.dart';

class PageModel {
  final String id;
  final String title;
  final String template;
  final Map<String, dynamic> content;
  final int order;
  final List<CustomWidgetModel> widgets; // New field for custom widgets

  PageModel({
    required this.id,
    required this.title,
    required this.template,
    required this.content,
    required this.order,
    this.widgets = const [], // Default to empty list
  });

  // Create a copy with updated fields
  PageModel copyWith({
    String? title,
    String? template,
    Map<String, dynamic>? content,
    int? order,
    List<CustomWidgetModel>? widgets,
  }) {
    return PageModel(
      id: this.id,
      title: title ?? this.title,
      template: template ?? this.template,
      content: content ?? this.content,
      order: order ?? this.order,
      widgets: widgets ?? this.widgets,
    );
  }

  factory PageModel.fromJson(Map<String, dynamic> json) {
    // Parse widgets if present
    List<CustomWidgetModel> widgetsList = [];
    if (json.containsKey('widgets') && json['widgets'] != null) {
      widgetsList = (json['widgets'] as List)
          .map((w) => CustomWidgetModel.fromJson(w))
          .toList();
    }

    return PageModel(
      id: json['id'],
      title: json['title'],
      template: json['template'],
      content: json['content'],
      order: json['order'],
      widgets: widgetsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'template': template,
      'content': content,
      'order': order,
      'widgets': widgets.map((w) => w.toJson()).toList(),
    };
  }
}