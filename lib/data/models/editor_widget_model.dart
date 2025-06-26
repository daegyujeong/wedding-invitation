import 'package:wedding_invitation/data/models/invitation_model.dart';

enum WidgetType {
  Text,
  Image,
  Map,
  CountdownTimer,
  DDay,
  Gallery,
  Schedule,
}

abstract class EditorWidget {
  final String id;
  final WidgetType type;
  final Map<String, dynamic> data;

  EditorWidget({
    required this.id,
    required this.type,
    required this.data,
  });

  Map<String, dynamic> toJson();

  factory EditorWidget.fromJson(Map<String, dynamic> json) {
    final type = WidgetType.values.firstWhere(
      (e) => e.toString() == 'WidgetType.${json['type']}',
      orElse: () => WidgetType.Text,
    );

    switch (type) {
      case WidgetType.Text:
        return TextWidget.fromJson(json);
      case WidgetType.Image:
        return ImageWidget.fromJson(json);
      case WidgetType.Map:
        return MapWidget.fromJson(json);
      case WidgetType.CountdownTimer:
        return CountdownWidget.fromJson(json);
      case WidgetType.DDay:
        return DDayWidget.fromJson(json);
      case WidgetType.Gallery:
        return GalleryWidget.fromJson(json);
      case WidgetType.Schedule:
        return ScheduleWidget.fromJson(json);
    }
  }

  // Factory methods for creating default widgets
  static EditorWidget createDefault(WidgetType type) {
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    
    switch (type) {
      case WidgetType.Text:
        return TextWidget(
          id: id,
          data: {
            'text': {'ko': '텍스트를 입력하세요', 'en': 'Enter text'},
            'fontFamily': 'Roboto',
            'fontSize': 16.0,
            'color': '#000000',
          },
        );
      case WidgetType.DDay:
        return DDayWidget(
          id: id,
          data: {
            'eventId': 'wedding',
            'format': '결혼식까지 {days}일',
            'style': '기본',
            'title': 'D-Day',
            'targetDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          },
        );
      case WidgetType.CountdownTimer:
        return CountdownWidget(
          id: id,
          data: {
            'targetDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
            'format': 'countdown',
          },
        );
      case WidgetType.Image:
        return ImageWidget(
          id: id,
          data: {
            'imageUrl': 'assets/images/placeholder.png',
            'width': 200.0,
            'height': 200.0,
          },
        );
      case WidgetType.Gallery:
        return GalleryWidget(
          id: id,
          data: {
            'imageUrls': ['assets/images/placeholder.png'],
            'layoutType': 'horizontal',
          },
        );
      case WidgetType.Map:
        return MapWidget(
          id: id,
          data: {
            'venueId': 'main_venue',
            'mapType': 'standard',
            'showDirections': true,
          },
        );
      case WidgetType.Schedule:
        return ScheduleWidget(
          id: id,
          data: {
            'events': [
              {'time': '14:00', 'description': '결혼식'},
              {'time': '15:30', 'description': '피로연'},
            ],
          },
        );
    }
  }
}

class TextWidget extends EditorWidget {
  TextWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.Text);

  MultiLanguageText get text {
    try {
      return MultiLanguageText.fromJson(data['text']);
    } catch (e) {
      // Fallback if MultiLanguageText is not available
      return MultiLanguageText(
        ko: data['text']?.toString() ?? '텍스트를 입력하세요',
        en: data['text']?.toString() ?? 'Enter text',
      );
    }
  }
  
  String get fontFamily => data['fontFamily']?.toString() ?? 'Roboto';
  double get fontSize => (data['fontSize'] as num?)?.toDouble() ?? 16.0;
  String get color => data['color']?.toString() ?? '#000000';

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory TextWidget.fromJson(Map<String, dynamic> json) {
    return TextWidget(
      id: json['id'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}

class DDayWidget extends EditorWidget {
  DDayWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.DDay);

  String get eventId => data['eventId']?.toString() ?? 'wedding';
  String get format => data['format']?.toString() ?? '결혼식까지 {days}일';
  String get style => data['style']?.toString() ?? '기본';
  String get title => data['title']?.toString() ?? 'D-Day';
  
  DateTime get targetDate {
    try {
      return DateTime.parse(data['targetDate']?.toString() ?? '');
    } catch (e) {
      return DateTime.now().add(const Duration(days: 30));
    }
  }

  void setTargetDate(DateTime date) {
    data['targetDate'] = date.toIso8601String();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory DDayWidget.fromJson(Map<String, dynamic> json) {
    return DDayWidget(
      id: json['id'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}

class MapWidget extends EditorWidget {
  MapWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.Map);

  String get venueId => data['venueId']?.toString() ?? 'main_venue';
  String get mapType => data['mapType']?.toString() ?? 'standard';
  bool get showDirections => data['showDirections'] == true;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory MapWidget.fromJson(Map<String, dynamic> json) {
    return MapWidget(
      id: json['id'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}

class ImageWidget extends EditorWidget {
  ImageWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.Image);

  String get imageUrl => data['imageUrl']?.toString() ?? 'assets/images/placeholder.png';
  double get width => (data['width'] as num?)?.toDouble() ?? 200.0;
  double get height => (data['height'] as num?)?.toDouble() ?? 200.0;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory ImageWidget.fromJson(Map<String, dynamic> json) {
    return ImageWidget(
      id: json['id'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}

class CountdownWidget extends EditorWidget {
  CountdownWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.CountdownTimer);

  DateTime get targetDate {
    try {
      return DateTime.parse(data['targetDate']?.toString() ?? '');
    } catch (e) {
      return DateTime.now().add(const Duration(days: 30));
    }
  }
  
  String get format => data['format']?.toString() ?? 'countdown';

  void setTargetDate(DateTime date) {
    data['targetDate'] = date.toIso8601String();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory CountdownWidget.fromJson(Map<String, dynamic> json) {
    return CountdownWidget(
      id: json['id'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}

class GalleryWidget extends EditorWidget {
  GalleryWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.Gallery);

  List<String> get imageUrls {
    try {
      return List<String>.from(data['imageUrls'] ?? []);
    } catch (e) {
      return ['assets/images/placeholder.png'];
    }
  }
  
  String get layoutType => data['layoutType']?.toString() ?? 'horizontal';

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory GalleryWidget.fromJson(Map<String, dynamic> json) {
    return GalleryWidget(
      id: json['id'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}

class ScheduleWidget extends EditorWidget {
  ScheduleWidget({
    required super.id,
    required super.data,
  }) : super(type: WidgetType.Schedule);

  List<Map<String, dynamic>> get events {
    try {
      return List<Map<String, dynamic>>.from(data['events'] ?? []);
    } catch (e) {
      return [
        {'time': '14:00', 'description': '결혼식'},
        {'time': '15:30', 'description': '피로연'},
      ];
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'data': data,
    };
  }

  factory ScheduleWidget.fromJson(Map<String, dynamic> json) {
    return ScheduleWidget(
      id: json['id'],
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }
}
