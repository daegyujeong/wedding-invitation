import 'custom_widget_model.dart';

class PageModel {
  final String id;
  final String title;
  final Map<String, dynamic> settings; // General page settings (background, padding, etc.)
  final int order;
  final List<CustomWidgetModel> widgets;

  PageModel({
    required this.id,
    required this.title,
    this.settings = const {},
    required this.order,
    this.widgets = const [],
  });

  // Create a copy with updated fields
  PageModel copyWith({
    String? title,
    Map<String, dynamic>? settings,
    int? order,
    List<CustomWidgetModel>? widgets,
  }) {
    return PageModel(
      id: this.id,
      title: title ?? this.title,
      settings: settings ?? this.settings,
      order: order ?? this.order,
      widgets: widgets ?? this.widgets,
    );
  }

  // Convenience methods for settings
  String get backgroundColor => settings['backgroundColor'] ?? '#FFFFFF';
  String get backgroundImage => settings['backgroundImage'] ?? '';
  double get padding => settings['padding']?.toDouble() ?? 16.0;
  bool get showTitle => settings['showTitle'] ?? true;
  String get titleColor => settings['titleColor'] ?? '#000000';
  double get titleSize => settings['titleSize']?.toDouble() ?? 24.0;

  // Update specific setting
  PageModel updateSetting(String key, dynamic value) {
    final newSettings = Map<String, dynamic>.from(settings);
    newSettings[key] = value;
    return copyWith(settings: newSettings);
  }

  factory PageModel.fromJson(Map<String, dynamic> json) {
    List<CustomWidgetModel> widgetsList = [];
    if (json.containsKey('widgets') && json['widgets'] != null) {
      widgetsList = (json['widgets'] as List)
          .map((w) => CustomWidgetModel.fromJson(w))
          .toList();
    }

    return PageModel(
      id: json['id'],
      title: json['title'],
      settings: json['settings'] ?? {},
      order: json['order'],
      widgets: widgetsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'settings': settings,
      'order': order,
      'widgets': widgets.map((w) => w.toJson()).toList(),
    };
  }
}
