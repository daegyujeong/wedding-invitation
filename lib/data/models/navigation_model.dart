class NavigationItemModel {
  final String id;
  final String title;
  final String icon;
  final bool isBookmark; // true for bookmark, false for redirect
  final String targetPage; // ID of the page to navigate to
  final bool isEnabled;

  NavigationItemModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.isBookmark,
    required this.targetPage,
    this.isEnabled = true,
  });

  // Create a copy with updated fields
  NavigationItemModel copyWith({
    String? title,
    String? icon,
    bool? isBookmark,
    String? targetPage,
    bool? isEnabled,
  }) {
    return NavigationItemModel(
      id: this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      isBookmark: isBookmark ?? this.isBookmark,
      targetPage: targetPage ?? this.targetPage,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  factory NavigationItemModel.fromJson(Map<String, dynamic> json) {
    return NavigationItemModel(
      id: json['id'],
      title: json['title'],
      icon: json['icon'],
      isBookmark: json['is_bookmark'],
      targetPage: json['target_page'],
      isEnabled: json['is_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'is_bookmark': isBookmark,
      'target_page': targetPage,
      'is_enabled': isEnabled,
    };
  }
}

class NavigationBarModel {
  final String id;
  final List<NavigationItemModel> items;
  final bool isEnabled;
  final bool showDDay;
  final DateTime? eventDate;
  final String ddayFormat;

  NavigationBarModel({
    required this.id,
    required this.items,
    this.isEnabled = true,
    this.showDDay = true,
    this.eventDate,
    this.ddayFormat = 'D-{days}',
  });

  // Create a copy with updated fields
  NavigationBarModel copyWith({
    List<NavigationItemModel>? items,
    bool? isEnabled,
    bool? showDDay,
    DateTime? eventDate,
    String? ddayFormat,
  }) {
    return NavigationBarModel(
      id: this.id,
      items: items ?? this.items,
      isEnabled: isEnabled ?? this.isEnabled,
      showDDay: showDDay ?? this.showDDay,
      eventDate: eventDate ?? this.eventDate,
      ddayFormat: ddayFormat ?? this.ddayFormat,
    );
  }

  factory NavigationBarModel.fromJson(Map<String, dynamic> json) {
    return NavigationBarModel(
      id: json['id'],
      items: (json['items'] as List)
          .map((item) => NavigationItemModel.fromJson(item))
          .toList(),
      isEnabled: json['is_enabled'] ?? true,
      showDDay: json['show_dday'] ?? true,
      eventDate: json['event_date'] != null 
          ? DateTime.parse(json['event_date']) 
          : null,
      ddayFormat: json['dday_format'] ?? 'D-{days}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'is_enabled': isEnabled,
      'show_dday': showDDay,
      'event_date': eventDate?.toIso8601String(),
      'dday_format': ddayFormat,
    };
  }
}
