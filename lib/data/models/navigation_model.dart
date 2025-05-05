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

  NavigationBarModel({
    required this.id,
    required this.items,
    this.isEnabled = true,
  });

  // Create a copy with updated fields
  NavigationBarModel copyWith({
    List<NavigationItemModel>? items,
    bool? isEnabled,
  }) {
    return NavigationBarModel(
      id: this.id,
      items: items ?? this.items,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  factory NavigationBarModel.fromJson(Map<String, dynamic> json) {
    return NavigationBarModel(
      id: json['id'],
      items: (json['items'] as List)
          .map((item) => NavigationItemModel.fromJson(item))
          .toList(),
      isEnabled: json['is_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'is_enabled': isEnabled,
    };
  }
}