import 'editor_widget_model.dart';

class PageModel {
  final String id;
  final String title;
  final Map<String, dynamic>
      settings; // General page settings (background, padding, etc.)
  final int order;

  PageModel({
    required this.id,
    required this.title,
    this.settings = const {},
    required this.order,
  });

  // Create a copy with updated fields
  PageModel copyWith({
    String? title,
    Map<String, dynamic>? settings,
    int? order,
  }) {
    return PageModel(
      id: id,
      title: title ?? this.title,
      settings: settings ?? this.settings,
      order: order ?? this.order,
    );
  }

  // Convenience methods for settings
  String get backgroundColor => settings['backgroundColor'] ?? '#FFFFFF';
  String get backgroundImage => settings['backgroundImage'] ?? '';
  double get padding => settings['padding']?.toDouble() ?? 16.0;
  bool get showTitle => settings['showTitle'] ?? true;
  String get titleColor => settings['titleColor'] ?? '#000000';
  double get titleSize => settings['titleSize']?.toDouble() ?? 24.0;

  // EditorWidget list convenience methods
  List<EditorWidget> get widgets {
    if (settings['widgets'] == null) return [];
    return (settings['widgets'] as List<dynamic>)
        .map((json) => EditorWidget.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Helper method to create a new PageModel with updated widgets
  PageModel withWidgets(List<EditorWidget> widgets) {
    final newSettings = Map<String, dynamic>.from(settings);
    newSettings['widgets'] = widgets.map((widget) => widget.toJson()).toList();
    return copyWith(settings: newSettings);
  }

  // Update specific setting
  PageModel updateSetting(String key, dynamic value) {
    final newSettings = Map<String, dynamic>.from(settings);
    newSettings[key] = value;
    return copyWith(settings: newSettings);
  }

  factory PageModel.fromJson(Map<String, dynamic> json) {
    return PageModel(
      id: json['id'],
      title: json['title'],
      settings: json['settings'] ?? {},
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'settings': settings,
      'order': order,
    };
  }
}
